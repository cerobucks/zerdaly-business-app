import 'dart:convert';
import 'dart:io';

import 'package:compressimage/compressimage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

    getNotificationToken();
  }

  final FirebaseMessaging _fcm = FirebaseMessaging();

  getNotificationToken() async {
    String fcmToken = await _fcm.getToken();

    if (businessInfo["notification_token"] == null) {
      var data = json.encode({
        'notification_token': fcmToken,
      });

      final auth = await token.queryAllRows();

      await business.update(data, auth[0]['Auth']);
    } else if (fcmToken != businessInfo["notification_token"]) {
      var data = json.encode({
        'notification_token': fcmToken,
      });

      final auth = await token.queryAllRows();

      await business.update(data, auth[0]['Auth']);
    }
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
                    child: businessInfo != null
                        ? businessInfo["image"] == null
                            ? Icon(
                                Icons.store,
                                color: Colors.grey,
                                size: 40.0,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(businessUrl +
                                            businessInfo["image"]))),
                              )
                        : Icon(
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
                  onTap: () {
                    setState(() {
                      pages = 5;
                    });
                    Navigator.of(context).pop();
                  },
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
                  onTap: () {
                    setState(() {
                      pages = 7;
                    });
                    Navigator.of(context).pop();
                  },
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
                  onTap: () {
                    setState(() {
                      pages = 8;
                    });
                    getSubscription();
                    Navigator.of(context).pop();
                  },
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
      case 5:
        return ordersList();
      case 6:
        return orderDetails();
      case 7:
        return earnings();
      case 8:
        return profile();
      case 9:
        return updateProfile();
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
                  child: GestureDetector(
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
                                            MediaQuery.of(context).size.width /
                                                6,
                                        color: Colors.grey[600]),
                                  )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          pages = 5;
                        });
                      }),
                )),
            Spacer(),
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  height: MediaQuery.of(context).size.height / 4.1,
                  child: GestureDetector(
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
                    onTap: () {
                      setState(() {
                        pages = 2;
                      });
                    },
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
                  child: GestureDetector(
                    child: GestureDetector(
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
                                            MediaQuery.of(context).size.width /
                                                12,
                                        color: Colors.grey[600]),
                                  )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          pages = 7;
                        });
                      },
                    ),
                  )),
            ),
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
                  child: GestureDetector(
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
                                          MediaQuery.of(context).size.width /
                                              12,
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
                    onTap: () {
                      getSubscription();
                      setState(() {
                        pages = 8;
                      });
                    },
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

    if (orders != null) {
      for (var i = 0; i < orders.length - 1; i++) {
        if (orders[i]["delivery_id"] != null) {
          count++;
        }
      }
    }else{
      return 0.toString();
    }

    return count.toString();
  }

  String incomeAmountText() {
    int amount = 0;
    var now = DateTime.now().toString();
    var split = now.split("-");
    String weekYear = split[0] + "-" + Jiffy().week.toString();
    print(sales);

    if (sales[weekYear] != null) {
      for (var i = 0; i < sales[weekYear].length; i++) {
        amount += sales[weekYear][i]["business_total"];
      }
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

  successMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(fontFamily: 'Kanit'),
      ),
      backgroundColor: Colors.green,
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
          imageCache.clear();
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
        imageCache.clear();
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

// Orders
  Widget ordersList() {
    return ListView.builder(
      itemCount: orders.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Ventas",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w800),
                ),
              ),
              Divider(),
              orders.length == 0
                  ? Center(
                      child: Text(
                        'Aún no has generado tu primera venta.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: 'Kanit',
                          fontSize: 18,
                        ),
                      ),
                    )
                  : Container(
                      child: Row(
                        children: <Widget>[
                          Spacer(),
                          Text(
                            'No enviado ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: 'Kanit',
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                          ),
                          Spacer(),
                          Text(
                            'Enviado ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: 'Kanit',
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                color: Colors.orange, shape: BoxShape.circle),
                          ),
                          Spacer(),
                          Text(
                            'Completado ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontFamily: 'Kanit',
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
            ],
          );
        } else {
          final orderData = orders[i - 1];
          final orderProducts = json.decode(orderData["products_id"]);

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
                                    productUrl + orderProducts[0]["image"]))),
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
                                  Text(
                                      orderProducts.length == 1
                                          ? orderProducts[0]["name"]
                                          : orderProducts[0]["name"] +
                                              " y otros...",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontFamily: 'Kanit',
                                      )),
                                  Spacer(),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                        color: orderData["delivery_id"] == null
                                            ? Colors.red
                                            : orderData["shipping_status"] == 5
                                                ? Colors.green
                                                : Colors.orange,
                                        shape: BoxShape.circle),
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
                                      Text("Total",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      Text(
                                          orderData["products_total"]
                                              .toString(),
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
                                      Text("Cant.",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      Text(orderProducts.length.toString(),
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
                                      Text("Detalles",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      GestureDetector(
                                        child: Text("Ver más",
                                            style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 16,
                                              fontFamily: 'Kanit',
                                            )),
                                        onTap: () {
                                          setState(() {
                                            userDetails = null;
                                            shippingDelivery = null;
                                            deliveriesAvailable = null;
                                            orderDetailsData = orderData;
                                            orderProductsDetails =
                                                orderProducts;
                                            getUser(orderData["user_id"]);
                                            pages = 6;
                                          });

                                          if (orderDetailsData["delivery_id"] !=
                                              null) {
                                            getDelivery(orderDetailsData[
                                                "delivery_id"]);
                                          } else {
                                            getDeliveriesAvailible();
                                          }
                                        },
                                      ),
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

//Order Details
  var orderDetailsData;
  var orderProductsDetails;
  var userDetails;
  var deliveriesAvailable;
  var shippingDelivery;
  //1 = user info, 2 = products details, 3 = contact delivery or delivery status.
  Widget orderDetails() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (ctx, i) {
        return orderDetailsPages(i);
      },
    );
  }

  Widget orderDetailsPages(int i) {
    switch (i) {
      case 0:
        return orderDetailsPage();
      case 1:
        return productsDetailsPage();
      case 2:
        return contactDeliveryPage();
    }

    return Container();
  }

  Widget orderDetailsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text(
            "Detalles del Pedido",
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w800),
          ),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.only(left: 5, top: 5),
          child: Text(
            "Cliente",
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w800),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Card(
              child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Nombre",
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w800),
                        ),
                        Text(
                            userDetails == null
                                ? " "
                                : userDetails[0]["name"] +
                                    " " +
                                    userDetails[0]["lastname"],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontFamily: 'Kanit',
                            )),
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Teléfono",
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w800),
                        ),
                        Text(
                            userDetails == null ? " " : userDetails[0]["phone"],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontFamily: 'Kanit',
                            )),
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Fecha",
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w800),
                        ),
                        Text(userDateOfPurchase(orderDetailsData["created_at"]),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontFamily: 'Kanit',
                            )),
                      ],
                    )
                  ],
                ),
              ],
            ),
          )),
        ),
      ],
    );
  }

  getUser(int id) async {
    final tokenData = await token.queryAllRows();
    final response = await business.getUser(id, tokenData[0]["Auth"]);
    setState(() {
      userDetails = response[2];
    });
  }

  String userDateOfPurchase(String date) {
    final dateSplit = date.split("-");
    final daySlit = dateSplit[2].split(" ");

    return daySlit[0] + "/" + dateSplit[1] + "/" + dateSplit[0];
  }

  Widget productsDetailsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 5, top: 5),
          child: Text(
            orderProductsDetails.length == 1 ? "Producto" : "Productos",
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w800),
          ),
        ),
        ListView.builder(
          itemCount: orderProductsDetails.length,
          shrinkWrap: true,
          itemBuilder: (ctx, i) {
            final productDetails = orderProductsDetails[i];

            return Card(
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(ctx).size.width / 7,
                          height: MediaQuery.of(ctx).size.width / 7,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      productUrl + productDetails["image"]))),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                        ),
                        Container(
                            width: MediaQuery.of(ctx).size.width / 1.3,
                            height: MediaQuery.of(ctx).size.width / 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 5),
                                ),
                                Row(
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Nombre",
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                                fontFamily: 'Kanit',
                                                fontWeight: FontWeight.w800)),
                                        Text(productDetails["name"].toString(),
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
                                        Text("Cant.",
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                                fontFamily: 'Kanit',
                                                fontWeight: FontWeight.w800)),
                                        Text(1.toString(),
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
                                        Text("Precio",
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                                fontFamily: 'Kanit',
                                                fontWeight: FontWeight.w800)),
                                        Text(
                                            "\$" +
                                                productDetails["price"]
                                                    .toString(),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                              fontFamily: 'Kanit',
                                            ))
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Divider(),
        Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Spacer(),
                          Text("Sub total",
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w800)),
                          Spacer(),
                          Text(
                              "\$" +
                                  orderDetailsData["products_total"].toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontFamily: 'Kanit',
                              )),
                          Spacer()
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Spacer(),
                          Text("4.9% + \$15",
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w800)),
                          Spacer(),
                          Text(
                              "-\$" +
                                  ((orderDetailsData["products_total"] *
                                              0.049) +
                                          15)
                                      .toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontFamily: 'Kanit',
                              )),
                          Spacer()
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Spacer(),
                          Text("Total",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 16,
                                  fontFamily: 'Kanit',
                                  fontWeight: FontWeight.w800)),
                          Spacer(),
                          Text(
                              "\$" +
                                  (orderDetailsData["products_total"] -
                                          ((orderDetailsData["products_total"] *
                                                  0.049) +
                                              15))
                                      .toString(),
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 16,
                                fontFamily: 'Kanit',
                              )),
                          Spacer()
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget contactDeliveryPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 5, top: 5),
          child: Text(
            "Envío",
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w800),
          ),
        ),
        Divider(),
        orderDetailsData["delivery_id"] == null
            ? contactDelivery()
            : shippingDetails()
      ],
    );
  }

  Widget contactDelivery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: 5,
          ),
          child: Text(
            "Contacta un delivery",
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w800),
          ),
        ),
        deliveriesAvailable == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: deliveriesAvailable.length > 6
                    ? 6
                    : deliveriesAvailable.length,
                shrinkWrap: true,
                itemBuilder: (ctx, i) {
                  final delivery = deliveriesAvailable[i];

                  return Container(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 9.5,
                      child: Card(
                          child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Nombre",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                        delivery["name"] +
                                            " " +
                                            delivery["lastname"],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontFamily: 'Kanit',
                                        )),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Teléfono",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w800),
                                    ),
                                    Text(delivery["phone"],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontFamily: 'Kanit',
                                        )),
                                  ],
                                ),
                                Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Acción",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w800),
                                    ),
                                    GestureDetector(
                                      child: Text("Contactar",
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      onTap: () {
                                        contactNotificationDelivery(
                                            delivery["id"],
                                            orderDetailsData["id"]);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      )),
                    ),
                  );
                },
              ),
      ],
    );
  }

  getDelivery(int id) async {
    final tokenData = await token.queryAllRows();
    final response = await business.getDelivery(id, tokenData[0]["Auth"]);
    setState(() {
      shippingDelivery = response[2];
    });
  }

  getDeliveriesAvailible() async {
    final auth = await token.queryAllRows();
    final deliveries = await business.getDeliveriesAvailible(auth[0]["Auth"]);
    setState(() {
      deliveriesAvailable = deliveries[2];
    });
  }

  contactNotificationDelivery(int deliveryId, int orderId) async {
    final auth = await token.queryAllRows();

    final response = await business.contactDeliveryAvailible(
        deliveryId, orderId, auth[0]["Auth"]);
    print(response);
    if (response[0] == '200') {
      successMessage(response[2].toString());
    } else {
      errorMessage(response[2].toString());
    }
  }

  Widget shippingDetails() {
    return Container(
      child: shippingDelivery == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                        child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Delivery",
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                      shippingDelivery[0]["name"] +
                                          " " +
                                          shippingDelivery[0]["lastname"],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontFamily: 'Kanit',
                                      )),
                                ],
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Teléfono",
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(shippingDelivery[0]["phone"],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontFamily: 'Kanit',
                                      )),
                                ],
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Fecha",
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                      userDateOfPurchase(
                                          orderDetailsData["updated_at"]),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontFamily: 'Kanit',
                                      )),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "Estado del envío: ",
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w800),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    shippingStatusText(orderDetailsData["shipping_status"]),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 10,
                  ),
                )
              ],
            ),
    );
  }

  Text shippingStatusText(int id) {
    switch (id) {
      case 0:
        return Text(
          "No enviado.",
          style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w800),
          textAlign: TextAlign.left,
        );
      case 1:
        return Text(
          "En camino al negocio.",
          style: TextStyle(
              color: Colors.yellow[700],
              fontSize: 18,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w800),
          textAlign: TextAlign.left,
        );
      case 2:
        return Text(
          "Llego al negocio.",
          style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w800),
          textAlign: TextAlign.left,
        );
      case 3:
        return Text(
          "De camino al cliente.",
          style: TextStyle(
              color: Colors.yellow[700],
              fontSize: 18,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w800),
          textAlign: TextAlign.left,
        );
      case 4:
        return Text(
          "Llego donde el cliente.",
          style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w800),
          textAlign: TextAlign.left,
        );
      case 5:
        return Text(
          "Completado.",
          style: TextStyle(
              color: Colors.green,
              fontSize: 18,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w800),
          textAlign: TextAlign.left,
        );
    }

    return Text(
      "",
      style: TextStyle(
          color: Colors.grey[600],
          fontSize: 18,
          fontFamily: 'Kanit',
          fontWeight: FontWeight.w800),
      textAlign: TextAlign.left,
    );
  }

  //earnings
  Widget earnings() {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (ctx, i) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                top: 10,
              ),
              child: Text(
                "Ganancias",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w800),
              ),
            ),
            Divider(),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                color: Color.fromRGBO(255, 144, 82, 1),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                    ),
                    Text(
                      "Esta semana (" + Jiffy().week.toString() + ")",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w800),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Divider(
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "En ventas",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontFamily: 'Kanit',
                              ),
                            ),
                            Text(
                              incomeAmountText(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Transacciones",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontFamily: 'Kanit',
                              ),
                            ),
                            Text(
                              incomeAmountTransactionsText(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Divider(),
            ListView.builder(
              itemCount: sales.length - 1,
              shrinkWrap: true,
              itemBuilder: (ctx, i) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 5, left: 10),
                          child: Text(
                            i == 0
                                ? "Semana pasada (" +
                                    (Jiffy().week - (i + 1)).toString() +
                                    ")"
                                : "Semana (" +
                                    (Jiffy().week - (i + 1)).toString() +
                                    ")",
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Divider(
                            color: Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "En ventas",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 17,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                                Text(
                                  incomeAmountPerWeekText(i),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 35,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Transacciones",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 17,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                                Text(
                                  incomeAmountTransactionsPerWeekText(i),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 35,
                                    fontFamily: 'Kanit',
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            i == 0
                                ? "Será depositado el viernes de esta semana."
                                : "Depositado el viernes de la semana (" +
                                    (Jiffy().week - i).toString() +
                                    ")",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 17,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String incomeAmountTransactionsText() {
    var now = DateTime.now().toString();
    var split = now.split("-");

    String weekYear = split[0] + "-" + Jiffy().week.toString();

    if (sales[weekYear] != null) {
      return sales[weekYear].length.toString();
    }

    return 0.toString();
  }

  String incomeAmountPerWeekText(int i) {
    int amount = 0;
    var now = DateTime.now().toString();
    var split = now.split("-");
    String weekYear = split[0] + "-" + (Jiffy().week - (i + 1)).toString();

    for (var i = 0; i < sales[weekYear].length; i++) {
      amount += sales[weekYear][i]["business_total"];
    }

    return "\$" + amount.toString();
  }

  String incomeAmountTransactionsPerWeekText(int i) {
    var now = DateTime.now().toString();
    var split = now.split("-");
    String weekYear = split[0] + "-" + (Jiffy().week - (i + 1)).toString();

    return sales[weekYear].length.toString();
  }

  final businessUrl = "https://api.zerdaly.com/api/business/getimage/";

  //subscription
  Widget profile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: Color.fromRGBO(255, 144, 82, 1),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10, bottom: 20),
                child: Text(
                  "Mi cuenta",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.left,
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    height: MediaQuery.of(context).size.height / 9,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: businessInfo["image"] != null
                        ? Container(
                            margin: EdgeInsets.only(left: 8, right: 8),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        businessUrl + businessInfo["image"]))))
                        : Container(
                            child: Center(
                              child: Icon(Icons.store,
                                  color: Color.fromRGBO(255, 144, 82, 1)),
                            ),
                          ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Hola,",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Kanit',
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        businessInfo["owner_name"],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Kanit',
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 10,
                      height: MediaQuery.of(context).size.height / 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        ownerName.text = businessInfo["owner_name"];
                        businessName.text = businessInfo["business_name"];
                        businessEmail.text = businessInfo["email"];
                        ownerPhone.text = businessInfo["phone"];
                        businessImg = null;
                        pages = 9;
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, top: 10),
          child: Text(
            "Suscripción",
            style: TextStyle(
                color: Color.fromRGBO(255, 144, 82, 1),
                fontSize: 20,
                fontFamily: 'Kanit',
                fontWeight: FontWeight.w800),
            textAlign: TextAlign.left,
          ),
        ),
        Divider(),
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
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 10,
                        child: Card(
                          child: Padding(
                              padding: EdgeInsets.all(5),
                              child: subscription != null
                                  ? subscription["status"] == "trialing"
                                      ? Row(
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "Estado",
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 16,
                                                      fontFamily: 'Kanit',
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                                Text("En Prueba",
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 16,
                                                        fontFamily: 'Kanit')),
                                              ],
                                            ),
                                            Spacer(),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "Comenzó",
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 16,
                                                      fontFamily: 'Kanit',
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                                Text(
                                                    subscription["trial_start"]
                                                        .toString(),
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
                                                Text(
                                                  "Termina",
                                                  style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 16,
                                                      fontFamily: 'Kanit',
                                                      fontWeight:
                                                          FontWeight.w800),
                                                ),
                                                Text(
                                                    subscription["trial_end"]
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 16,
                                                      fontFamily: 'Kanit',
                                                    )),
                                              ],
                                            )
                                          ],
                                        )
                                      : subscription["status"] == "active"
                                          ? Row(
                                              children: <Widget>[
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      "Estado",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 16,
                                                          fontFamily: 'Kanit',
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    Text("Activa",
                                                        style: TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Kanit')),
                                                  ],
                                                ),
                                                Spacer(),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      "Comenzó",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 16,
                                                          fontFamily: 'Kanit',
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    Text(
                                                        subscription["start_at"]
                                                            .toString(),
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
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
                                                    Text(
                                                      "Termina",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 16,
                                                          fontFamily: 'Kanit',
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    Text(
                                                        subscription["end_at"]
                                                            .toString(),
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 16,
                                                          fontFamily: 'Kanit',
                                                        )),
                                                  ],
                                                )
                                              ],
                                            )
                                          : Row(
                                              children: <Widget>[
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      "Estado",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 16,
                                                          fontFamily: 'Kanit',
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    Text("No Activa",
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Kanit')),
                                                  ],
                                                ),
                                                Spacer(),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      "Comenzó",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 16,
                                                          fontFamily: 'Kanit',
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    Text(
                                                        subscription["start_at"]
                                                            .toString(),
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
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
                                                    Text(
                                                      "Termina",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 16,
                                                          fontFamily: 'Kanit',
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    Text(
                                                        subscription["end_at"]
                                                            .toString(),
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 16,
                                                          fontFamily: 'Kanit',
                                                        )),
                                                  ],
                                                )
                                              ],
                                            )
                                  : Center(
                                      child: CircularProgressIndicator(),
                                    )),
                        ),
                      ),
                      businessInfo["validated"] == 1
                          ? businessInfo["status"] == 1
                              ? GestureDetector(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Card(
                                      color: Colors.red,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Center(
                                          child: Text("Cancelar Suscripción",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: 'Kanit',
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    cancelSubscription(context);
                                  })
                              : GestureDetector(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Card(
                                      color: Colors.green,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Center(
                                          child: Text("Activar Suscripción",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: 'Kanit',
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    nenewSubscription(context);
                                  })
                          : Container()
                    ],
                  )
            : Container(),
      ],
    );
  }

  cancelSubscription(BuildContext context) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("¿Éstas seguro?",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontFamily: 'Kanit',
                    )),
                Text("Quiero cancelar la subscripcion",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 17,
                      fontFamily: 'Kanit',
                    )),
                Padding(
                    padding: EdgeInsets.only(
                  top: 10,
                )),
                Row(
                  children: <Widget>[
                    Spacer(),
                    GestureDetector(
                      child: Text("No",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontFamily: 'Kanit',
                          )),
                      onTap: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    Spacer(),
                    GestureDetector(
                      child: Text("Si",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontFamily: 'Kanit',
                          )),
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final auth = await token.queryAllRows();
                        final response =
                            await business.cancelSubsctiption(auth[0]["Auth"]);
                        if (response[0] == "200") {
                          getBusinessInfo();
                          getSubscription();
                          successMessage(response[2]);
                        } else {
                          errorMessage(response[2]);
                        }
                      },
                    ),
                    Spacer(),
                  ],
                )
              ],
            ),
          );
        });
  }

  nenewSubscription(BuildContext context) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("¿Éstas seguro?",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontFamily: 'Kanit',
                    )),
                Text("Al renovar pagaras \$499/mes.",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 17,
                      fontFamily: 'Kanit',
                    )),
                Padding(
                    padding: EdgeInsets.only(
                  top: 10,
                )),
                Row(
                  children: <Widget>[
                    Spacer(),
                    GestureDetector(
                      child: Text("No",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontFamily: 'Kanit',
                          )),
                      onTap: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    Spacer(),
                    GestureDetector(
                      child: Text("De acuerdo",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontFamily: 'Kanit',
                          )),
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final auth = await token.queryAllRows();
                        final response =
                            await business.renewSubsctiption(auth[0]["Auth"]);
                        if (response[0] == "200") {
                          getBusinessInfo();
                          getSubscription();
                          successMessage(response[2]);
                        } else {
                          errorMessage(response[2]);
                        }
                      },
                    ),
                    Spacer(),
                  ],
                )
              ],
            ),
          );
        });
  }

  var subscription;

  getSubscription() async {
    final auth = await token.queryAllRows();
    final response = await business.getSubsctiption(auth[0]["Auth"]);

    setState(() {
      subscription = response[2];
    });
  }

  //update business image, info, etc.
  TextEditingController ownerName = new TextEditingController();
  TextEditingController businessName = new TextEditingController();
  TextEditingController businessEmail = new TextEditingController();
  TextEditingController ownerPhone = new TextEditingController();
  File businessImg;

  Widget updateProfile() {
    return ListView(
      children: <Widget>[
        Container(
          color: Color.fromRGBO(255, 144, 82, 1),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10, bottom: 20),
                    child: Text(
                      "Editar cuenta",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w800),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10, top: 10, bottom: 20),
                      child: Text(
                        "Guardar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Kanit',
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    onTap: () {
                      if (ownerName.text.length < 6) {
                        errorMessage("Tu nombre debe tener la menos 6 letras.");
                      } else {
                        saveProfileChanges();
                      }
                    },
                  ),
                ],
              ),
              Center(
                child: Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.height / 6,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: businessImg == null
                        ? businessInfo["image"] != null
                            ? Container(
                                margin: EdgeInsets.only(left: 6, right: 6),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(businessUrl +
                                            businessInfo["image"]))),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    GestureDetector(
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                9,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                17,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[600]),
                                            child: Icon(Icons.add_a_photo,
                                                color: Colors.white),
                                          ),
                                        ),
                                        onTap: () {
                                          getProfilePicture();
                                        })
                                  ],
                                ),
                              )
                            : Container(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    Center(
                                      child: Icon(Icons.store,
                                          size: 35,
                                          color:
                                              Color.fromRGBO(255, 144, 82, 1)),
                                    ),
                                    GestureDetector(
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                9,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                17,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[600]),
                                            child: Icon(Icons.add_a_photo,
                                                color: Colors.white),
                                          ),
                                        ),
                                        onTap: () {
                                          getProfilePicture();
                                        })
                                  ],
                                ),
                              )
                        : Container(
                            margin: EdgeInsets.only(left: 7, right: 7),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(businessImg),
                                )),
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                GestureDetector(
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                9,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                17,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[600]),
                                        child: Icon(Icons.add_a_photo,
                                            color: Colors.white),
                                      ),
                                    ),
                                    onTap: () {
                                      getProfilePicture();
                                    })
                              ],
                            ))),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Nombre',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: MediaQuery.of(context).size.width / 20,
                  fontFamily: 'Kanit',
                ),
              ),
              TextField(
                controller: ownerName,
                decoration: InputDecoration(
                  hintText: 'Tu nombre',
                  hintStyle: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width / 21,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Text(
                'Nombre del negocio',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: MediaQuery.of(context).size.width / 20,
                  fontFamily: 'Kanit',
                ),
              ),
              TextField(
                controller: businessName,
                decoration: InputDecoration(
                  hintText: 'Negocio',
                  hintStyle: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width / 21,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Text(
                'Email',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: MediaQuery.of(context).size.width / 20,
                  fontFamily: 'Kanit',
                ),
              ),
              TextField(
                controller: businessEmail,
                decoration: InputDecoration(
                  hintText: 'Tu email',
                  hintStyle: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width / 21,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Text(
                'Número de teléfono',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: MediaQuery.of(context).size.width / 20,
                  fontFamily: 'Kanit',
                ),
              ),
              TextField(
                controller: ownerPhone,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                  hintText: '8095394444',
                  hintStyle: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: MediaQuery.of(context).size.width / 21,
                  ),
                  counterText: "",
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  getProfilePicture() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        businessImg = img;
      });
    } else {
      errorMessage("No se ha seleccionado ninguna foto.");
    }
  }

  saveProfileChanges() async {
    final auth = await token.queryAllRows();

    if (businessImg != null) {
      await CompressImage.compress(
          imageSrc: businessImg.path, desiredQuality: 85);

      String businessImgBs64 = base64Encode(businessImg.readAsBytesSync());
      final response =
          await business.uploadBusinessImage(businessImgBs64, auth[0]["Auth"]);

      if (response[0] == 200) {
        if (businessName.text == businessInfo["business_name"] &&
            businessEmail.text == businessInfo["email"]) {
          updateBusiness(
              json.encode({
                'owner_name': ownerName.text,
                'phone': ownerPhone.text,
                'image': response[2],
              }),
              auth[0]["Auth"]);
        } else if (businessName.text == businessInfo["business_name"]) {
          updateBusiness(
              json.encode({
                'owner_name': ownerName.text,
                'phone': ownerPhone.text,
                'image': response[2],
                'email': businessEmail.text
              }),
              auth[0]["Auth"]);
        } else if (businessEmail.text == businessInfo["email"]) {
          updateBusiness(
              json.encode({
                'owner_name': ownerName.text,
                'phone': ownerPhone.text,
                'image': response[2],
                'business_name': businessEmail.text
              }),
              auth[0]["Auth"]);
        } else {
          updateBusiness(
              json.encode({
                'owner_name': ownerName.text,
                'phone': ownerPhone.text,
                'image': response[2],
                'business_name': businessEmail.text,
                'email': businessEmail.text
              }),
              auth[0]["Auth"]);
        }
      } else {
        errorMessage("Ha ocurrido un error, Intentalo otra vez.");
      }
    } else {
      if (businessName.text == businessInfo["business_name"] &&
          businessEmail.text == businessInfo["email"]) {
        updateBusiness(
            json.encode({
              'owner_name': ownerName.text,
              'phone': ownerPhone.text,
            }),
            auth[0]["Auth"]);
      } else if (businessName.text == businessInfo["business_name"]) {
        updateBusiness(
            json.encode({
              'owner_name': ownerName.text,
              'phone': ownerPhone.text,
              'email': businessEmail.text
            }),
            auth[0]["Auth"]);
      } else if (businessEmail.text == businessInfo["email"]) {
        updateBusiness(
            json.encode({
              'owner_name': ownerName.text,
              'phone': ownerPhone.text,
              'business_name': businessName.text
            }),
            auth[0]["Auth"]);
      } else {
        updateBusiness(
            json.encode({
              'owner_name': ownerName.text,
              'phone': ownerPhone.text,
              'business_name': businessName.text,
              'email': businessEmail.text
            }),
            auth[0]["Auth"]);
      }
    }
  }

  updateBusiness(var data, String auth) async {
    final result = await business.update(data, auth);

    if (result[0] == "200") {
      imageCache.clear();
      getBusinessInfo();
      successMessage("Se ha editado correctamente.");
      setState(() {});
    } else if (result[0] == 404) {
      if (result[2]["email"] != null) {
        if (result[2]["email"][0] ==
            "The email must be a valid email address.") {
          errorMessage("Utiliza un email valido.");
        } else if ((result[2]["email"][0] ==
            "The email has already been taken.")) {
          errorMessage("Este email ya esta en uso.");
        }
      } else if (result[2]["business_name"] != null) {
        errorMessage("Este nombre de negocio, ya esta en uso.");
      } else if (result[2]["owner_name"] != null) {
        errorMessage("El nombre solo puede tener letras.");
      } else {
        errorMessage("Ha ocurrido error, Intentalo de nuevo.");
      }
    } else {
      errorMessage("Ha ocurrido error, Intentalo de nuevo.");
    }
  }
}
