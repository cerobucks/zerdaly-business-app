import 'dart:convert';
import 'dart:io';

import 'package:compressimage/compressimage.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zerdaly_business_app/Token.dart';
import 'package:zerdaly_business_app/delivery_views/general.dart';
import 'package:zerdaly_business_app/model/delivery.dart';

class DeliveryRegister extends StatefulWidget {
  @override
  DeliveryRegisterState createState() => DeliveryRegisterState();
}

class DeliveryRegisterState extends State<DeliveryRegister> {
  TextEditingController name = new TextEditingController();
  TextEditingController lastName = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController bday = new TextEditingController();
  TextEditingController bmonth = new TextEditingController();
  TextEditingController byear = new TextEditingController();
  TextEditingController deliveryPhone = new TextEditingController();
  String city = "";

  int page = 1;
  MediaQueryData screenInfo;
  MapboxMapController mapController;
  var location = new Location();
  var deliveryLocation;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool imageBeingProcessed = false;
  bool faceImgValidated = false;
  bool idImgValidated = false;
  bool motoImgValidated = false;
  bool registerProcess = false;
  bool fixEmail = false;
  bool validEmail = false;

  File faceImg, idImg, motoImg;

  @override
  Widget build(BuildContext context) {
    screenInfo = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 144, 82, 1),
      key: _scaffoldKey,
      body: ListView(
        children: <Widget>[pages(page)],
      ),
    );
  }

  Widget pages(int page) {
    switch (page) {
      case 1:
        return firstPage();
        break;
      case 2:
        return secondPage();
        break;
      case 3:
        return thirdPage();
        break;
    }
    return Container();
  }

  Widget firstPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          'Esto solo te tomara unos minutos...',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Kanit',
              fontSize: screenInfo.size.width * 0.045),
          textAlign: TextAlign.center,
        ),
        Text(
          'Para empezar nececitamos:',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Kanit',
              fontSize: screenInfo.size.width * 0.045),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Container(
            width: screenInfo.size.width,
            height: screenInfo.size.height * 0.75,
            padding: EdgeInsets.all(10),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Tu nombre',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: screenInfo.size.width * 0.045,
                        fontFamily: 'Kanit',
                      ),
                    ),
                    TextField(
                      controller: name,
                      decoration: InputDecoration(
                        hintText: 'Ej: Juan',
                        hintStyle: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: screenInfo.size.width * 0.045,
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Tu apellido',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: screenInfo.size.width * 0.045,
                        fontFamily: 'Kanit',
                      ),
                    ),
                    TextField(
                      controller: lastName,
                      decoration: InputDecoration(
                        hintText: 'Ej: Bosch',
                        hintStyle: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: screenInfo.size.width * 0.045,
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Tu Email',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: screenInfo.size.width * 0.045,
                        fontFamily: 'Kanit',
                      ),
                    ),
                    TextField(
                      controller: email,
                      onChanged: (text) {
                        setState(() {
                          fixEmail = false;
                          validEmail = false;
                        });
                      },
                      decoration: InputDecoration(
                          hintText: 'Ej: juan@mail.com',
                          hintStyle: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: screenInfo.size.width * 0.045,
                          ),
                          errorText: fixEmail
                              ? "Este email ya esta en uso."
                              : validEmail ? "Escribe un email valido." : null),
                    ),
                    Spacer(),
                    Text(
                      'Contraseña',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: screenInfo.size.width * 0.045,
                        fontFamily: 'Kanit',
                      ),
                    ),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Tu contraseña',
                        hintStyle: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: screenInfo.size.width * 0.045,
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Fecha de nacimiento',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: screenInfo.size.width * 0.045,
                        fontFamily: 'Kanit',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Spacer(),

                        //day TextField
                        Container(
                          width: screenInfo.size.width * 0.10,
                          child: TextField(
                            controller: bday,
                            maxLength: 2,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Día',
                              hintStyle: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.045,
                              ),
                              counterText: "",
                            ),
                          ),
                        ),
                        Spacer(),
                        //Month TextField
                        Container(
                          width: screenInfo.size.width * 0.10,
                          child: TextField(
                            controller: bmonth,
                            maxLength: 2,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Mes',
                              hintStyle: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.045,
                              ),
                              counterText: "",
                            ),
                          ),
                        ),
                        Spacer(),

                        //Year TextField
                        Container(
                          width: screenInfo.size.width * 0.20,
                          child: TextField(
                            controller: byear,
                            maxLength: 4,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Año',
                              hintStyle: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.045,
                              ),
                              counterText: "",
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    )
                  ],
                ),
              ),
            )),
        GestureDetector(
          child: Container(
            width: screenInfo.size.width * 0.40,
            height: screenInfo.size.height * 0.07,
            child: Center(
              child: Card(
                color: Color.fromRGBO(255, 144, 82, 1),
                child: Center(
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Kanit',
                        fontSize: screenInfo.size.width * 0.045),
                  ),
                ),
              ),
            ),
          ),
          onTap: () {
            pageOneValidation();
          },
        )
      ],
    );
  }

  pageOneValidation() {
    
    if (name.text.isEmpty ||
        lastName.text.isEmpty ||
        email.text.isEmpty ||
        email.text.isEmpty ||
        bday.text == "" ||
        byear.text == "" ||
        byear.text == "") {
      errorMessage("Por favor, completa todos los campos.");
    } else if (byear.text.length != 4) {
      errorMessage("El año debe tener 4 digitos.");
    } else if (int.parse(bday.text) > 31) {
      errorMessage("Los meses no tienen más de 31 días.");
    } else if (int.parse(bmonth.text) > 12) {
      errorMessage("El año no tiene más de 12 meses.");
    } else {
      DateTime now = new DateTime.now();
      var age = now.year - int.parse(byear.text);

      if (age < 18) {
        errorMessage("Debes ser mayor de edad para continuar.");
      } else {
        setState(() {
          page = 2;
        });
      }
    }
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

  Widget secondPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          'Para brindar un servicio de\ncalidad, necesitamos 3 fotos:',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Kanit',
              fontSize: screenInfo.size.width * 0.045),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15),
        ),
        //Selfie
        GestureDetector(
          child: Container(
            width: screenInfo.size.width * 0.75,
            height: screenInfo.size.height * 0.20,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.face,
                      size: screenInfo.size.width * 0.20,
                      color: !faceImgValidated
                          ? Color.fromRGBO(255, 144, 82, 1)
                          : Colors.green,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Selfie',
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.05)),
                        Text('Tómate una selfie',
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.04)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            if (!imageBeingProcessed) {
              faceImageValidation();
            }
          },
        ),
        //Cedula de identidad
        GestureDetector(
          child: Container(
            width: screenInfo.size.width * 0.75,
            height: screenInfo.size.height * 0.20,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.person_pin,
                      size: screenInfo.size.width * 0.20,
                      color: !idImgValidated
                          ? Color.fromRGBO(255, 144, 82, 1)
                          : Colors.green,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Tu Cédula',
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.05)),
                        Text('Foto de Cédula',
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.04)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            if (!imageBeingProcessed) {
              idImageValidation();
            }
          },
        ),
        GestureDetector(
          child: Container(
            width: screenInfo.size.width * 0.75,
            height: screenInfo.size.height * 0.20,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.motorcycle,
                      size: screenInfo.size.width * 0.20,
                      color: !motoImgValidated
                          ? Color.fromRGBO(255, 144, 82, 1)
                          : Colors.green,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Tu motor',
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.05)),
                        Text('Foto de motor.',
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.04)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          onTap: () {
            if (!imageBeingProcessed) {
              motoImageValidation();
            }
          },
        ),
        imageBeingProcessed
            ? Padding(
                padding: EdgeInsets.only(top: 20),
              )
            : Container(),
        imageBeingProcessed
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              )
            : Container(),
        Padding(
          padding: EdgeInsets.only(top: 20),
        ),
        GestureDetector(
          child: Container(
            width: screenInfo.size.width * 0.40,
            height: screenInfo.size.height * 0.07,
            child: Center(
              child: Card(
                color: Color.fromRGBO(255, 144, 82, 1),
                child: Center(
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Kanit',
                        fontSize: screenInfo.size.width * 0.045),
                  ),
                ),
              ),
            ),
          ),
          onTap: () {
            pageTwoValidation();
          },
        ),
      ],
    );
  }

  pageTwoValidation() {
    if (!faceImgValidated) {
      errorMessage("Debes subir una selfie.");
    } else if (!idImgValidated) {
      errorMessage("Debes subir una foto de tu cédula.");
    } else if (!motoImgValidated) {
      errorMessage("Debes subir una foto de tu motor.");
    } else {
      setState(() {
        page = 3;
      });
    }
  }

  faceImageValidation() async {
    setState(() {
      imageBeingProcessed = true;
    });
    File img = await ImagePicker.pickImage(source: ImageSource.camera);

    if (img != null) {
      final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(img);
      final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
      List<Face> face = await faceDetector.processImage(visionImage);

      if (face.length == 1) {
        faceImg = img;
        faceImgValidated = true;
        imageBeingProcessed = false;
      } else {
        errorMessage("La foto debe ser de tu cara.");
        faceImgValidated = false;
        imageBeingProcessed = false;
      }
      setState(() {});
    } else {
      errorMessage("No se ha tomado la foto.");
    }
  }

  idImageValidation() async {
    setState(() {
      imageBeingProcessed = true;
    });
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    if (img != null) {
      FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(img);
      ImageLabeler labeler = FirebaseVision.instance.cloudImageLabeler();
      List<ImageLabel> labels = await labeler.processImage(visionImage);

      for (ImageLabel label in labels) {
        if (label.text.toString() == "Identity document" &&
            label.confidence > 0.70) {
          idImg = img;
        }
      }

      if (idImg != null) {
        idImgValidated = true;
        imageBeingProcessed = false;
      } else {
        idImgValidated = false;
        imageBeingProcessed = false;
        errorMessage("La foto debe ser de tu cédula.");
      }

      setState(() {});
    } else {
      errorMessage("No se ha tomado la foto.");
    }
  }

  motoImageValidation() async {
    setState(() {
      imageBeingProcessed = true;
    });
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    if (img != null) {
      FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(img);
      ImageLabeler labeler = FirebaseVision.instance.cloudImageLabeler();
      List<ImageLabel> labels = await labeler.processImage(visionImage);

      for (ImageLabel label in labels) {
        if (label.text.toString() == "Motorcycle" && label.confidence > 0.70) {
          motoImg = img;
        }
      }

      if (motoImg != null) {
        motoImgValidated = true;
        imageBeingProcessed = false;
      } else {
        motoImgValidated = false;
        imageBeingProcessed = false;
        errorMessage("La foto debe ser de tu motor.");
      }

      setState(() {});
    } else {
      errorMessage("No se ha tomado la foto.");
    }
  }

  Widget thirdPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Text(
          'Solo necesitamos unos detalles más...',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Kanit',
              fontSize: screenInfo.size.width * 0.045),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Container(
            width: screenInfo.size.width,
            height: screenInfo.size.height * 0.35,
            padding: EdgeInsets.all(10),
            child: Card(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Número de teléfono',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: screenInfo.size.width * 0.045,
                              fontFamily: 'Kanit',
                            ),
                          ),
                          TextField(
                            controller: deliveryPhone,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            decoration: InputDecoration(
                              hintText: 'Ej: 8092461925',
                              hintStyle: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.045,
                              ),
                              counterText: "",
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Ciudad',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: screenInfo.size.width * 0.045,
                              fontFamily: 'Kanit',
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              DropdownButton<String>(
                                  items: <String>[
                                    'Santo Domingo',
                                    'Santiago',
                                    'San Pedro de Macoris',
                                    'La Altagracia',
                                    'La Romana',
                                    'La Vega',
                                    'Puerto Plata'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontFamily: 'Kanit',
                                          fontSize: screenInfo.size.width * 0.045
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String res) {
                                    setState(() {
                                      city = res;
                                    });
                                  },
                                  hint: Text(
                                    city == "" ? "Tu ciudad" : city,
                                    style: TextStyle(
                                      fontFamily: 'Kanit',
                                      fontSize: screenInfo.size.width * 0.045
                                    ),
                                  )),
                            ],
                          )
                        ])))),
                        Center(
            child: Column(children: <Widget>[
              Text(
              'Al registrarme estoy de acuerdo con los ',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kanit',
                fontSize: screenInfo.size.width * 0.025,
              ),
              textAlign: TextAlign.center,
            ),
            GestureDetector(child: Text(
              'Terminos y Condiciones.',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kanit',
                fontSize: screenInfo.size.width * 0.03,
              ),
              textAlign: TextAlign.center,
            ),
            onTap: (){
              _launchURL();
            },)
            ],),
          ),
        !registerProcess
            ? GestureDetector(
                child: Container(
                  width: screenInfo.size.width * 0.40,
                  height: screenInfo.size.height * 0.07,
                  child: Center(
                    child: Card(
                      color: Color.fromRGBO(255, 144, 82, 1),
                      child: Center(
                        child: Text(
                          'Registrarme',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Kanit',
                              fontSize: screenInfo.size.width * 0.045),
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  pageThreeValidation();
                },
              )
            : Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              )
      ],
    );
  }
