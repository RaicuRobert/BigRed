import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tesco_share/REST.dart';
import 'package:tesco_share/model/Shop.dart';

import 'dart:convert';
import '../Constants.dart';
import 'CategoryList.dart';

import 'package:http/http.dart' as http;

import 'GoogleMap.dart';

class CharityMainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => CharityMainPageState();

}

class CharityMainPageState extends State<CharityMainPage>{
  List<Shop> stores ;

  CharityMainPageState(){
    getDumbStores();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(title: Text("Save a Meal")),
        backgroundColor: Colors.white,
        body: Container(
        child: Column(
        mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 100,),
        Image(image: AssetImage("images/tesco-logo.png"), width: 300,),
        SizedBox(height:10),
        Center(
          child: Text("stores nearby", style:TextStyle(fontSize: 20, fontFamily: 'Poppins', color: darkColor, fontWeight: FontWeight.w600)),
        ),
        _content()
      ]
    )
    ),
      floatingActionButton: FloatingActionButton(child: Image.asset('images/google-maps.png'), backgroundColor: lightColor,
      onPressed: _toMap,),
    );
  }

  void _toMap(){
    Navigator.push(context,MaterialPageRoute(
        builder: (context) => MapSample()
    ));
  }

  Widget _content(){
    if(stores == null){
     return _onLoading();
    }else{
     return _storeList();
    }
  }


  Widget _storeList(){
    return Container(
      height: 600,
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: ListView.builder(
          itemCount: stores.length,
          itemBuilder: (context, index) => ListTile(
              contentPadding: EdgeInsets.only(top: 10, left: 20),
              leading: Icon(Icons.shopping_cart, color: Colors.red,),
              title: Text(stores[index].name, style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
              subtitle: Text(stores[index].distance),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) => CategoryList()
                  ))
          )
      ),
      color: Colors.white,

    );
  }

  Widget _onLoading() {
    return new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              new CircularProgressIndicator(),
              new Text("Loading"),
            ],
          );
  }

  void getDumbStores() {
    if(shops.length == 0){
      REST.getShops().then((value) {
        setState(() {
          stores = shops;
          print(stores.length);
        });
      });
      return;
    }

    stores = shops;
  }



}