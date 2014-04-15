## Molecule.CreditCard
La molécula credit card proporciona un formulario para realizar pagos con tarjetas de crédito mediante Stripe. Para poder comenzar a realizar pagos con stripe solo necesitas realizar 3 sencillos pasos.

1.	Crear un cuenta en  [Stripe](https://stripe.com/), una vez con la cuenta creada en tu sección de claves del dashboard te proporcionarán las dos claves para poder hacer efectivos los pagos. (pública y privada)
2.	Arrastra la Molecula.CreditCard a tu app, una vez instanciada debes asignarle la clave pública antes citada y una url que apunte a tu server que será el que valide y procese lo pagos.
3.	Ten listo tu server para recibir las peticiones de pago de tu app. Aquí tienes unos ejemplos de algunos servers [Stripe server samples](https://stripe.com/docs/examples)



### Attributes
```
id    		: [OPTIONAL]
stripeKey 	: "pk_test_000000000000000000000"
url			: "www.your-server-api.example"
```

### Methods
#### .onButtonTouch()
Este método es el que activa la validación y el envío el formulario de pago. Para que el formulario sea considerado como válido se han de introducir parámetos correctos en todos los campos de los input.

Una vez validados todos los parámetros introducidos en el formulario se generará un token que contiene toda la información. Este token es el que se envia a tu servidor y te permite hacer efectivo el pago.

**Input correct parameters example**

```
creditcard	  : "4242424242424242"
cvc   	      : "123"
expire_month  : "11"
expire_year   : "2015"
```
<strong>Recuerda: La fecha de expiración debe ser mayor que la actual para considerarse válida.</strong>

**Input incorrect parameters example**

```
creditcard	  : "4000000000000002"
cvc   	      : "11"
expire_month  : "13"
expire_year   : "1970"
```

### Events

#### onStripeCreditCardSubmit


#### onStripeCreditCardError


#### onStripeCreditCardChange
