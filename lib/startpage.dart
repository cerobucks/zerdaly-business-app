import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Login/businessLogin.dart';

class StartPage extends StatefulWidget {
  @override
  StartPageState createState() => StartPageState();
}

class StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData screenInfo = MediaQuery.of(context);

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
            body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Color.fromRGBO(255, 144, 82, 1)),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Zerdaly",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Pacifico',
                      fontSize: screenInfo.size.width / 6,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 3),
                  ),
                  Text(
                    "Elige tu tipo de cuenta:",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Kanit',
                      fontSize: screenInfo.size.width / 20,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        child: Container(
                            width: screenInfo.size.width / 3,
                            height: screenInfo.size.height / 4.5,
                            child: Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Spacer(),
                                  Text(
                                    "Negocio",
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 144, 82, 1),
                                      fontFamily: 'Kanit',
                                      fontSize: screenInfo.size.width / 18,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.business_center,
                                    color: Color.fromRGBO(255, 144, 82, 1),
                                    size: screenInfo.size.width / 5,
                                  ),
                                  Spacer(),
                                ],
                              ),
                            )),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> BusinessLogin()));
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                      ),
                      GestureDetector(
                        child: Container(
                            width: screenInfo.size.width / 3,
                            height: screenInfo.size.height / 4.5,
                            child: Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Spacer(),
                                  Text(
                                    "Delivery",
                                    style: TextStyle(
                                      color: Color.fromRGBO(255, 144, 82, 1),
                                      fontFamily: 'Kanit',
                                      fontSize: screenInfo.size.width / 18,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.motorcycle,
                                    color: Color.fromRGBO(255, 144, 82, 1),
                                    size: screenInfo.size.width / 5,
                                  ),
                                  Spacer(),
                                ],
                              ),
                            )),
                        onTap: () {
                          print("delivery");
                        },
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        )));
  }
}
