import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tesco_share/model/Product.dart';

class REST{
  static String url = "http://192.168.100.56:4001";
  static var client = http.Client();

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
}