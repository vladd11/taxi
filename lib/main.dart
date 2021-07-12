import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

import 'api.dart';
import 'profile.dart';
import 'support.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Api api;
  MapApi mapApi;
  List<Product> products;
  MapController mapController;
  LocationData locationData;
  LatLng oldPosition;

  bool _enabled;
  bool _permission;
  int selected;

  bool _selectStreet;
  bool _order;

  String _street;

  String _paymentMethod;

  Timer timer;

  @override
  void initState() {
    super.initState();
    mapController = MapController();

    api = FakeApi();
    mapApi = IMapApi();
    _paymentMethod = "cash";
    init();
    setupTimer();
    getProducts();
  }

  void setupTimer() {
    timer = Timer.periodic(Duration(seconds: 8), (timer) async {
      if (oldPosition != mapController.center) {
        String address = await mapApi.getAddressByLatLng(mapController.center);
        setState(() {
          _street = address;
        });
      }
      oldPosition = mapController.center;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void getProducts() async {
    try {
      List<Product> _products = await api.getProducts();
      setState(() => products = _products);
    } catch (_) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Test')));
    }
  }

  void init() async {
    Location location = Location();
    _enabled = await location.serviceEnabled();
    if (!_enabled) {
      _enabled = await location.requestService();
    }

    if (_enabled) {
      _permission = await location.hasPermission() == PermissionStatus.granted;
      if (_permission) {
        _permission =
            await location.requestPermission() == PermissionStatus.granted;
      }
    }

    if (_permission) {
      locationData = await location.getLocation();
      location.onLocationChanged.listen((event) {
        setState(() => {
          locationData = event
        });
        mapController.move(LatLng(locationData.latitude, locationData.longitude), 12);
      });
    }
  }

  Future<void> checkout() async {
    try {
      await FakeApi()
          .checkout(Order(
              product: products[selected],
              streetName: _street,
              location: mapController.center,
              price: products[selected].price))
          .then((value) => _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text(''))))
          .catchError((e) => _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text('Нет подключения к интернету'))));
    } catch (_) {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Нет подключения к интернету')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Stack(
            children: [
              (_order == true)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding:
                                EdgeInsets.only(top: 8, bottom: 8, left: 8),
                            child: Text('Заказ',
                                style: Theme.of(context).textTheme.headline6)),
                        Container(
                          width: size.width,
                          child: DropdownButton(
                              items: [
                                DropdownMenuItem<String>(
                                    child: Container(
                                        padding: EdgeInsets.only(left: 8),
                                        width: size.width - 30,
                                        child: Text('Наличными')),
                                    value: 'cash'),
                                DropdownMenuItem<String>(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Text('Электронными')),
                                    value: 'electronic')
                              ],
                              onChanged: (value) {
                                setState(() => _paymentMethod = value);
                              },
                              value: _paymentMethod),
                        ),
                      ],
                    )
                  : Container(height: 0),
              (_order == true)
                  ? Container(height: 0)
                  : Container(
                      height: 100,
                      child: (products == null)
                          ? Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                Product product = products[index];
                                String name = product.name;
                                String imageUrl = product.imageUrl;
                                String price = product.price.toString();
                                return Container(
                                  height: 250,
                                  width: size.width / 3,
                                  child: Stack(
                                    children: [
                                      Card(
                                          shape: (selected == index)
                                              ? RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  side: BorderSide(
                                                      color: Colors.blue))
                                              : null,
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                CachedNetworkImage(
                                                    imageUrl: imageUrl,
                                                    height: 25),
                                                Text('$name',
                                                    textAlign:
                                                        TextAlign.center),
                                                Text('$price руб',
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .caption),
                                              ])),
                                      Positioned.fill(
                                          child: Material(
                                              color: Colors.transparent,
                                              child: Padding(
                                                padding: EdgeInsets.all(4),
                                                child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    onTap: () => setState(() {
                                                          if (selected == index)
                                                            selected = -1;
                                                          else
                                                            selected = index;
                                                        })),
                                              )))
                                    ],
                                  ),
                                );
                              },
                              scrollDirection: Axis.horizontal,
                            ))
            ],
          )),
      body: Stack(children: [
        FlutterMap(
            mapController: mapController,
            options: MapOptions(
                center: LatLng(53.13, 50.11),
                zoom: 12,
                minZoom: 8,
                maxZoom: 18),
            layers: [
              TileLayerOptions(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c']),
              CircleLayerOptions(circles: [
                (locationData == null)
                    ? CircleMarker()
                    : CircleMarker(
                        point: LatLng(
                            locationData.latitude, locationData.longitude),
                        useRadiusInMeter: true,
                        radius: locationData.accuracy,
                        color: Colors.blue.withAlpha(50))
              ]),
              MarkerLayerOptions(markers: [
                (locationData == null)
                    ? Marker()
                    : Marker(
                        width: 20,
                        height: 20,
                        point: LatLng(
                            locationData.latitude, locationData.longitude),
                        builder: (context) => Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withAlpha(200))),
                      )
              ]),
            ]),
        // Marker to address
        Center(child: Icon(Icons.gps_not_fixed, size: 20)),
        //  Top view
        SafeArea(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                flex: 1,
                child: FlatButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage())),
                    child: Icon(Icons.person))),
            Flexible(
              flex: 3,
              child: FlatButton(
                onPressed: () => setState(() => _selectStreet = true),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text("Ваш адрес:"),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: Text((_street == null) ? "Поиск..." : _street,
                            maxLines: 999,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline6),
                      );
                    },
                  ),
                ]),
              ),
            ),
            Flexible(
                flex: 1,
                child: FlatButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SupportPage())),
                    child: Icon(Icons.help))),
          ],
        )),
        // Select street menu
        (_selectStreet == true)
            ? Column(
                children: [
                  SafeArea(
                    child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: "Адрес",
                              contentPadding: EdgeInsets.only(left: 8)),
                          onSubmitted: (address) => moveByAddress(address),
                        )),
                  ),
                  FlatButton(
                      onPressed: () => setState(() => _selectStreet = false),
                      child: Icon(Icons.keyboard_arrow_up))
                ],
              )
            : Container(),
      ]),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          (_order == true)
              ? FloatingActionButton(
                  onPressed: () {
                    setState(() => _order = false);
                  },
                  child: Icon(Icons.close),
                )
              : Container(height: 0),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: FloatingActionButton(
              onPressed: () {
                if (_order == true) {
                  checkout();
                }
                setState(() => _order = true);
              },
              child: Icon(Icons.shopping_cart),
              backgroundColor: (_order == true) ? Colors.green : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> moveByAddress(String address) async {
    LatLng latLng = await mapApi.getLatLngByAddress(address);
    mapController.onReady.then((value) => mapController.move(latLng, 16));
  }

  Future<void> updateStreet() async {
    String address = await mapApi.getAddressByLatLng(mapController.center);
    setState(() => _street = address);
  }
}