_launchURL() async {
  const url = 'https://zerdaly.com/terms.html';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
  pageThreeValidation() async {
    if (deliveryPhone.text.isEmpty || city == "") {
      errorMessage("Por favor, completa todos los campos.");
    } else if (deliveryPhone.text.length > 10 ||
        deliveryPhone.text.length < 10) {
      errorMessage("El número de telefono debe tener 10 digitos.");
    } else {
      if (deliveryLocation == null) {
        deliveryLocation = await location.getLocation();
      }
      register();
    }
  }

  register() async {
    setState(() {
      registerProcess = true;
    });

    await CompressImage.compress(imageSrc: faceImg.path, desiredQuality: 85);
    await CompressImage.compress(imageSrc: idImg.path, desiredQuality: 85);
    await CompressImage.compress(imageSrc: motoImg.path, desiredQuality: 85);

    String bs64FaceImg = base64Encode(faceImg.readAsBytesSync());
    String bs64IdImg = base64Encode(idImg.readAsBytesSync());
    String bs64MotoImg = base64Encode(motoImg.readAsBytesSync());

    setState(() {});

    Delivery delivery = new Delivery();
    var data = {
      'name': name.text,
      'lastname': lastName.text,
      'email': email.text.toLowerCase().toString(),
      'password': password.text,
      'dob': bday.text.toString() +
          "/" +
          bmonth.text.toString() +
          "/" +
          byear.text.toString(),
      'city': city,
      'phone': deliveryPhone.text.toString(),
      'latitude': deliveryLocation.latitude.toString(),
      'longitude': deliveryLocation.longitude.toString(),
      'id_image': bs64IdImg,
      'face_image': bs64FaceImg,
      'moto_image': bs64MotoImg,
    };

    final result = await delivery.register(data);

    if (result[0] == 200) {
      saveToken(result[4]["token"].toString());
    } else if (result[0] == 404) {
      if (result[2]["email"] != null) {
        if (result[2]["email"][0] ==
            "The email must be a valid email address.") {
          validEmail = true;
          page = 1;
        } else if ((result[2]["email"][0] ==
            "The email has already been taken.")) {
          fixEmail = true;
          page = 1;
        }
      } else {
        errorMessage("Ha ocurrido error, Intentalo de nuevo.");
      }
    } else {
      errorMessage("Ha ocurrido error, Intentalo de nuevo.");
    }

    setState(() {
      registerProcess = false;
    });
  }

  saveToken(String auth) async {
    Token token = Token.instance;
    Map<String, dynamic> row = {
      Token.columnKind: "Delivery",
      Token.columnAuth: auth
    };

    final id = await token.insert(row);

    if (id != null) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => DeliveryGeneral()));
    }
  }
}
