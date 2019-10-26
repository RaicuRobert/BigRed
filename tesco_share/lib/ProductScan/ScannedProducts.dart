import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tesco_share/Constants.dart';

import 'ScannedProductView.dart';

class ScannedProductsView extends StatelessWidget {

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: Text("Scanned Products"),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: _buildBar(context),
        body: Column(
            children: <Widget>[Flexible(
              child: new Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    FlatButton(child: Text("Scan new item"), onPressed: ()=> _scanItem(context),),
                    _productList()
                  ],
                ),
              ),
            )]
        ));
  }

  void _scanItem(context){
    Navigator.push(context,MaterialPageRoute(
        builder: (context) => ScannedProductView()
    ));
  }

  Widget _productList(){
    return Expanded(child:ListView.separated(
      itemCount: scannedProducts.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(scannedProducts[index].barcode),
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    ))  ;
  }
}
