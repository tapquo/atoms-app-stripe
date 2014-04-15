"use strict"

class Atoms.Molecule.StripeCreditCard extends Atoms.Molecule.Form

  @available: ["Atom.Input", "Atom.Button"]

  @events   : ["submit"]

  @extends  : true

  @default  :
    events  : ["submit", "error"]
    children: [
        "Atom.Input": id: "card_number", placeholder: "Type your credit card number", required: true, events: ["change"], callbacks: ["validate"]
      ,
        "Atom.Input": id: "card_cvc", placeholder: "Type your credit card cvc", required: true, events: ["change"], callbacks: ["validate"]
      ,
        "Atom.Input": id: "card_expiry_month", placeholder: "MM", required: true, events: ["change"], callbacks: ["validate"]
      ,
        "Atom.Input": id: "card_expiry_year", placeholder: "YYYY", required: true, events: ["change"], callbacks: ["validate"]
      ,
        "Atom.Button": text: "submit payment", style: "fluid accept"
    ]

  output: ->
    super
    exists = Atoms.$("[data-extension=stripe]").length > 0
    if exists then do @__init else __loadScript @__init

  # Children Bubble Events
  onButtonTouch: (event, form) ->
    event.preventDefault()

    if @attributes.url? and @attributes.stripeKey? and @validate()
      Atoms.App?.Modal?.Loading?.show()

      Stripe.setPublishableKey @attributes.stripeKey
      parameters =
        number    : @card_number.el.val()
        cvc       : @card_cvc.el.val()
        exp_month : @card_expiry_month.el.val()
        exp_year  : @card_expiry_year.el.val()
      window.Stripe.createToken parameters, @_onStripeCreateToken
    else
      @bubble "error", "?"
    false

  # Private Methods
  _onStripeCreateToken: (status, response) =>
    if response.error
      Atoms.App?.Modal?.Loading?.hide()
      #@bubble "error", response.error
    else
      @post response.id

  validate: ->
    if not Stripe.validateCardNumber @card_number.el.val()
      console.log "Invalid Card Number"
      false
    else if not Stripe.validateCVC @card_cvc.el.val()
      console.log "Invalid CVC"
      false
    else if not Stripe.validateExpiry @card_expiry_month.el.val(), @card_expiry_year.el.val()
      console.log "Invalid Expiry Date"
      false
    else true

  post: (token) =>
    $$.ajax
      url         : @attributes.url
      type        : "POST"
      data        : { stripeToken: token}
      dataType    : 'json'
      contentType : "application/x-www-form-urlencoded"
      success: (xhr) ->
        #@bubble "submit"
        Atoms.App?.Modal?.Loading?.hide()
        console.log xhr
      error: (xhr, error) =>
        #@bubble "error" 
        Atoms.App?.Modal?.Loading?.hide()


__loadScript = (callback) ->
  window.google = maps: {}
  script = document.createElement("script")
  script.type = "text/javascript"
  script.src = "https://js.stripe.com/v1/"
  script.setAttribute "data-extension", "stripe"
  script.onload = -> callback.call @ if callback?
  document.body.appendChild script

Atoms.$ ->
  new Atoms.Molecule.StripeCreditCard container: "body", url: "http://localhost:8080/stripe", stripeKey: "pk_test_INaJhR0dwOhLo9PAfK4IKH6n"
