import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tesco_share/Constants.dart';
import 'package:tesco_share/REST.dart';
import 'package:tesco_share/model/Product.dart';
import 'package:tesco_share/model/ProductScannedInfo.dart';

import 'ScannedProductView.dart';

class ScannedProductsView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => ScannedProductsViewState();
}

class ScannedProductsViewState extends State<ScannedProductsView> {

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
                    _productList(),
                    Container(
                        margin: const EdgeInsets.only(bottom: 10, top: 10),
                        child:
                        RaisedButton(
                          shape: RoundedRectangleBorder(

                          borderRadius: BorderRadius.circular(32),
                        ), padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                          color: lightColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Text("Checkout"),
                            Icon(Icons.check)
                          ],), onPressed: _sendItems,)
                        )],
                ),
              ),
            )]
        ));
  }

  void _sendItems(){
    for(ProductScannedInfo productScannedInfo in scannedProducts)
     {
       Product product = new Product(productScannedInfo.apiData == null? productScannedInfo.barcode : productScannedInfo.apiData.description, "", productScannedInfo.quantity, productScannedInfo.barcode);
       REST.addProduct(product);
     }
    scannedProducts.clear();
    setState(() {

    });
  }


  void _scanItem(context){
    Navigator.push(context,MaterialPageRoute(
        builder: (context) => ScannedProductView()
    ));
  }

  Widget _productList(){
    return Expanded(child:ListView.separated(
      itemCount: scannedProducts.length+1,
      itemBuilder: (context, index) {
        if(scannedProducts.length > index) {
          return Dismissible(
            // Show a red background as the item is swiped away.
            background: Container(color: Colors.red),
            key: Key(scannedProducts[index].barcode),
            onDismissed: (direction) {
              setState(() {
                scannedProducts.removeAt(index);
              });
            },
            child: ListTile(
              title: Text(_displayName(scannedProducts[index])),
              subtitle: Text('Quantity: ${scannedProducts[index].quantity}'),
              trailing: Icon(Icons.edit),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) =>
                        ScannedProductView.Edit(scannedProducts[index], index)
                ));
              },
            ),
            confirmDismiss: (DismissDirection direction) async {
              final bool res = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text(
                        "Are you sure you wish to delete this item?"),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("DELETE")
                      ),
                      FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                      ),
                    ],
                  );
                },
              );
              return res;
            },
          );
        }
        else{
         return Row(
           mainAxisAlignment: MainAxisAlignment.center,
           mainAxisSize: MainAxisSize.min,
           children: <Widget>[Container(margin: EdgeInsets.all(5),height: 60,child: RaisedButton(
             shape: RoundedRectangleBorder(

               borderRadius: BorderRadius.circular(32),
             ), padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
             color: lightColor,
             child: Row(
               children: <Widget>[
                 Text("Scan new item"),
                 Icon(Icons.add)
               ],
             ), onPressed: ()=> _scanItem(context),),)
            ],)
                  ;
        }
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    ))  ;
  }

  String _displayName(ProductScannedInfo scannedProduct){
     if(scannedProduct.apiData == null){
       scannedProduct.GetProductData().then((bcinfo){
         setState(() {

         });
       });
       return scannedProduct.barcode;
     }else{
       return '${scannedProduct.apiData.brand} - ${scannedProduct.apiData.description}';
     }

  }
}
