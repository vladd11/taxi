import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:latlong/latlong.dart';

class Api {
  Future<void> checkout(Order order) {
    throw UnimplementedError();
  }

  Future<List<Product>> getProducts() {
    throw UnimplementedError();
  }

  Future<Profile> getProfile() {
    throw UnimplementedError();
  }

  Future<void> support({@required String email, String text}) {
    throw UnimplementedError();
  }
}

/*class IApi implements Api {
  static const server_url = "https://vlad.pythonanywhere.com/taxi/";
  static const checkout_url = server_url + "checkout";
  static const products_url = server_url + "products";
  User user;

  IApi(this.user);

  @override
  Future<void> checkout(Product product) async {
    return http.post(checkout_url, body: json.encode(product.toJson()));
  }

  @override
  Future<List<Product>> getProducts() async {
    http.Response response = await http.get(products_url);
    if (response.statusCode == 200) {
      List<Product> products = [];
      List<Map<String, dynamic>> list = [];
      for (Map<String, dynamic> map in list) {
        products.add(Product.fromJson(map));
      }
      return products;
    } else {
      throw HttpException(response.statusCode);
    }
  }
}*/

class FakeApi implements Api {
  @override
  Future<void> checkout(Order order) async {

  }

  @override
  Future<List<Product>> getProducts() async {
    return [
      Product('Test', "https://logo.clearbit.com/google.com",
          Decimal.parse("100.1001"))
    ];
  }

  @override
  Future<Profile> getProfile() async {
    return Profile(
        'User',
        'https://logo.clearbit.com/google.com',
        List.generate(
            3,
            (index) => Order(
                product: Product(
                    "name",
                    "https://logo.clearbit.com/google.com?size=64",
                    Decimal.parse("2.5")),
                status: 0,
                price: Decimal.parse('22.5'),
                location: LatLng(53.13, 50.11),
                streetName: 'Утевская улица')));
  }

  @override
  Future<void> support({@required String email, String text}) async {}
}

class MapApi {
  Future<String> getAddressByLatLng(LatLng latLng) {
    throw new UnimplementedError();
  }

  Future<LatLng> getLatLngByAddress(String address) {
    throw new UnimplementedError();
  }
}

class IMapApi implements MapApi {
  http.Client client = MapClient();
  static const String email = '&email=rozhkov.2006@gmail.com';

  @override
  Future<String> getAddressByLatLng(LatLng latLng) async {
    String lat = latLng.latitude.toString();
    String lng = latLng.longitude.toString();
    http.Response response = await client.get(
        "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng$email");
    Map<String, dynamic> address = jsonDecode(response.body)['address'];
    if(address == null) {
      if (latLng.latitude > 180) {
        if (latLng.longitude > 180) {
          return 'Широта ${(latLng.latitude/2).toStringAsFixed(6)}, ${(latLng.longitude/2).toStringAsFixed(6)}';
        } else {
          return '${(latLng.latitude/2).toStringAsFixed(6)} северной широты, ${(latLng.longitude/2).toStringAsFixed(6)} южной долготы';
        }
      } else {
        if (latLng.longitude > 180) {
          return '${(latLng.latitude/2).toStringAsFixed(6)} южной широты, ${(latLng.longitude/2).toStringAsFixed(6)} северной долготы';
        } else {
          return '${(latLng.latitude/2).toStringAsFixed(6)} южной широты, ${(latLng.longitude/2).toStringAsFixed(6)} южной долготы';
        }
      }
    }

    String road = address['road'];
    String num = address['house_number'];

    if (road == null) {
      road = address['suburb'];
      if (road == null) {
        road = address['city'];
        if (road == null) {
          road = address['state'];
          if (road == null) {
            if (latLng.latitude > 180) {
              if (latLng.longitude > 180) {
                return '${(latLng.latitude/2).toStringAsFixed(6)} северной широты, ${(latLng.longitude/2).toStringAsFixed(6)} северной долготы';
              } else {
                return '${(latLng.latitude/2).toStringAsFixed(6)} северной широты, ${(latLng.longitude/2).toStringAsFixed(6)} южной долготы';
              }
            } else {
              if (latLng.longitude > 180) {
                return '${(latLng.latitude/2).toStringAsFixed(6)} южной широты, ${(latLng.longitude/2).toStringAsFixed(6)} северной долготы';
              } else {
                return '${(latLng.latitude/2).toStringAsFixed(6)} южной широты, ${(latLng.longitude/2).toStringAsFixed(6)} южной долготы';
              }
            }
          }
        }
      }
    }

    if (num == null) {
      return '$road';
    }

    return '$road $num';
  }

  @override
  Future<LatLng> getLatLngByAddress(String address) async {
    http.Response response = await http.get(
        "https://nominatim.openstreetmap.org/search?street=$address&format=json$email");
    Map<String, dynamic> map = jsonDecode(response.body)[0];
    return LatLng(double.parse(map['lat']), double.parse(map['lon']));
  }
}

class MapClient extends http.BaseClient {
  http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(BaseRequest request) {
    request.headers['user-agent'] = 'DemoTaxiApp/1.0';
    return _inner.send(request);
  }
}

class HttpException implements Exception {
  int code;

  HttpException(this.code);

  @override
  String toString() {
    return 'HttpException: $code response code';
  }
}

class User {}

class Product {
  String name;
  String imageUrl;
  Decimal price;

  Product(this.name, this.imageUrl, this.price);

  Product.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        imageUrl = json['image_url'],
        price = Decimal.parse(json['price']);

  Map<String, dynamic> toJson() =>
      {'name': name, 'imageUrl': imageUrl, 'price': price.toString()};
}

class Profile {
  String name;
  String avatarUrl;
  List<Order> orders;

  Profile(this.name, this.avatarUrl, this.orders);

  Profile.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        avatarUrl = json['avatarUrl'],
        orders = [
          for (var i = 0; i < json['orders'].length; i++)
            Order.fromJson(json['orders'].get(i))
        ];

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatarUrl': avatarUrl,
        'orders': [for (var i = 0; i < orders.length; i++) orders[i].toJson()]
      };
}

class Order {
  Product product;
  int status;
  Decimal price;
  LatLng location;
  String streetName;

  Order(
      {@required this.product,
      this.status,
      @required this.price,
      @required this.location,
      @required this.streetName});

  Order.fromJson(Map<String, dynamic> json)
      : product = Product.fromJson(json['product']),
        status = json['status'],
        price = Decimal.parse(json['price']),
        location = stringToLatLng(json['location']),
        streetName = json['streetName'];

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'status': status,
        'price': price.toString(),
        'location':
            '${location.latitude.toString()};${location.longitude.toString()}',
        'streetName': streetName
      };

  String statusAsString() {
    switch (status) {
      case -1:
        return 'Обработка';
      case 0:
        return 'В очреди доставки';
      case 1:
        return 'В пути';
      case 2:
        return 'Доставлен';
      case 3:
        return 'Отменен';
      default:
        return 'Не указан';
    }
  }
}

LatLng stringToLatLng(String string) {
  List<String> strings = string.split(';');
  return LatLng(double.parse(strings[0]), double.parse(strings[1]));
}
