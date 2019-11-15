import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as prefix0;
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:zerdaly_business_app/Token.dart';
import 'package:zerdaly_business_app/main.dart';
import 'package:zerdaly_business_app/model/delivery.dart';
import 'package:compressimage/compressimage.dart';

class DeliveryGeneral extends StatefulWidget {
  @override
  DeliveryGeneralState createState() => DeliveryGeneralState();
}

class DeliveryGeneralState extends State<DeliveryGeneral> {
  final token = Token.instance;
  Delivery delivery = new Delivery();
  var deliveryInfo, shippings, orders, contacts, likes;
  int pages = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final deliveryUrl = 'https://api.zerdaly.com/api/delivery/getimage/';

  String bankName = "";
  String bankType = "";
  TextEditingController bankHolder = new TextEditingController();
  TextEditingController bankNumber = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getDeliveryInfo();
  }

  getDeliveryInfo() async {
    final auth = await token.queryAllRows();
    final result = await delivery.info(auth[0]["Auth"]);

    if (result[0] == 200) {
      deliveryInfo = result[1];
      shippings = result[2];
      orders = result[3];
      contacts = result[4];
      likes = result[5];
      setState(() {});
      getNotificationToken();
    }
  }

  final FirebaseMessaging _fcm = FirebaseMessaging();

  getNotificationToken() async {
    String fcmToken = await _fcm.getToken();

    if (deliveryInfo["notification_token"] == null) {
      var data = json.encode({
        'notification_token': fcmToken,
      });

      final auth = await token.queryAllRows();

      await delivery.update(data, auth[0]['Auth']);
    } else if (fcmToken != deliveryInfo["notification_token"]) {
      var data = json.encode({
        'notification_token': fcmToken,
      });

      final auth = await token.queryAllRows();

      await delivery.update(data, auth[0]['Auth']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (pages != 0) {
          getDeliveryInfo();
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
                  child: deliveryInfo != null
                      ? deliveryInfo["image"] == null
                          ? Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 40.0,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(deliveryUrl +
                                          deliveryInfo["image"]))),
                            )
                      : Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 40.0,
                        ),
                ),
                accountName: Text(
                  deliveryInfo != null
                      ? deliveryInfo["name"] + " " + deliveryInfo["lastname"]
                      : "",
                  style: TextStyle(color: Colors.white, fontFamily: 'Kanit'),
                ),
                accountEmail: Text(
                  deliveryInfo != null ? deliveryInfo["email"] : "",
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
                        color: Colors.grey, fontFamily: 'Kanit', fontSize: 18)),
                onTap: () {
                  setState(() {
                    pages = 0;
                  });
                  getDeliveryInfo();

                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                trailing: Icon(
                  Icons.local_shipping,
                  color: Color.fromRGBO(255, 144, 82, 1),
                ),
                title: Text("Envíos",
                    style: TextStyle(
                        color: Colors.grey, fontFamily: 'Kanit', fontSize: 18)),
                onTap: () {
                  setState(() {
                    pages = 2;
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
                        color: Colors.grey, fontFamily: 'Kanit', fontSize: 18)),
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
                        color: Colors.grey, fontFamily: 'Kanit', fontSize: 18)),
                onTap: () {
                  setState(() {
                    deliveryName.text = deliveryInfo["name"];
                    deliveryLastName.text = deliveryInfo["lastname"];
                    deliveryEmail.text = deliveryInfo["email"];
                    deliveryPhone.text = deliveryInfo["phone"];
                    deliveryImg = null;
                    pages = 6;
                  });
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
                        color: Colors.grey, fontFamily: 'Kanit', fontSize: 18)),
                onTap: () async {
                  final id = await token.queryAllRows();
                  await token.delete(id[0]['id']);
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
                        color: Colors.grey, fontFamily: 'Kanit', fontSize: 18)),
              )
            ],
          ),
        ),
        body: page(),
      ),
    );
  }

  Widget page() {
    switch (pages) {
      case 0:
        return general();
      case 1:
        return activateAccount();
      case 2:
        return shipppings();
      case 3:
        return shippingDetails();
      case 4:
        return requests();
      case 5:
        return requestDetails();
      case 6:
        return profile();

      case 7:
        return earnings();
    }
    return Container();
  }

  Widget general() {
    return ListView(
      children: <Widget>[
        deliveryInfo != null
            ? deliveryInfo["validated"] == 0
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
                                "Envíos",
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: Colors.grey[600],
                                    fontSize:
                                        MediaQuery.of(context).size.width / 22),
                              ),
                              trailing: Icon(
                                Icons.local_shipping,
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
                                                8,
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
                                "Solicitudes",
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: Colors.grey[600],
                                    fontSize:
                                        MediaQuery.of(context).size.width / 24),
                              ),
                              trailing: Icon(
                                Icons.insert_chart,
                                color: Color.fromRGBO(255, 144, 82, 1),
                              ),
                            ),
                            contacts != null
                                ? Text(
                                    contacts.length.toString(),
                                    style: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                8,
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
                          pages = 4;
                        });
                      }),
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
                                        MediaQuery.of(context).size.width / 22),
                              ),
                              trailing: Icon(
                                Icons.monetization_on,
                                color: Color.fromRGBO(255, 144, 82, 1),
                              ),
                            ),
                            orders != null
                                ? Text(
                                    incomeAmountText(),
                                    style: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                13,
                                        color: Colors.grey[600]),
                                  )
                                : Text(
                                    "\$" + 0.toString(),
                                    style: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                13,
                                        color: Colors.grey[600]),
                                  )
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
                                    MediaQuery.of(context).size.width / 22),
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
                                        MediaQuery.of(context).size.width / 8,
                                    color: Colors.grey[600]),
                              )
                            : Text(
                                0.toString(),
                                style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize:
                                        MediaQuery.of(context).size.width / 6,
                                    color: Colors.grey[600]),
                              ),
                      ],
                    ),
                  ),
                )),
            Spacer()
          ],
        ),
        Row(
          children: <Widget>[Spacer(), Spacer()],
        ),
      ],
    );
  }

  String incomeAmountText() {
    int amount = 0;
    var now = DateTime.now().toString();
    var split = now.split("-");
    String weekYear = split[0] + "-" + Jiffy().week.toString();

    if (orders.length != 0) {
      if (orders[weekYear] != null) {
        for (var i = 0; i < orders[weekYear].length; i++) {
          amount += orders[weekYear][i]["delivery_total"];
        }
      }
    }

    return "\$" + amount.toString();
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

  Widget activateAccount() {
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
            "Zerdaly deposita semanalmente, los ingresos que obtienes al realizar los envíos.",
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
                    'Guardar',
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
              final auth = await token.queryAllRows();
              saveBank(auth[0]["Auth"]);
            }
          },
        )
      ],
    );
  }

  saveBank(String auth) async {
    final response = await delivery.newBank(
        bankName, bankType, bankNumber.text, bankHolder.text, auth);

    if (response == true) {
      getDeliveryInfo();
      setState(() {
        pages = 0;
      });
    } else {
      errorMessage("Intentalo otra vez.");
    }

    setState(() {});
  }

  Widget shipppings() {
    return ListView.builder(
      itemCount: shippings.length + 1,
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
                      "Envíos",
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
                    child: Icon(
                      Icons.local_shipping,
                      color: Color.fromRGBO(255, 144, 82, 1),
                    ),
                  )
                ],
              ),
              Divider(),
              shippings.length == 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Aún no has realizado un envío.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: 'Kanit',
                            fontSize: 18,
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          );
        } else {
          final shippingDetails = shippings[i - 1];
          return Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(ctx).size.width / 1.12,
                          height: MediaQuery.of(ctx).size.width / 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                              ),
                              Row(
                                children: <Widget>[
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
                                          )),
                                      Text(
                                          shippingDetails["shipping_total"]
                                              .toString(),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: MediaQuery.of(context).size.width/25,
                                            fontFamily: 'Kanit',
                                          )),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Ganacia",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      Text(
                                          (shippingDetails["shipping_total"] -
                                                  (shippingDetails[
                                                          "shipping_total"] *
                                                      0.20))
                                              .toString(),
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: MediaQuery.of(context).size.width/25,
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
                                      Text(
                                          shippingDetails["shipping_status"] ==
                                                  4
                                              ? "Completado"
                                              : "No completado",
                                          style: TextStyle(
                                            color: shippingDetails[
                                                        "shipping_status"] ==
                                                    4
                                                ? Colors.green
                                                : Colors.red,
                                            fontSize: MediaQuery.of(context).size.width/25,
                                            fontFamily: 'Kanit',
                                          ))
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

  Widget shippingDetails() {
    return Container();
  }

  Widget requests() {
    return ListView.builder(
      itemCount: contacts.length + 1,
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
                      "Solicitudes",
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
                    child: Icon(
                      Icons.insert_chart,
                      color: Color.fromRGBO(255, 144, 82, 1),
                    ),
                  )
                ],
              ),
              Divider(),
              contacts.length == 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Aún no has sido solicitado.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: 'Kanit',
                            fontSize: 18,
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          );
        } else {
          final contactDetails = contacts[i - 1];
          return Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(ctx).size.width / 1.12,
                          //height: MediaQuery.of(ctx).size.width / 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 5),
                              ),
                              Row(
                                children: <Widget>[
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("id",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      Text(
                                          "#" + contactDetails["id"].toString(),
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
                                      Text("Pedido",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      Text(
                                          "#" +
                                              contactDetails["order_id"]
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
                                      Text("Detalles",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontFamily: 'Kanit',
                                          )),
                                      GestureDetector(
                                        child: Text("Ver",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 16,
                                              fontFamily: 'Kanit',
                                            )),
                                        onTap: () async {
                                          businessInfo = null;
                                          orderDetails = null;
                                          userDetails = null;
                                          userLocation = null;
                                          shippingsPage = 0;
                                          askIfArrived = false;

                                          contactInfo = contactDetails;
                                          getBusinessInfo(
                                              contactDetails["business_id"]);
                                          getOrderDetails(
                                              contactDetails["order_id"]);

                                          setState(() {
                                            pages = 5;
                                          });
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

  getBusinessInfo(int id) async {
    final auth = await token.queryAllRows();
    final result = await delivery.getBusiness(id, auth[0]["Auth"]);

    deliveryLocation = await location.getLocation();

    if (result[0] == "200") {
      setState(() {
        businessInfo = result[2];
      });
    }
  }

  getOrderDetails(int id) async {
    final auth = await token.queryAllRows();
    final result = await delivery.getOrder(id, auth[0]["Auth"]);
    if (result[0] == "200") {
      setState(() {
        orderDetails = result[2];
      });

      getUser(orderDetails[0]["user_id"]);
      getUserLocation(orderDetails[0]["user_location_id"]);
    }
  }

  getUser(int id) async {
    final auth = await token.queryAllRows();
    final result = await delivery.getUser(id, auth[0]["Auth"]);
    if (result[0] == "200") {
      setState(() {
        userDetails = result[2];
      });
    }
  }

  getUserLocation(int id) async {
    final auth = await token.queryAllRows();
    final result = await delivery.getUserLocation(id, auth[0]["Auth"]);
    if (result[0] == "200") {
      setState(() {
        userLocation = result[2];
      });
    }
  }

  var businessInfo, orderDetails, contactInfo, userDetails, userLocation;
  MapboxMapController mapController;

  Widget requestDetails() {
    return orderDetails != null
        ? orderDetails[0]["delivery_id"] == null ||
                orderDetails[0]["delivery_id"] == deliveryInfo["id"]
            ? orderDetails[0]["shipping_status"] < 4
                ? businessInfo == null
                    ? Container(
                        child: Center(
                        child: CircularProgressIndicator(),
                      ))
                    : map()
                : requestDone()
            : orderTaken()
        : Container(
            child: Center(
            child: CircularProgressIndicator(),
          ));
  }

  var location = new prefix0.Location();
  var deliveryLocation;
  double distanceInMeters = 0;
  int shippingsPage = 0;
  bool askIfArrived = false;

  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
    getDistance();
    // mapController.addCircle(CircleOptions(
    //     geometry:
    //         LatLng(businessInfo[0]["latitude"], businessInfo[0]["longitude"]),
    //     circleColor: "#ff9052",
    //     circleRadius: 7,
    //     circleStrokeWidth: 1));

    // mapController.addSymbol(SymbolOptions(
    //     geometry:
    //         LatLng(businessInfo[0]["latitude"], businessInfo[0]["longitude"]),
    //     iconImage: "suitcase-15"));
  }

  void onMapCreated2(MapboxMapController controller) {
    mapController = controller;
  }

  Widget map() {
    return Container(
      child: Stack(
        children: shippingsPage == 0
            ? <Widget>[
                MapboxMap(
                  onMapCreated: onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(businessInfo[0]["latitude"],
                        businessInfo[0]["longitude"]),
                    zoom: 15,
                  ),
                  trackCameraPosition: true,
                  rotateGesturesEnabled: false,
                  myLocationEnabled: false,
                  myLocationTrackingMode: MyLocationTrackingMode.None,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.business_center,
                    color: Colors.orange,
                    size: 25,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: !askIfArrived
                          ? MediaQuery.of(context).size.height / 5
                          : MediaQuery.of(context).size.height / 3,
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    top: 10,
                                  ),
                                  child: Text(
                                      businessInfo[0]["business_name"]
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width/23,
                                          fontFamily: 'Kanit',
                                          color: Colors.grey[600])),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    top: 10,
                                  ),
                                  child: Text(
                                      distanceInMeters == 0
                                          ? "0 km"
                                          : (distanceInMeters / 1000)
                                                  .toStringAsFixed(2) +
                                              " km",
                                      style: TextStyle(
                                          fontSize:  MediaQuery.of(context).size.width/23,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey[600])),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    top: 10,
                                  ),
                                  child: Text(
                                      "\$" +
                                          orderDetails[0]["shipping_total"]
                                              .toString(),
                                      style: TextStyle(
                                          fontSize:  MediaQuery.of(context).size.width/23,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey[600])),
                                ),
                                Spacer(),
                                Padding(
                                  padding: EdgeInsets.only(top: 10, right: 10),
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        pages = 0;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                              ),
                              child: Text(
                                  businessInfo[0]["direction_details"]
                                      .toString(),
                                  style: TextStyle(
                                      fontSize:  MediaQuery.of(context).size.width/24,
                                      fontFamily: 'Kanit',
                                      color: Colors.grey[600])),
                            ),
                            !askIfArrived
                                ? GestureDetector(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              12,
                                      child: Card(
                                        color: Colors.green,
                                        child: Center(
                                          child: Text("Comenzar",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Kanit',
                                                  color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      final auth = await token.queryAllRows();
                                      final result = await delivery.takeOrder(
                                          orderDetails[0]["id"],
                                          auth[0]["Auth"]);

                                      if (result[0] == "200") {
                                        startShipping();
                                        final result = await delivery.update(
                                            json.encode({'status': 0}),
                                            auth[0]["Auth"]);
                                        setState(() {
                                          askIfArrived = true;
                                        });
                                      } else {
                                        errorMessage(
                                            "Este pedido ya se ha tomado.");
                                        getDeliveryInfo();
                                        setState(() {
                                          pages = 0;
                                        });
                                      }
                                    },
                                  )
                                : Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              11,
                                          child: Card(
                                            color: Colors.green,
                                            child: Center(
                                              child: Text("Llegue al negocio",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Kanit',
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                        onTap: () async {
                                          final auth =
                                              await token.queryAllRows();
                                          final result =
                                              await delivery.arrivedOnBusiness(
                                                  orderDetails[0]["id"],
                                                  auth[0]["Auth"]);

                                          if (result[0] == "200") {
                                            getDistance2();

                                            setState(() {
                                              shippingsPage = 1;
                                              askIfArrived = false;
                                            });
                                          } else {
                                            errorMessage(
                                                "Ha ocurrido un error, intentalo otra vez.");
                                          }
                                        },
                                      ),
                                      GestureDetector(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              11,
                                          child: Card(
                                            color: Colors.red,
                                            child: Center(
                                              child: Text(
                                                  "No he llegado al negocio",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Kanit',
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            askIfArrived = false;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                          ],
                        ),
                      )),
                ),
              ]
            : <Widget>[
                userDetails != null
                    ? new MapboxMap(
                        onMapCreated: onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(userLocation[0]["latitude"],
                              userLocation[0]["longitude"]),
                          zoom: 15,
                        ),
                        trackCameraPosition: true,
                        rotateGesturesEnabled: false,
                        myLocationEnabled: false,
                        myLocationTrackingMode: MyLocationTrackingMode.None,
                      )
                    : Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.person,
                    color: Colors.orange,
                    size: 25,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: !askIfArrived
                          ? MediaQuery.of(context).size.height / 5
                          : MediaQuery.of(context).size.height / 3,
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    top: 10,
                                  ),
                                  child: Text(
                                      userDetails[0]["name"] +
                                          " " +
                                          userDetails[0]["lastname"].toString(),
                                      style: TextStyle(
                                          fontSize:  MediaQuery.of(context).size.width/22,
                                          fontFamily: 'Kanit',
                                          color: Colors.grey[600])),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    top: 10,
                                  ),
                                  child: Text(
                                      distanceInMeters == 0
                                          ? "0 km"
                                          : (distanceInMeters / 1000)
                                                  .toStringAsFixed(2) +
                                              " km",
                                      style: TextStyle(
                                          fontSize:  MediaQuery.of(context).size.width/22,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey[600])),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    top: 10,
                                  ),
                                  child: Text(
                                      "\$" +
                                          orderDetails[0]["shipping_total"]
                                              .toString(),
                                      style: TextStyle(
                                          fontSize:  MediaQuery.of(context).size.width/22,
                                          fontFamily: 'Kanit',
                                          fontWeight: FontWeight.w800,
                                          color: Colors.grey[600])),
                                ),
                                Spacer(),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                              ),
                              child: Text(
                                  userLocation[0]["description"].toString(),
                                  style: TextStyle(
                                      fontSize:  MediaQuery.of(context).size.width/24,
                                      fontFamily: 'Kanit',
                                      color: Colors.grey[600])),
                            ),
                            !askIfArrived
                                ? GestureDetector(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              12,
                                      child: Card(
                                        color: Colors.green,
                                        child: Center(
                                          child: Text("Continuar",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Kanit',
                                                  color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      final auth = await token.queryAllRows();
                                      final result =
                                          await delivery.onWayToCustomer(
                                              orderDetails[0]["id"],
                                              auth[0]["Auth"]);

                                      if (result[0] == "200") {
                                        continueShipping();
                                        setState(() {
                                          askIfArrived = true;
                                        });
                                      } else {
                                        errorMessage(
                                            "Ha ocurrido un error, intentalo otra vez.");
                                      }
                                    },
                                  )
                                : Column(
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              11,
                                          child: Card(
                                            color: Colors.green,
                                            child: Center(
                                              child: Text(
                                                  "Llegue donde el cliente",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Kanit',
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() async {
                                            final auth =
                                                await token.queryAllRows();
                                            final result = await delivery
                                                .arrivedOnCustomer(
                                                    orderDetails[0]["id"],
                                                    auth[0]["Auth"]);
                                            if (result[0] == "200") {
                                              getDeliveryInfo();
                                              await delivery.update(
                                            json.encode({'status': 1}),
                                            auth[0]["Auth"]);
                                              pages = 0;
                                            } else {
                                              errorMessage(
                                                  "Ha ocurrido un error, intentalo otra vez.");
                                            }
                                          });
                                        },
                                      ),
                                      GestureDetector(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              11,
                                          child: Card(
                                            color: Colors.red,
                                            child: Center(
                                              child: Text(
                                                  "No he llegado donde el cliente",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Kanit',
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            askIfArrived = false;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                          ],
                        ),
                      )),
                ),
              ],
      ),
    );
  }

  getDistance() async {
    distanceInMeters = await Geolocator().distanceBetween(
        deliveryLocation.latitude,
        deliveryLocation.longitude,
        businessInfo[0]["latitude"],
        businessInfo[0]["longitude"]);
    setState(() {});
  }

  getDistance2() async {
    mapController.animateCamera(CameraUpdate.newLatLng(
      LatLng(userLocation[0]["latitude"], userLocation[0]["longitude"]),
    ));
    setState(() {
      distanceInMeters = 0;
    });
    deliveryLocation = await location.getLocation();
    distanceInMeters = await Geolocator().distanceBetween(
        deliveryLocation.latitude,
        deliveryLocation.longitude,
        userLocation[0]["latitude"],
        userLocation[0]["longitude"]);
    setState(() {});
  }

  startShipping() async {
    final origin = Location(
        name: "Delivery",
        latitude: deliveryLocation.latitude,
        longitude: deliveryLocation.longitude);
    final destination = Location(
        name: businessInfo[0]["business_name"],
        latitude: businessInfo[0]["latitude"],
        longitude: businessInfo[0]["longitude"]);

    await FlutterMapboxNavigation.startNavigation(origin, destination);
  }

  continueShipping() async {
    final origin = Location(
        name: "Delivery",
        latitude: deliveryLocation.latitude,
        longitude: deliveryLocation.longitude);
    final destination = Location(
        name: userDetails[0]["name"] + " " + userDetails[0]["lastname"],
        latitude: userLocation[0]["latitude"],
        longitude: userLocation[0]["longitude"]);

    await FlutterMapboxNavigation.startNavigation(origin, destination);
  }

  Widget orderTaken() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height / 8,
            decoration:
                BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: Center(
              child: Icon(
                Icons.cancel,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            "Este envío ha sido\ntomado por otro delivery.",
            style: TextStyle(
              color: Colors.grey[600],
              fontFamily: 'Kanit',
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }

  Widget requestDone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height / 8,
            decoration:
                BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: Center(
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            "Envío completado",
            style: TextStyle(
                color: Colors.grey[600], fontFamily: 'Kanit', fontSize: 20),
          ),
        )
      ],
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
              itemCount: orders.length - 1,
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

    if (orders.length != 0) {
      if (orders[weekYear] != null) {
        return orders[weekYear].length.toString();
      }
    }

    return 0.toString();
  }

  String incomeAmountPerWeekText(int i) {
    int amount = 0;
    var now = DateTime.now().toString();
    var split = now.split("-");
    String weekYear = split[0] + "-" + (Jiffy().week - (i + 1)).toString();

    for (var i = 0; i < orders[weekYear].length; i++) {
      amount += orders[weekYear][i]["business_total"];
    }

    return "\$" + amount.toString();
  }

  String incomeAmountTransactionsPerWeekText(int i) {
    var now = DateTime.now().toString();
    var split = now.split("-");
    String weekYear = split[0] + "-" + (Jiffy().week - (i + 1)).toString();

    return orders[weekYear].length.toString();
  }

  //update business image, info, etc.
  TextEditingController deliveryName = new TextEditingController();
  TextEditingController deliveryLastName = new TextEditingController();
  TextEditingController deliveryEmail = new TextEditingController();
  TextEditingController deliveryPhone = new TextEditingController();
  File deliveryImg;

  Widget profile() {
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
                      "Mi cuenta",
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
                      if (deliveryName.text.length < 4) {
                        errorMessage("Tu nombre debe tener la menos 4 letras.");
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
                    child: deliveryImg == null
                        ? deliveryInfo["image"] != null
                            ? Container(
                                margin: EdgeInsets.only(left: 6, right: 6),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(deliveryUrl +
                                            deliveryInfo["image"]))),
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
                                  image: FileImage(deliveryImg),
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
                controller: deliveryName,
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
                'Apellido',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: MediaQuery.of(context).size.width / 20,
                  fontFamily: 'Kanit',
                ),
              ),
              TextField(
                controller: deliveryLastName,
                decoration: InputDecoration(
                  hintText: 'Tu apellido',
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
                controller: deliveryEmail,
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
                controller: deliveryPhone,
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
        deliveryImg = img;
      });
    } else {
      errorMessage("No se ha seleccionado ninguna foto.");
    }
  }

  saveProfileChanges() async {
    final auth = await token.queryAllRows();

    if (deliveryImg != null) {
      await CompressImage.compress(
          imageSrc: deliveryImg.path, desiredQuality: 85);

      String deliveryImgBs64 = base64Encode(deliveryImg.readAsBytesSync());
      final response =
          await delivery.uploadDeliveryImage(deliveryImgBs64, auth[0]["Auth"]);

      if (response[0] == 200) {
        if (deliveryEmail.text == deliveryInfo["email"]) {
          updateDelivery(
              json.encode({
                'name': deliveryName.text,
                'lastname': deliveryLastName.text,
                'phone': deliveryPhone.text,
                'image': response[2],
              }),
              auth[0]["Auth"]);
        } else {
          updateDelivery(
              json.encode({
                'name': deliveryName.text,
                'lastname': deliveryLastName.text,
                'phone': deliveryPhone.text,
                'image': response[2],
                'email': deliveryEmail.text
              }),
              auth[0]["Auth"]);
        }
      } else {
        errorMessage("Ha ocurrido un error, Intentalo otra vez.");
      }
    } else {
      if (deliveryEmail.text == deliveryInfo["email"]) {
        updateDelivery(
            json.encode({
              'name': deliveryName.text,
              'lastname': deliveryLastName.text,
              'phone': deliveryPhone.text,
            }),
            auth[0]["Auth"]);
      } else {
        updateDelivery(
            json.encode({
              'name': deliveryName.text,
              'lastname': deliveryLastName.text,
              'phone': deliveryPhone.text,
              'email': deliveryEmail.text
            }),
            auth[0]["Auth"]);
      }
    }
  }

  updateDelivery(var data, String auth) async {
    final result = await delivery.update(data, auth);

    if (result[0] == "200") {
      imageCache.clear();
      getDeliveryInfo();
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
      } else {
        errorMessage("Ha ocurrido error, Intentalo de nuevo.");
      }
    } else {
      errorMessage("Ha ocurrido error, Intentalo de nuevo.");
    }
  }
}
