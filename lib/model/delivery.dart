import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Delivery {
  final url = 'https://api.zerdaly.com/api/delivery/';

  Future<List> login(String email, String pass) async {
    List response = new List(3);
    await http.post(url + 'login', body: {
      'json': json.encode({
        'email': email,
        'password': pass,
      }).toString(),
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result['code'];
      response[1] = result['status'];
      response[2] = result['token'];
    });
    return response;
  }

  Future<List> register(var data) async {
    List response = new List(5);

    await http
        .post(url + "register", body: {'json': json.encode(data)}).then((res) {
      final data = json.decode(res.body);
      response[0] = data["code"];
      response[1] = data["status"];
      response[2] = data["errors"];
      response[3] = data["message"];
      response[4] = data["token"];
    }).catchError((error) {});
    return response;
  }

  Future<List> update(var data, String token) async {
    List response = new List(3);

    await http.put(url + "update", body: {
      'json': data,
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);

      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> uploadDeliveryImage(String img, String token) async {
    List response = new List(3);
    await http.post(url + "upload", body: {
      'json': json.encode({
        'image': img,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["image"];
    }).then((error) {});

    return response;
  }

  Future<List> info(String token) async {
    List response = new List(6);
    await http.post(url + "info",
        headers: {HttpHeaders.authorizationHeader: token}).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["delivery"];
      response[2] = result["delivery_shippings"];
      response[3] = result["delivery_orders"];
      response[4] = result["delivery_contact"];
      response[5] = result["delivery_likes"];
    }).catchError((error) {});

    return response;
  }

  Future<bool> newBank(String bankName, String bankType, String bankNumber,
      String bankHolder, String token) async {
    bool status = false;
    await http.post(url + "new/bank", body: {
      'json': json.encode({
        'bank_name': bankName,
        'account_type': bankType,
        'account_holder': bankHolder,
        'account_number': bankNumber,
      }),
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      if (res.statusCode == 200) {
        status = true;
      }
    }).catchError((error) {});

    return status;
  }



  Future<List> getUser(int id, String token) async {
    List response = new List(3);
    await http.post("https://api.zerdaly.com/api/user/getuser", body: {
      'json': json.encode({
        'id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> getUserLocation(int id, String token) async {
    List response = new List(3);
    await http.post("https://api.zerdaly.com/api/user/getlocation", body: {
      'json': json.encode({
        'id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> getBusiness(int id, String token) async {
    List response = new List(3);
    await http.post("https://api.zerdaly.com/api/business/getbusiness", body: {
      'json': json.encode({
        'id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> getOrder(int id, String token) async {
    List response = new List(3);
    await http.post(url + "get/order", body: {
      'json': json.encode({
        'order_id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> takeOrder(int id, String token) async {
    List response = new List(3);
    await http.put(url + "take/order", body: {
      'json': json.encode({
        'order_id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

  Future<List> arrivedOnBusiness(int id, String token) async {
    List response = new List(3);
    await http.put(url + "arrived/on/business", body: {
      'json': json.encode({
        'order_id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }
//find error here
  Future<List> onWayToCustomer(int id, String token) async {
    List response = new List(3);
    await http.put(url + "on/way/to/customer", body: {
      'json': json.encode({
        'order_id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }

    Future<List> arrivedOnCustomer(int id, String token) async {
    List response = new List(3);
    await http.put(url + "arrived/on/customer", body: {
      'json': json.encode({
        'order_id': id,
      })
    }, headers: {
      HttpHeaders.authorizationHeader: token
    }).then((res) {
      final result = json.decode(res.body);
      response[0] = result["code"];
      response[1] = result["status"];
      response[2] = result["message"];
    }).then((error) {});

    return response;
  }
}
