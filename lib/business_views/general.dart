import 'dart:convert';
import 'dart:io';

import 'package:compressimage/compressimage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:zerdaly_business_app/Token.dart';
import 'package:zerdaly_business_app/main.dart';
import 'package:zerdaly_business_app/model/business.dart';

class BusinessGeneral extends StatefulWidget {
  @override
  BusinessGeneralState createState() => BusinessGeneralState();
}

class BusinessGeneralState extends State<BusinessGeneral> {
  final token = Token.instance;
  Business business = new Business();
  var businessInfo;
  var sales;
  var orders;
  var products;
  var likes;

  int pages = 0;
  int validationPage = 0;

  String bankName = "";
  String bankType = "";
  TextEditingController bankHolder = new TextEditingController();
  TextEditingController bankNumber = new TextEditingController();
  var cardNumber = new MaskedTextController(mask: '0000 0000 0000 0000');
  var cardDate = new MaskedTextController(mask: '00/00');
  var cardCVV = new MaskedTextController(mask: '0000');
  bool subscriptionValidationProcess = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final productUrl = 'https://api.zerdaly.com/api/business/getimage/product/';

  @override
  void initState() {
    super.initState();

    getBusinessInfo();
  }

  getBusinessInfo() async {
    final result = await token.queryAllRows();
    final auth = result[0]["Auth"];
    final response = await business.info(auth);

    setState(() {
      businessInfo = response[1];
      sales = response[2];
      orders = response[3];
      products = response[4];
      likes = response[5];
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (pages != 0) {
            getBusinessInfo();
            setState(() {
              pages = 0;
            });
          }
          return false;
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              "Zerdaly",
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 15,
                  color: Colors.white,
                  fontFamily: "Pacifico"),
            ),
            elevation:
                defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.store,
                      color: Colors.grey,
                      size: 40.0,
                    ),
                  ),
                  accountName: Text(
                    businessInfo != null ? businessInfo["business_name"] : "",
                    style: TextStyle(color: Colors.white, fontFamily: 'Kanit'),
                  ),
                  accountEmail: Text(
                    businessInfo != null ? businessInfo["email"] : "",
                    style: TextStyle(color: Colors.white, fontFamily: 'Kanit'),
                  ),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.category,
                    color: Color.fromRGBO(255, 144, 82, 1),
                  ),
                  title: Text("General",
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Kanit',
                          fontSize: 18)),
                  onTap: () {
                    setState(() {
                      pages = 0;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  trailing: Icon(
                    Icons.bubble_chart,
                    color: Color.fromRGBO(255, 144, 82, 1),
                  ),
                  title: Text("Productos",
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Kanit',
                          fontSize: 18)),
                  onTap: () {
                    setState(() {
                      pages = 2;
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  trailing: Icon(
                    Icons.insert_chart,
                    color: Color.fromRGBO(255, 144, 82, 1),
                  ),
                  title: Text("Ventas",
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Kanit',
                          fontSize: 18)),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.monetization_on,
                    color: Color.fromRGBO(255, 144, 82, 1),
                  ),
                  title: Text("Ganancias",
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Kanit',
                          fontSize: 18)),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.card_giftcard,
                    color: Color.fromRGBO(255, 144, 82, 1),
                  ),
                  title: Text("Suscripción",
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Kanit',
                          fontSize: 18)),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.store,
                    color: Color.fromRGBO(255, 144, 82, 1),
                  ),
                  title: Text("Mi cuenta",
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Kanit',
                          fontSize: 18)),
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Color.fromRGBO(255, 144, 82, 1),
                  ),
                  title: Text("Cerrar sesión",
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Kanit',
                          fontSize: 18)),
                  onTap: () async {
                    await token.delete(1);
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MySplashScreen()));
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.info,
                    color: Color.fromRGBO(255, 144, 82, 1),
                  ),
                  title: Text("Términos y Condiciones",
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Kanit',
                          fontSize: 18)),
                )
              ],
            ),
          ),
          body: page(),
        ));
  }

  Widget page() {
    switch (pages) {
      case 0:
        return general();
      case 1:
        return activateAccount();
      case 2:
        return product();
      case 3:
        return newProduct();
      case 4:
        return editProduct();
    }
    return Container();
  }

