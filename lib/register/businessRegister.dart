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
import 'package:zerdaly_business_app/business_views/general.dart';
import 'package:zerdaly_business_app/model/business.dart';

class BusinessRegister extends StatefulWidget {
  @override
  BusinessRegisterState createState() => BusinessRegisterState();
}

class BusinessRegisterState extends State<BusinessRegister> {
  TextEditingController name = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController bday = new TextEditingController();
  TextEditingController bmonth = new TextEditingController();
  TextEditingController byear = new TextEditingController();
  TextEditingController businessName = new TextEditingController();
  TextEditingController businessPhone = new TextEditingController();
  TextEditingController businessDirection = new TextEditingController();
  String city = "";
  String category;
  String shippingTime;

  int page = 1;
  MediaQueryData screenInfo;
  MapboxMapController mapController;
  var location = new Location();
  var userLocation;
  var businessLocation;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool imageBeingProcessed = false;
  bool faceImgValidated = false;
  bool idImgValidated = false;
  bool registerProcess = false;
  bool fixBusinessName = false;
  bool fixEmail = false;
  bool validEmail = false;

  File faceImg, idImg;

  @override
  Widget build(BuildContext context) {
    screenInfo = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 144, 82, 1),
      key: _scaffoldKey,
      body: page != 4
          ? ListView(
              children: <Widget>[pages(page)],
            )
          : pageFour(),
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
      case 4:
        return pageFour();
        break;
      case 5:
        return pageFive();
        break;
      case 6:
        return pageSix();
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
            height: screenInfo.size.height * 0.70,
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
                        hintText: 'Ej: Juan Gomez',
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
                      padding: EdgeInsets.only(top: 5),
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
                                fontSize: screenInfo.size.width / 21,
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
          'Para brindar un servicio de\ncalidad, necesitamos 2 fotos:',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Kanit',
              fontSize: screenInfo.size.width * 0.045),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
        ),
        //Selfie
        GestureDetector(
          child: Container(
            width: screenInfo.size.width * 0.75,
            height: screenInfo.size.height * 0.18,
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
            height: screenInfo.size.height * 0.18,
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
                        Text('Cédula',
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
                        fontSize: screenInfo.size.width / 19),
                  ),
                ),
              ),
            ),
          ),
          onTap: () {
            pageTwoValidation();
          },
        )
      ],
    );
  }

  pageTwoValidation() {
    if (!faceImgValidated) {
      errorMessage("Debes subir una selfie.");
    } else if (!idImgValidated) {
      errorMessage("Debes subir una foto de tu cédula.");
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
            height: screenInfo.size.height * 0.70,
            padding: EdgeInsets.all(10),
            child: Card(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Nombre del negocio',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: screenInfo.size.width * 0.045,
                              fontFamily: 'Kanit',
                            ),
                          ),
                          TextField(
                            controller: businessName,
                            onChanged: (text) {
                              setState(() {
                                fixBusinessName = false;
                              });
                            },
                            decoration: InputDecoration(
                                hintText: 'Ej: Zerdaly',
                                hintStyle: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: screenInfo.size.width * 0.045,
                                ),
                                errorText: fixBusinessName
                                    ? "Este nombre de negocio ya esta en uso. "
                                    : null),
                          ),
                          Spacer(),
                          Text(
                            'Número de teléfono',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: screenInfo.size.width * 0.045,
                              fontFamily: 'Kanit',
                            ),
                          ),
                          TextField(
                            controller: businessPhone,
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
                            'Dirección del negocio',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: screenInfo.size.width * 0.045,
                              fontFamily: 'Kanit',
                            ),
                          ),
                          TextField(
                            controller: businessDirection,
                            decoration: InputDecoration(
                              hintText: 'Ej: Calle quita, edificio...',
                              hintStyle: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: screenInfo.size.width * 0.045,
                              ),
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
                                            fontSize:
                                                screenInfo.size.width * 0.045),
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
                                        fontSize:
                                            screenInfo.size.width * 0.045),
                                  )),
                            ],
                          )
                        ])))),
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
                        fontSize: screenInfo.size.width / 19),
                  ),
                ),
              ),
            ),
          ),
          onTap: () async {
            pageThreeValidation();
          },
        )
      ],
    );
  }

  pageThreeValidation() async {
    if (businessName.text.isEmpty ||
        businessPhone.text.isEmpty ||
        businessDirection.text.isEmpty ||
        city == null) {
      errorMessage("Por favor, completa todos los campos.");
    } else if (businessName.text.length < 4) {
      errorMessage("El nombre del negocio debe tener por lo menos 4 letras.");
    } else if (businessPhone.text.length > 10 ||
        businessPhone.text.length < 10) {
      errorMessage("El número de telefono debe tener 10 digitos.");
    } else if (businessDirection.text.length < 10) {
      errorMessage(
          "La dirección del negocio debe tener por lo menos 10 letras.");
    } else {
      if (userLocation == null) {
        userLocation = await location.getLocation();
      }
      setState(() {
        page = 4;
      });
    }
  }

  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.addListener(onMapChanged);
  }

  void onMapChanged() {
    setState(() {
      getMapPosition();
    });
  }

  void getMapPosition() {
    businessLocation = mapController.cameraPosition.target;
  }

  @override
  void dispose() {
    if (mapController != null) {
      mapController.removeListener(onMapChanged);
    }
    super.dispose();
  }

  Widget pageFour() {
    return Container(
        width: screenInfo.size.width,
        height: screenInfo.size.height,
        child: Stack(
          children: <Widget>[
            MapboxMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(userLocation.latitude, userLocation.longitude),
                zoom: 14,
              ),
              trackCameraPosition: true,
              rotateGesturesEnabled: false,
              myLocationEnabled: false,
              myLocationTrackingMode: MyLocationTrackingMode.None,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    width: screenInfo.size.width,
                    height: screenInfo.size.height / 7,
                    child: Card(
                      child: Center(
                          child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text(
                          "Lleva el marcador a donde se encuetra tu negocio.",
                          style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: screenInfo.size.width / 21),
                          textAlign: TextAlign.center,
                        ),
                      )),
                    ),
                  ),
                ),
              ],
            ),
            Center(
                child: Icon(
              Icons.location_on,
              color: Color.fromRGBO(255, 144, 82, 1),
              size: screenInfo.size.width / 9,
            )),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                child: Container(
                  width: screenInfo.size.width / 3,
                  height: screenInfo.size.height / 14,
                  child: Center(
                    child: Card(
                      color: Color.fromRGBO(255, 144, 82, 1),
                      child: Center(
                        child: Text(
                          'Continuar',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Kanit',
                              fontSize: screenInfo.size.width / 19),
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  setState(() {
                    page = 5;
                  });
                },
              ),
            )
          ],
        ));
  }

  Widget pageFive() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10, left: 10),
            child: Text(
              'Tu negocio es de:',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Kanit',
                  fontSize: screenInfo.size.width * 0.045),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: Row(
                children: <Widget>[
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      width: screenInfo.size.width * 0.38,
                      height: screenInfo.size.height * 0.23,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: category == "Accesorios"
                                  ? Colors.white
                                  : Color.fromRGBO(255, 144, 82, 1),
                              width: 4)),
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Spacer(),
                            Text(
                              "Accesorios",
                              style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.grey[600],
                                  fontSize: screenInfo.size.width * 0.045),
                            ),
                            Icon(
                              Icons.headset,
                              size: screenInfo.size.width * 0.24,
                              color: Color.fromRGBO(255, 144, 82, 1),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        category = "Accesorios";
                      });
                    },
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      width: screenInfo.size.width * 0.38,
                      height: screenInfo.size.height * 0.23,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: category == "Belleza"
                                  ? Colors.white
                                  : Color.fromRGBO(255, 144, 82, 1),
                              width: 4)),
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Spacer(),
                            Text(
                              "Belleza",
                              style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.grey[600],
                                  fontSize: screenInfo.size.width * 0.045),
                            ),
                            Icon(
                              Icons.color_lens,
                              size: screenInfo.size.width * 0.24,
                              color: Color.fromRGBO(255, 144, 82, 1),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        category = "Belleza";
                      });
                    },
                  ),
                  Spacer(),
                ],
              )),
          Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: Row(
                children: <Widget>[
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      width: screenInfo.size.width * 0.38,
                      height: screenInfo.size.height * 0.23,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: category == "Comida"
                                  ? Colors.white
                                  : Color.fromRGBO(255, 144, 82, 1),
                              width: 4)),
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Spacer(),
                            Text(
                              "Comida",
                              style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.grey[600],
                                  fontSize: screenInfo.size.width * 0.045),
                            ),
                            Icon(
                              Icons.fastfood,
                              size: screenInfo.size.width * 0.24,
                              color: Color.fromRGBO(255, 144, 82, 1),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        category = "Comida";
                      });
                    },
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      width: screenInfo.size.width * 0.38,
                      height: screenInfo.size.height * 0.23,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: category == "Vestimentas"
                                  ? Colors.white
                                  : Color.fromRGBO(255, 144, 82, 1),
                              width: 4)),
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Spacer(),
                            Text(
                              "Vestimentas",
                              style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.grey[600],
                                  fontSize: screenInfo.size.width * 0.045),
                            ),
                            Icon(
                              Icons.accessibility_new,
                              size: screenInfo.size.width * 0.23,
                              color: Color.fromRGBO(255, 144, 82, 1),
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        category = "Vestimentas";
                      });
                    },
                  ),
                  Spacer(),
                ],
              )),
          Padding(
            padding: EdgeInsets.only(top: 10, left: 10),
            child: Text(
              'Tiempo de envío promedio:',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Kanit',
                  fontSize: screenInfo.size.width * 0.045),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: Row(
                children: <Widget>[
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      width: screenInfo.size.width * 0.38,
                      height: screenInfo.size.height * 0.08,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: shippingTime == "30 mins"
                                  ? Colors.white
                                  : Color.fromRGBO(255, 144, 82, 1),
                              width: 4)),
                      child: Card(
                          child: Center(
                        child: Text(
                          "30 mins",
                          style: TextStyle(
                              fontFamily: 'Kanit',
                              color: Colors.grey[600],
                              fontSize: screenInfo.size.width * 0.045),
                        ),
                      )),
                    ),
                    onTap: () {
                      setState(() {
                        shippingTime = "30 mins";
                      });
                    },
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      width: screenInfo.size.width * 0.38,
                      height: screenInfo.size.height * 0.08,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: shippingTime == "60 mins"
                                  ? Colors.white
                                  : Color.fromRGBO(255, 144, 82, 1),
                              width: 4)),
                      child: Card(
                          child: Center(
                        child: Text(
                          "60 mins",
                          style: TextStyle(
                              fontFamily: 'Kanit',
                              color: Colors.grey[600],
                              fontSize: screenInfo.size.width * 0.045),
                        ),
                      )),
                    ),
                    onTap: () {
                      setState(() {
                        shippingTime = "60 mins";
                      });
                    },
                  ),
                  Spacer(),
                ],
              )),
          Padding(
              padding: EdgeInsets.only(
                top: 10,
              ),
              child: Row(
                children: <Widget>[
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      width: screenInfo.size.width * 0.38,
                      height: screenInfo.size.height * 0.08,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: shippingTime == "1 a 12 horas"
                                  ? Colors.white
                                  : Color.fromRGBO(255, 144, 82, 1),
                              width: 4)),
                      child: Card(
                          child: Center(
                        child: Text(
                          "1 a 12 h",
                          style: TextStyle(
                              fontFamily: 'Kanit',
                              color: Colors.grey[600],
                              fontSize: screenInfo.size.width * 0.045),
                        ),
                      )),
                    ),
                    onTap: () {
                      setState(() {
                        shippingTime = "1 a 12 horas";
                      });
                    },
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      width: screenInfo.size.width * 0.38,
                      height: screenInfo.size.height * 0.08,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: shippingTime == "12 a 24 horas"
                                  ? Colors.white
                                  : Color.fromRGBO(255, 144, 82, 1),
                              width: 4)),
                      child: Card(
                          child: Center(
                        child: Text(
                          "12 a 24 h",
                          style: TextStyle(
                              fontFamily: 'Kanit',
                              color: Colors.grey[600],
                              fontSize: screenInfo.size.width * 0.045),
                        ),
                      )),
                    ),
                    onTap: () {
                      setState(() {
                        shippingTime = "12 a 24 horas";
                      });
                    },
                  ),
                  Spacer(),
                ],
              )),
          Padding(
            padding: EdgeInsets.only(top: 12),
          ),
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
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
                pageFiveValidation();
              },
            ),
          )
        ]);
  }

  pageFiveValidation() {
    if (category == null) {
      errorMessage("Elige una categoría.");
    } else if (shippingTime == null) {
      errorMessage("Elige un tiempo de entrega.");
    } else {
      setState(() {
        page = 6;
      });
    }
  }

  Widget pageSix() {
    return Container(
      padding: EdgeInsets.all(10),
      width: screenInfo.size.width,
      height: screenInfo.size.height,
      child: Card(
          child: Column(
        children: <Widget>[
          Center(
            child: Text(
              "Zerdaly",
              style: TextStyle(
                color: Color.fromRGBO(255, 144, 82, 1),
                fontFamily: 'Pacifico',
                fontSize: screenInfo.size.width * 0.12,
              ),
            ),
          ),
          Center(
            child: Text(
              "Para negocios",
              style: TextStyle(
                color: Color.fromRGBO(255, 144, 82, 1),
                fontFamily: 'Kanit',
                fontSize: screenInfo.size.width * 0.05,
              ),
            ),
          ),
          Center(
            child: Text(
              "Te regala:",
              style: TextStyle(
                color: Color.fromRGBO(255, 144, 82, 1),
                fontFamily: 'Kanit',
                fontSize: screenInfo.size.width * 0.045,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "30 dias de prueba gratis,",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Kanit',
                    fontSize: screenInfo.size.width * 0.045,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              Text(
                " luego:",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Kanit',
                  fontSize: screenInfo.size.width * 0.045,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "\$499",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Kanit',
                    fontSize: screenInfo.size.width * 0.05,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              Text(
                "/al mes",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Kanit',
                  fontSize: screenInfo.size.width * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Center(
            child: Text(
              "Para mantener la cuenta activa.",
              style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'Kanit',
                  fontSize: screenInfo.size.width * 0.045,
                  fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: <Widget>[
                Text(
                  "* ",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Kanit',
                      fontSize: screenInfo.size.width * 0.04,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Puedes publicar todos tus productos.",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Kanit',
                    fontSize: screenInfo.size.width * 0.035,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: <Widget>[
                Text(
                  "* ",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Kanit',
                      fontSize: screenInfo.size.width * 0.035,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Procesar tarjetas visa, mastercard, etc.",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Kanit',
                    fontSize: screenInfo.size.width * 0.035,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              children: <Widget>[
                Text(
                  "* ",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Kanit',
                      fontSize: screenInfo.size.width * 0.04,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Enviar tus productos de forma gratuita.",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Kanit',
                    fontSize: screenInfo.size.width * 0.035,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Puedes ",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Kanit',
                  fontSize: screenInfo.size.width * 0.045,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "procesar pagos ",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Kanit',
                    fontSize: screenInfo.size.width * 0.045,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "a una ",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Kanit',
                  fontSize: screenInfo.size.width * 0.045,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "tasa ",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Kanit',
                    fontSize: screenInfo.size.width * 0.045,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              Text(
                "de: ",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: 'Kanit',
                  fontSize: screenInfo.size.width * 0.045,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 2),
          ),
          Center(
            child: Text(
              "4.9% + \$15",
              style: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'Kanit',
                  fontSize: screenInfo.size.width * 0.045,
                  fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Text(
              " por transacción.",
              style: TextStyle(
                color: Colors.grey[500],
                fontFamily: 'Kanit',
                fontSize: screenInfo.size.width * 0.045,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 3),
          ),
          Center(
            child: Column(children: <Widget>[
              Text(
              'Al registrarme estoy de acuerdo con los ',
              style: TextStyle(
                color: Colors.grey[500],
                fontFamily: 'Kanit',
                fontSize: screenInfo.size.width * 0.025,
              ),
              textAlign: TextAlign.center,
            ),
            GestureDetector(child: Text(
              'Terminos y Condiciones.',
              style: TextStyle(
                color: Colors.orange,
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
          Padding(
            padding: EdgeInsets.only(top: 5),
          ),
          !registerProcess
              ? Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
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
                    onTap: () {
                      register();
                    },
                  ),
                )
              : Center(child: CircularProgressIndicator()),
        ],
      )),
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
  int categoryId = 1;
  register() async {
    setState(() {
      registerProcess = true;
    });
    switch (category) {
      case "Accesorios":
        categoryId = 1;
        break;
      case "Belleza":
        categoryId = 2;
        break;
      case "Comida":
        categoryId = 3;
        break;
      case "Vestimentas":
        categoryId = 4;
        break;
    }

    await CompressImage.compress(imageSrc: faceImg.path, desiredQuality: 85);
    await CompressImage.compress(imageSrc: idImg.path, desiredQuality: 85);

    String bs64FaceImg = base64Encode(faceImg.readAsBytesSync());
    String bs64IdImg = base64Encode(idImg.readAsBytesSync());

    setState(() {});

    Business business = new Business();
    var data = {
      'owner_name': name.text,
      'business_name': businessName.text,
      'email': email.text.toLowerCase().toString(),
      'password': password.text,
      'dob': bday.text.toString() +
          "/" +
          bmonth.text.toString() +
          "/" +
          byear.text.toString(),
      'city': city,
      'phone': businessPhone.text.toString(),
      'category_id': categoryId.toString(),
      'shipping_delay': shippingTime,
      'direction_details': businessDirection.text,
      'latitude': businessLocation.latitude.toString(),
      'longitude': businessLocation.longitude.toString(),
      'id_image': bs64IdImg,
      'face_image': bs64FaceImg,
    };
    final result = await business.register(data);

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
      } else if (result[2]["business_name"] != null) {
        fixBusinessName = true;
        page = 3;
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
      Token.columnKind: "Business",
      Token.columnAuth: auth
    };

    final id = await token.insert(row);

    if (id != null) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BusinessGeneral()));
    }
  }
}
