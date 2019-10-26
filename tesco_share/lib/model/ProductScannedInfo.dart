import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:tesco_share/Constants.dart';

class ApiDataScanned{
String description;
String brand;

ApiDataScanned(this.description, this.brand);

ApiDataScanned.clone(ApiDataScanned data) : this(data.description, data.brand);

factory ApiDataScanned.fromJson(Map<String, dynamic> json) {
  return ApiDataScanned(
    json['description'],
    json['brand']
  );
}
}

class ProductScannedInfo{
  ApiDataScanned apiData;
  String barcode;
  DateTime expiryDate;
  DateTime useByDate;
  bool canBeFrozen;
  String category;
  int quantity;

  bool isValid(){
    bool valid = true;

    if(barcode == null ||  barcode.trim() == ""){
      return false;
    }

    if(expiryDate != null){
      valid = valid && _IsEarlyerOrToday(DateTime.now(),expiryDate.add(new Duration(days: 1)));
    }

    if(useByDate != null){
      if(_IsEarlyerOrToday(DateTime.now(),useByDate))
      {
        if(_isEqual(useByDate,DateTime.now())){
          valid = valid && canBeFrozen;
        }else{
          valid = false;
        }
      }
    }

    valid = valid && (expiryDate != null || useByDate != null);

    return valid && quantity >=1;
  }


  _isEqual(DateTime a, DateTime b){
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  _IsEarlyerOrToday(DateTime a, DateTime b){
    if(a.year > b.year){
      return false;
    }

    if(a.month > b.month){
      return false;
    }

    if(a.day > b.day){
      return false;
    }

    return true;
  }

  Future<ProductScannedInfo> GetProductData() async {
    if(this.apiData != null){
      return this;
    }

    final response = await http.get('https://dev.tescolabs.com/product/?gtin=${this.barcode}', headers: {"Ocp-Apim-Subscription-Key": "abb267cda5ed4e089d9d94fb3d4f50c8"});

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      this.apiData = ApiDataScanned.fromJson(json.decode(response.body)['products'][0]);
      return this;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post; ${response.statusCode}');
    }
  }

  ProductScannedInfo(){
    this.quantity = 1;
    this.category = categories[0];
  }

  ProductScannedInfo.clone(ProductScannedInfo info){
    this.barcode = info.barcode;
    this.expiryDate = info.expiryDate;
    this.useByDate = info.useByDate;
    this.canBeFrozen = info.canBeFrozen;
    this.quantity = info.quantity;
    this.apiData = ApiDataScanned.clone(info.apiData);
    this.category = info.category;
  }
}