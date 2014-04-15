"use strict"

class Atoms.Molecule.StripeCreditCard extends Atoms.Molecule.Form

  @extends  : true

  @default  :
    events  : ["submit", "error"]
    children: [
        "Atom.Input": id: "number", type: "tel", placeholder: "Credit card number", required: true, events: ["keyup"]
      ,
        "Atom.Input": id: "month", type: "tel", placeholder: "MM", events: ["keyup"]
      ,
        "Atom.Input": id: "year", type: "tel", placeholder: "YYYY", events: ["keyup"]
      ,
        "Atom.Input": id: "cvc", type: "tel", placeholder: "CVC", events: ["keyup"]
      ,
        "Atom.Button": id: "submit", text: "Send Payment", style: "fluid accept", disabled: true
    ]

  constructor: ->
    super
    do __loadScript
    if @attributes.amount
      @submit.el.html (@attributes.concept or "Pay") + " #{@attributes.amount}"

  # Instance Methods
  post: (token) =>
    parameters =
      token     : token
      amount    : @attributes.amount
      reference : @attributes.reference

    $$.ajax
      url         : @attributes.url
      type        : "POST"
      dataType    : "json"
      data        : parameters
      contentType : "application/x-www-form-urlencoded"
      success: (xhr) =>
        @bubble "submit", xhr
        Atoms.App?.Modal?.Loading?.hide()
      error: (xhr, error) =>
        @bubble "error", error
        Atoms.App?.Modal?.Loading?.hide()

  # Children Bubble Events
  onButtonTouch: (event, form) ->
    Atoms.App?.Modal?.Loading?.show()

    Stripe.setPublishableKey @attributes.key
    parameters =
      number    : @number.value()
      cvc       : @cvc.value()
      exp_month : @month.value()
      exp_year  : @year.value()
    window.Stripe.createToken parameters, (status, response) =>
      if response.error
        Atoms.App?.Modal?.Loading?.hide()
        @bubble "error", response.error
      else
        @post response.id
    false

  onInputKeyup: ->
    valid = true
    input.error?(false) for input in @children
    if not @attributes.url or not @attributes.key
      valid = false
    else if not Stripe.validateCardNumber @number.value()
      valid = false
      @number.error true
    else if not Stripe.validateExpiry @month.value(), @year.value()
      valid = false
      @month.error true
      @year.error true
    else if not Stripe.validateCVC @cvc.value()
      valid = false
      @cvc.error true

    if valid
      @submit.el.removeAttr "disabled"
    else
      @submit.el.attr "disabled", true
    false

__loadScript = (callback) ->
  script = document.createElement("script")
  script.type = "text/javascript"
  script.src = "https://js.stripe.com/v1/"
  script.setAttribute "data-extension", "stripe"
  script.onload = -> callback.call @ if callback?
  document.body.appendChild script