//general section
  Widget general() {
    return ListView(
      children: <Widget>[
        businessInfo != null
            ? businessInfo["validated"] == 0
                ? Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                          child: ListTile(
                        trailing: Icon(
                          Icons.notification_important,
                          color: Colors.yellow[700],
                        ),
                        title: Text(
                          "Activa tu cuenta para procesar pagos.",
                          style: TextStyle(
                              fontFamily: 'Kanit', color: Colors.grey),
                        ),
                        onTap: () {
                          setState(() {
                            pages = 1;
                          });
                        },
                      )),
                    ),
                  )
                : Container()
            : Container(),
        Row(
          children: <Widget>[
            Spacer(),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  height: MediaQuery.of(context).size.height / 4.1,
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Text(
                            "Ventas",
                            style: TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width / 19),
                          ),
                          trailing: Icon(
                            Icons.insert_chart,
                            color: Color.fromRGBO(255, 144, 82, 1),
                          ),
                        ),
                        orders != null
                            ? Text(
                                orders.length.toString(),
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.width / 6,
                                    color: Colors.grey[600]),
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                )),
            Spacer(),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  height: MediaQuery.of(context).size.height / 4.1,
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Text(
                            "Productos",
                            style: TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width / 19),
                          ),
                          trailing: Icon(
                            Icons.bubble_chart,
                            color: Color.fromRGBO(255, 144, 82, 1),
                          ),
                        ),
                        products != null
                            ? Text(
                                products.length.toString(),
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.width / 6,
                                    color: Colors.grey[600]),
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                )),
            Spacer()
          ],
        ),
        Row(
          children: <Widget>[
            Spacer(),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  height: MediaQuery.of(context).size.height / 4.1,
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Text(
                            "Envíos",
                            style: TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width / 19),
                          ),
                          trailing: Icon(
                            Icons.local_shipping,
                            color: Color.fromRGBO(255, 144, 82, 1),
                          ),
                        ),
                        orders != null
                            ? Text(
                                shippingsAmountText(),
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.width / 6,
                                    color: Colors.grey[600]),
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                )),
            Spacer(),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  height: MediaQuery.of(context).size.height / 4.1,
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Text(
                            "Ganancia",
                            style: TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width / 19),
                          ),
                          trailing: Icon(
                            Icons.monetization_on,
                            color: Color.fromRGBO(255, 144, 82, 1),
                          ),
                        ),
                        sales != null
                            ? Text(
                                incomeAmountText(),
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.width / 12,
                                    color: Colors.grey[600]),
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                )),
            Spacer()
          ],
        ),
        Row(
          children: <Widget>[
            Spacer(),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  height: MediaQuery.of(context).size.height / 4.1,
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Text(
                            "Suscripción",
                            style: TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width / 20),
                          ),
                          trailing: Icon(
                            Icons.card_giftcard,
                            color: Color.fromRGBO(255, 144, 82, 1),
                          ),
                        ),
                        businessInfo != null
                            ? Text(
                                businessInfo["status"] == 0
                                    ? "No Activa"
                                    : "Activa",
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.width / 12,
                                    color: businessInfo["status"] == 0
                                        ? Colors.grey
                                        : Colors.green),
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                )),
            Spacer(),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  height: MediaQuery.of(context).size.height / 4.1,
                  child: Card(
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Text(
                            "Likes",
                            style: TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.grey[600],
                                fontSize:
                                    MediaQuery.of(context).size.width / 19),
                          ),
                          trailing: Icon(
                            Icons.star,
                            color: Color.fromRGBO(255, 144, 82, 1),
                          ),
                        ),
                        likes != null
                            ? Text(
                                likes.length.toString(),
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.width / 6,
                                    color: Colors.grey[600]),
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    ),
                  ),
                )),
            Spacer()
          ],
        ),
      ],
    );
  }

  String shippingsAmountText() {
    int count = 1;

    for (var i = 0; i < orders.length - 1; i++) {
      if (orders[i]["delivery_id"] != null) {
        count++;
      }
    }

    return count.toString();
  }

  String incomeAmountText() {
    int amount = 0;
    var now = DateTime.now().toString();
    var split = now.split("-");
    String weekYear = split[0] + "-" + Jiffy().week.toString();

    for (var i = 0; i < sales[weekYear].length; i++) {
      amount += sales[weekYear][i]["business_total"];
    }

    return "\$" + amount.toString();
  }

  Widget activateAccount() {
    return validationPage == 0 ? addBankAcount() : activateSubscription();
  }

  Widget addBankAcount() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Center(
          child: Text(
            "Activa tu cuenta",
            style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(255, 144, 82, 1)),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text(
            "Agrega tu cuenta de banco ",
            style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700]),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10, left: 10, bottom: 10),
          child: Text(
            "Zerdaly deposita semanalmente, los ingresos que obtienes al vender tus productos.",
            style: TextStyle(
                fontFamily: 'Kanit', fontSize: 18, color: Colors.grey),
          ),
        ),
        Card(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Nombre del Banco",
                    style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(255, 144, 82, 1)),
                  ),
                  Container(
                      child: DropdownButton<String>(
                          items: <String>[
                            'Banco Popular Dominicano',
                            'Banserveras'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String res) {
                            setState(() {
                              bankName = res;
                            });
                          },
                          hint: Text(
                            bankName == "" ? "Tu banco" : bankName,
                            style: TextStyle(
                              fontFamily: 'Kanit',
                            ),
                          ))),
                  Text(
                    "Tipo de cuenta",
                    style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(255, 144, 82, 1)),
                  ),
                  Container(
                      child: DropdownButton<String>(
                          items: <String>['Corriente', 'Ahorros']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String res) {
                            setState(() {
                              bankType = res;
                            });
                          },
                          hint: Text(
                            bankType == "" ? "Tipo de cuenta" : bankType,
                            style: TextStyle(
                              fontFamily: 'Kanit',
                            ),
                          ))),
                  Text(
                    "Número de cuenta",
                    style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(255, 144, 82, 1)),
                  ),
                  TextField(
                    controller: bankNumber,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    decoration: InputDecoration(
                      hintText: 'Ej: 777343656',
                      hintStyle: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    "Nombre del propietario",
                    style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(255, 144, 82, 1)),
                  ),
                  TextField(
                    controller: bankHolder,
                    decoration: InputDecoration(
                      hintText: 'Ej: Juan Bosch',
                      hintStyle: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )),
        ),
        GestureDetector(
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height / 14,
            child: Center(
              child: Card(
                color: Color.fromRGBO(255, 144, 82, 1),
                child: Center(
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Kanit', fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
          onTap: () async {
            if (bankName == "" ||
                bankType == "" ||
                bankNumber.text.isEmpty ||
                bankHolder.text.isEmpty) {
              errorMessage("Por favor, completa todos los campos.");
            } else if (bankNumber.text.length > 9 ||
                bankNumber.text.length < 9) {
              errorMessage("El número de cuenta debe tener 9 dígitos.");
            } else if (bankHolder.text.length < 6) {
              errorMessage(
                  "El nombre del propietario debe tener mínimo 6 Letras.");
            } else {
              setState(() {
                validationPage = 1;
              });
            }
          },
        )
      ],
    );
  }

  Widget activateSubscription() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Center(
          child: Text(
            "Activa tu cuenta",
            style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color.fromRGBO(255, 144, 82, 1)),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text(
            "Agrega tu método de pago",
            style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700]),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 10, left: 10, bottom: 10),
          child: Text(
            "Para regalarte 30 días de prueba gratis, necesitamos validar tu método de pago. Puedes cancelar tu suscripción cuando quieras.",
            style: TextStyle(
                fontFamily: 'Kanit', fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.right,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Activar suscripción",
                    style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(255, 144, 82, 1)),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 2.2,
                        child: TextField(
                          controller: cardNumber,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '4242 4242 4242 4242',
                            hintStyle: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        child: TextField(
                          controller: cardDate,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '02/22',
                            hintStyle: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width / 6,
                        child: TextField(
                          controller: cardCVV,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            hintStyle: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        subscriptionValidationProcess == false
            ? GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width / 4,
                  height: MediaQuery.of(context).size.height / 14,
                  child: Center(
                    child: Card(
                      color: Color.fromRGBO(255, 144, 82, 1),
                      child: Center(
                        child: Text(
                          '¡Acepto!',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Kanit',
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  if (cardNumber.text.isEmpty ||
                      cardDate.text.isEmpty ||
                      cardCVV.text.isEmpty) {
                    errorMessage("Por favor, completa todos los campos.");
                  } else if (cardNumber.text.length < 19) {
                    errorMessage("El número de la tarjeta esta incompleto.");
                  } else if (cardDate.text.length < 5) {
                    errorMessage("La fecha valida esta incompleta.");
                  } else if (cardCVV.text.length < 3) {
                    errorMessage("El CVV esta incompleto.");
                  } else {
                    newSubscription();
                  }
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ],
    );
  }

  newSubscription() async {
    setState(() {
      subscriptionValidationProcess = true;
    });
    //Split card number
    var number = cardNumber.text.split(" ");
    String numberSplit = number[0] + number[1] + number[2] + number[3];
    //Split card date
    var date = cardDate.text.split("/");
    String month = date[0];
    String year = date[1];

    //create subscription
    final result = await token.queryAllRows();
    final auth = result[0]["Auth"];
    final response = await business.newSubscription(
        numberSplit, month, year, cardCVV.text.toString(), auth);

    if (response[0] == "400") {
      if (response[2] == "Your card number is incorrect.") {
        errorMessage("El número de la tarjeta es incorrecto.");
      } else if (response[2] == "Your card's expiration year is invalid.") {
        errorMessage("Tu tarjeta esta vencida.");
      } else if (response[2] == "Your card's expiration month is invalid.") {
        errorMessage("El mes de la tarjeta es incorrecto.");
      }
    } else if (response[0] == "200") {
      saveBank(auth);
    } else {
      errorMessage("Intentalo otra vez.");
    }
  }

  saveBank(String auth) async {
    final response = await business.newBank(
        bankName, bankType, bankNumber.text, bankHolder.text, auth);

    if (response == true) {
      getBusinessInfo();
      setState(() {
        pages = 0;
      });
    } else {
      errorMessage("Intentalo otra vez.");
    }

    setState(() {
      subscriptionValidationProcess = false;
    });
  }

  errorMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(fontFamily: 'Kanit'),
      ),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ));
  }

//Products section
  Widget product() {
    return ListView.builder(
      itemCount: products.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Productos",
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      child: Icon(
                        Icons.add_box,
                        color: Color.fromRGBO(255, 144, 82, 1),
                      ),
                      onTap: () {
                        setState(() {
                          pages = 3;
                        });
                      },
                    ),
                  )
                ],
              ),
              Divider(),
              products.length == 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Crea un producto presionando "',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: 'Kanit',
                            fontSize: 18,
                          ),
                        ),
                        Icon(
                          Icons.add_box,
                          color: Color.fromRGBO(255, 144, 82, 1),
                        ),
                        Text(' "',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: 'Kanit',
                              fontSize: 18,
                            ))
                      ],
                    )
                  : Container(),
            ],
          );
        } else {
          final productData = products[i - 1];
          return Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(ctx).size.width / 5,
                        height: MediaQuery.of(ctx).size.width / 5,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    productUrl + productData["image"]))),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                      ),
                      Container(
                          width: MediaQuery.of(ctx).size.width / 1.5,
                          height: MediaQuery.of(ctx).size.width / 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(productData["name"],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontFamily: 'Kanit',
                                      )),
                                  Spacer(),
                                  GestureDetector(
                                    child: Icon(
                                      Icons.edit,
                                      color: Color.fromRGBO(255, 144, 82, 1),
                                      size: 18,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        editProductData = productData;
                                        editProductName.text =
                                            editProductData["name"];
                                        editProductPrice.text =
                                            editProductData["price"].toString();
                                        editProductDescription.text =
                                            editProductData["description"];
                                        editProductOnStock.text =
                                            editProductData["on_stock"]
                                                .toString();
                                        editProductImg = null;
                                        pages = 4;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                              ),
                              Row(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Precio",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      Text(productData["price"].toString(),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Cant. D.",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      Text(productData["on_stock"].toString(),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Estado",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      productData["active"] == 1
                                          ? Text("Activo",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 16,
                                                fontFamily: 'Kanit',
                                              ))
                                          : Text("Inactivo",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16,
                                                fontFamily: 'Kanit',
                                              )),
                                    ],
                                  ),
                                  Spacer(),
                                ],
                              )
                            ],
                          )),
                    ],
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }

