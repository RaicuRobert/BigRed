import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:tesco_share/model/Product.dart';
import 'package:web_socket_channel/io.dart';

import 'Constants.dart';
import 'model/Shop.dart';

class REST{
  static String url = "http://104.248.20.49:4001";
  static var client = http.Client();
  static var channel = new IOWebSocketChannel.connect('ws://104.248.20.49:4001/svc/websockets');


  static HashMap<String, bool> notificationFilter = new HashMap<String, bool>();
  static StreamController notificationDoneController = new StreamController.broadcast();

  static void startListening() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('logo');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload){
          if (payload != null) {
            debugPrint('notification payload: ' + payload);
          }
        });


    channel.stream.listen(
            (message) async{
          print("Received message from websocket: $message");


          List<Product> products = new List<Product>();

        Product pr =Product.fromJson(json.decode(message));
          products.add(pr);


          if(notificationFilter[pr.category] == true)
          {
            var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
                '1', 'ROB', 'Charity',
                importance: Importance.Max, priority: Priority.High);
            var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
            var platformChannelSpecifics = new NotificationDetails(
                androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
            await flutterLocalNotificationsPlugin.show(
                0, 'New inventory available', 'based on prefences', platformChannelSpecifics,
                payload: 'item id 2');
          }


          notificationDoneController.add(products);
        },
        onError: (error, StackTrace stackTrace) {
          // error handling
        },
        onDone: () {
          // communication has been closed
        });
  }



  static Future<List<Product>> getAllProducts() async {
    List<Product> products = List<Product>();

    final response = await client.get(url + '/all');
    var respData = json.decode(response.body);
    products = getProductsFromJson(respData);
    
    return products;
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    List<Product> products = List<Product>();

    final response = await client.get(url + '/category/' + category);
    var respData = json.decode(response.body);
    products = getProductsFromJson(respData);

    return products;
  }

  static Future<List<Product>> getRequestedProductsInCategory(String category) async {
    List<Product> products = List<Product>();

    final response = await client.get(url + '/requestedInCategory/' + category);
    var respData = json.decode(response.body);
    products = getProductsFromJson(respData);

    return products;
  }

  static Future<List<Product>> getRequestedProducts(String category) async {
    List<Product> products = List<Product>();

    final response = await client.get(url + '/requested');
    var respData = json.decode(response.body);
    products = getProductsFromJson(respData);

    return products;
  }



  static Future addProduct(Product product) async {
    await client.post(url + "/addProduct/", body: { 'name': product.name, 'quantity': product.quantity.toString(), 'category': product.category, 'barcode': product.barcode});
  }

  static Future acquireProduct(String name, int quantity) async {
    print('Acquiring $quantity pieces of $name');
    await client.post(url + '/delete/', body: {'name': name, 'quantity': quantity.toString()});
  }

  static List<Product> getProductsFromJson(respData) {
    List<Product> products = List<Product>();
    for (var prod in respData){
      var name = prod['name'];
      var category = prod['category'];
      var quantity = prod['quantity'];
      var barcode = prod['barcode'];
      var product = Product(name, category, quantity, barcode);
      products.add(product);
    }

    return products;
  }

  static Future<void> getShops() async{
    final response = await http.get('https://dev.tescolabs.com/locations/search?sort=near: "47.4754267,19.0979369"', headers: {"Ocp-Apim-Subscription-Key": "d8bc2a3938d54c03a415206c8a02223c"});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      for(var data in json.decode(response.body)['results']) {
        var geo = data['location']['geo']['coordinates'];
        double long = geo['longitude'];
        double latitude =geo['latitude'];
        String name = data['location']['name'];
        String distance = '${data['distanceFrom']['value']} ${data['distanceFrom']['unit']}';

        Shop shop = new Shop(name, distance, latitude, long);

        shops.add(shop);
      }

    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post; ${response.statusCode}');
    }
  }
}