//new Product
  TextEditingController newProductName = new TextEditingController();
  TextEditingController newProductPrice = new TextEditingController();
  TextEditingController newProductDescription = new TextEditingController();
  TextEditingController newProductOnStock = new TextEditingController();
  File newProductImg = null;

  Widget newProduct() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "Nuevo Producto",
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w800),
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Container(
            height: MediaQuery.of(context).size.height / 2.2,
            child: Card(
              child: Container(
                height: MediaQuery.of(context).size.height / 2.2,
                decoration: newProductImg != null
                    ? BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(
                              newProductImg,
                            ),
                            fit: BoxFit.cover),
                      )
                    : BoxDecoration(),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    newProductImg == null
                        ? GestureDetector(
                            child: Icon(
                              Icons.add_a_photo,
                              color: Color.fromRGBO(255, 144, 82, 1),
                              size: 30,
                            ),
                            onTap: () {
                              addNewProductImage();
                            },
                          )
                        : Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: GestureDetector(
                                child: Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.edit,
                                    color: Color.fromRGBO(255, 144, 82, 1),
                                  ),
                                ),
                                onTap: () {
                                  addNewProductImage();
                                },
                              ),
                            ),
                          ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          color: Colors.white70,
                          child: ListTile(
                            leading: Text(
                                newProductName.text.isEmpty
                                    ? "Nombre"
                                    : newProductName.text,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                )),
                            trailing: Text(
                                newProductPrice.text.isEmpty
                                    ? "Precio"
                                    : "\$" + newProductPrice.text,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                )),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: TextFormField(
                      maxLength: 20,
                      controller: newProductName,
                      onChanged: (text) {
                        setState(() {});
                      },
                      style: TextStyle(fontFamily: 'Kanit'),
                      decoration: InputDecoration(
                          hintText: "Nombre",
                          hintStyle: TextStyle(fontFamily: 'Kanit'),
                          counterText: ""),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    child: TextFormField(
                      maxLength: 4,
                      controller: newProductPrice,
                      onChanged: (text) {
                        setState(() {});
                      },
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontFamily: 'Kanit'),
                      decoration: InputDecoration(
                          hintText: "Precio",
                          hintStyle: TextStyle(fontFamily: 'Kanit'),
                          counterText: ""),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width / 8,
                    child: TextFormField(
                      maxLength: 2,
                      controller: newProductOnStock,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontFamily: 'Kanit'),
                      decoration: InputDecoration(
                          hintText: "Cant.",
                          hintStyle: TextStyle(fontFamily: 'Kanit'),
                          counterText: ""),
                    ),
                  ),
                ],
              ),
              TextFormField(
                maxLength: 100,
                controller: newProductDescription,
                style: TextStyle(fontFamily: 'Kanit'),
                decoration: InputDecoration(
                    hintText: "Descripción (opcional)",
                    hintStyle: TextStyle(fontFamily: 'Kanit'),
                    counterText: ""),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              newProductProcess == false
                  ? GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 14,
                        child: Center(
                          child: Card(
                            color: Color.fromRGBO(255, 144, 82, 1),
                            child: Center(
                              child: Text(
                                'Crear',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.width / 19),
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        createNewProduct();
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    )
            ],
          ),
        )
      ],
    );
  }

  bool newProductProcess = false;
  addNewProductImage() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        newProductImg = img;
      });
    } else {
      errorMessage("No se ha seleccionado ninguna foto.");
    }
  }

  createNewProduct() {
    if (newProductName.text.isEmpty) {
      errorMessage("El producto debe llevar un nombre.");
    } else if (newProductPrice.text.isEmpty) {
      errorMessage("El producto debe llevar un precio.");
    } else if (newProductOnStock.text.isEmpty) {
      errorMessage("El producto debe tener una cantidad disponible.");
    } else if (newProductImg == null) {
      errorMessage("El producto debe tener un foto.");
    } else {
      setState(() {
        newProductProcess = true;
      });
      saveProduct();
    }
  }

  saveProduct() async {
    await CompressImage.compress(
        imageSrc: newProductImg.path, desiredQuality: 85);

    String bs64ProductImg = base64Encode(newProductImg.readAsBytesSync());

    final tokenData = await token.queryAllRows();

    final result =
        await business.uploadProductImage(bs64ProductImg, tokenData[0]["Auth"]);

    if (result[0] == 404) {
      errorMessage("Intentalo otra vez.");
    } else {
      final productResult = await business.newProduct(
          newProductName.text,
          newProductPrice.text,
          newProductOnStock.text,
          newProductDescription.text,
          result[2],
          tokenData[0]["Auth"]);

      if (productResult[0] == 200) {
        getBusinessInfo();
        setState(() {
          newProductProcess = false;
          pages = 2;
          newProductName.text = "";
          newProductPrice.text = "";
          newProductOnStock.text = "";
          newProductDescription.text = "";
          newProductImg = null;
        });
      } else {
        errorMessage("Intentalo otra vez.");
      }
    }

    setState(() {
      newProductProcess = false;
    });
  }

  //Edit product
  TextEditingController editProductName = new TextEditingController();
  TextEditingController editProductPrice = new TextEditingController();
  TextEditingController editProductDescription = new TextEditingController();
  TextEditingController editProductOnStock = new TextEditingController();
  File editProductImg = null;

  var editProductData;

  Widget editProduct() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Editar Producto",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w800),
              ),
            ),
            Spacer(),
            Text(
              "Estado",
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 18,
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w800),
            ),
            Switch(
              onChanged: (value) {
                if (!value) {
                  setState(() {
                    editProductData["active"] = 0;
                  });
                } else {
                  setState(() {
                    editProductData["active"] = 1;
                  });
                }
                print(editProductData["active"]);
              },
              value: editProductData["active"] == 0 ? false : true,
            ),
          ],
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Container(
            height: MediaQuery.of(context).size.height / 2.2,
            child: Card(
              child: Container(
                height: MediaQuery.of(context).size.height / 2.2,
                decoration: editProductData != null
                    ? BoxDecoration(
                        image: DecorationImage(
                            image: editProductImg == null
                                ? NetworkImage(
                                    productUrl + editProductData["image"],
                                  )
                                : FileImage(editProductImg),
                            fit: BoxFit.cover),
                      )
                    : BoxDecoration(),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: GestureDetector(
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.edit,
                              color: Color.fromRGBO(255, 144, 82, 1),
                            ),
                          ),
                          onTap: () {
                            editProductImage();
                          },
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          color: Colors.white70,
                          child: ListTile(
                            leading: Text(
                                editProductName.text.isEmpty
                                    ? "Nombre"
                                    : editProductName.text,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                )),
                            trailing: Text(
                                editProductPrice.text.isEmpty
                                    ? "Precio"
                                    : "\$" + editProductPrice.text,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                )),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 2.5,
                    child: TextFormField(
                      maxLength: 20,
                      controller: editProductName,
                      onChanged: (text) {
                        setState(() {});
                      },
                      style: TextStyle(fontFamily: 'Kanit'),
                      decoration: InputDecoration(
                          hintText: "Nombre",
                          hintStyle: TextStyle(fontFamily: 'Kanit'),
                          counterText: ""),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    child: TextFormField(
                      maxLength: 4,
                      controller: editProductPrice,
                      onChanged: (text) {
                        setState(() {});
                      },
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontFamily: 'Kanit'),
                      decoration: InputDecoration(
                          hintText: "Precio",
                          hintStyle: TextStyle(fontFamily: 'Kanit'),
                          counterText: ""),
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width / 8,
                    child: TextFormField(
                      maxLength: 2,
                      controller: editProductOnStock,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontFamily: 'Kanit'),
                      decoration: InputDecoration(
                          hintText: "Cant.",
                          hintStyle: TextStyle(fontFamily: 'Kanit'),
                          counterText: ""),
                    ),
                  ),
                ],
              ),
              TextFormField(
                maxLength: 100,
                controller: editProductDescription,
                style: TextStyle(fontFamily: 'Kanit'),
                decoration: InputDecoration(
                    hintText: "Descripción (opcional)",
                    hintStyle: TextStyle(fontFamily: 'Kanit'),
                    counterText: ""),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              newProductProcess == false
                  ? GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 14,
                        child: Center(
                          child: Card(
                            color: Color.fromRGBO(255, 144, 82, 1),
                            child: Center(
                              child: Text(
                                'Guardar Cambios',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.width / 19),
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        validateEditedProduct();
                      },
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    )
            ],
          ),
        )
      ],
    );
  }

  editProductImage() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        editProductImg = img;
      });
    } else {
      errorMessage("No se ha seleccionado ninguna foto.");
    }
  }

  validateEditedProduct() {
    if (editProductName.text.isEmpty) {
      errorMessage("El producto debe llevar un nombre.");
    } else if (editProductPrice.text.isEmpty) {
      errorMessage("El producto debe llevar un precio.");
    } else if (editProductOnStock.text.isEmpty) {
      errorMessage("El producto debe tener una cantidad disponible.");
    } else {
      setState(() {
        newProductProcess = true;
      });
      saveEditedProduct();
    }
  }

  saveEditedProduct() async {
    final tokenData = await token.queryAllRows();

    if (editProductImg != null) {
      await CompressImage.compress(
          imageSrc: editProductImg.path, desiredQuality: 85);

      String bs64ProductImg = base64Encode(editProductImg.readAsBytesSync());

      final result = await business.uploadProductImage(
          bs64ProductImg, tokenData[0]["Auth"]);

      if (result[0] == 404) {
        errorMessage("Intentalo otra vez.");
      } else {
        final productResult = await business.editProduct(
            editProductData["id"],
            editProductName.text,
            editProductPrice.text,
            editProductOnStock.text,
            editProductDescription.text,
            result[2],
            editProductData["active"].toString(),
            tokenData[0]["Auth"],
            );

        if (productResult[0] == 200) {
          getBusinessInfo();
          setState(() {
            newProductProcess = false;
            pages = 2;
            editProductName.text = "";
            editProductPrice.text = "";
            editProductOnStock.text = "";
            editProductDescription.text = "";
            editProductImg = null;
            editProductData = null;
          });
        } else {
          errorMessage("Intentalo otra vez.");
        }
      }
    } else {

       final productResult = await business.editProduct(
            editProductData["id"],
            editProductName.text,
            editProductPrice.text,
            editProductOnStock.text,
            editProductDescription.text,
            editProductData["image"],
            editProductData["active"].toString(),
            tokenData[0]["Auth"]);

        if (productResult[0] == 200) {
          getBusinessInfo();
          setState(() {
            newProductProcess = false;
            pages = 2;
            editProductName.text = "";
            editProductPrice.text = "";
            editProductOnStock.text = "";
            editProductDescription.text = "";
            editProductImg = null;
            editProductData = null;
          });
        } else {
          errorMessage("Intentalo otra vez.");
        }
    }

    setState(() {
      newProductProcess = false;
    });
  }
}
