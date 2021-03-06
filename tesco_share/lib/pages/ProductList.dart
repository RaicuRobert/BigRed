import 'dart:ui' as prefix0;

import 'package:flutter/material.dart';
import 'package:tesco_share/REST.dart';
import 'package:tesco_share/model/Product.dart';

import 'package:tesco_share/Constants.dart';


class ProductList extends StatefulWidget{

  String category;
  ProductList(this.category);

  @override
  ProductListState createState() => ProductListState(category);
}

class ProductListState extends State<ProductList>{
  String category;
  ProductListState(this.category);
  bool iconPressed = false;
  var products;
  bool showRequests = false;
  var str = "Available";

  @override
  Widget build(BuildContext context) {

    var notificationIcon = Icon(iconPressed ? Icons.notifications_active : Icons.notifications);

    if (showRequests == false){
      if (products == null)
        {
          initializeProductsFromServer();
          return Scaffold(
              appBar: AppBar(
                title: Text("$category"),
                actions: <Widget>[
                  // Notify Button
                  IconButton(
                    icon: notificationIcon,
                    onPressed: () {
                      setState(() {
                        iconPressed = !iconPressed;
                      });
                    },
                  )
                ],
              ),
            body: Center(
              child: CircularProgressIndicator(backgroundColor: lightColor,)
            )
          );

        }
    }
    else {
      if (products == null) {
        initializeAcquiredProductsFromServer();
        return Scaffold(
            appBar: AppBar(
              title: Text("$category"),
              actions: <Widget>[
                // Notify Button
                IconButton(
                  icon: notificationIcon,
                  onPressed: () {
                    setState(() {
                      iconPressed = !iconPressed;
                    });
                  },
                )
              ],
            ),
            body: Center(
                child: CircularProgressIndicator(backgroundColor: lightColor,)
            )
        );
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("$category"),
          actions: <Widget>[
            // Notify Button
            IconButton(
              icon: notificationIcon,
              onPressed: () {
                setState(() {
                  iconPressed = !iconPressed;
                });
              },
            )
          ],
        ),
//        drawer: MainDrawer(),
//        floatingActionButton: FloatingActionButton(
//          onPressed: acquireProduct,
//          child: Icon(Icons.add),
//          foregroundColor: Colors.white,
//          backgroundColor: darkColor,
//        ),
        body: Column(
            children: <Widget>[
              SwitchListTile(
//            inactiveThumbColor: darkColor,
                inactiveTrackColor: darkColor,
                inactiveThumbColor: darkColor,
                title: Text(str, style: TextStyle(color: Colors.black, fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 18.0)),
                value: showRequests,
                onChanged:(bool value) {
                  setState((){
                    showRequests = value;
                  });
                  var newProducts;
                  if (showRequests == true){
                    initializeAcquiredProductsFromServer();
                    setState(() {
                      str = "Already requested";
                    });
                  }
                  else{
                    initializeProductsFromServer();
                    setState(() {
                      str = "Available";
                    });
                  }
                  print("New products: " + newProducts.toString());
                  setState(() => {
                    products = newProducts
                  });

                },)
              ,Flexible(
                child: new Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 10),
//                  color: Colors.white,
                  child: new ListView.builder(
                    //itemExtent: 300.0, // THIS IS THE HEIGHT OF THE ITEM!!!!
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (_, index) => new ProductRow(products[index]),
                  ),
                ),
              )])
    );
  }

  void initializeProductsFromServer() {
    Future<List<Product>> allProductsFuture;
    if (category != 'All Products')
      allProductsFuture = REST.getProductsByCategory(category);
    else
      allProductsFuture = REST.getAllProducts();
    allProductsFuture.then((allProducts){
      setState(() {
        this.products = allProducts;
      });
    });
  }

  void initializeAcquiredProductsFromServer(){
    Future<List<Product>> allProductsFuture;
    if (category != 'All Products')
      allProductsFuture = REST.getRequestedProductsInCategory(category);
    else
      allProductsFuture = REST.getRequestedProducts(category);
    allProductsFuture.then((allProducts){
      setState(() {
        this.products = allProducts;
      });
    });
  }
}


class ProductRow extends StatefulWidget {
  Product product;
  ProductRow(this.product);

  @override
  State<StatefulWidget> createState() => ProductRowState(product);
}
class ProductRowState extends State<ProductRow>{
  Product product;

  ProductRowState(this.product);

  @override
  Widget build(BuildContext context) {
    final planetThumbnail = new Container(
        alignment: new FractionalOffset(0.0, 0.5),
        margin: const EdgeInsets.only(top: 10.0),
        child: new Container(
          width: 60.0,
          height: 60.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image:  AssetImage("images/${product.name}.jpg")
            ),
          ),
        )
    );

    final planetCard = new Container(
        width: 550,
        height: 90,
        margin: const EdgeInsets.only(left: 3.0, right: 3.0),
        decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: new BorderRadius.circular(10.0),
        ),
        child: Container(
            height: 100,
            margin: const EdgeInsets.only(top: 16.0, left: 60.0, right: 10),
            constraints: new BoxConstraints.expand(),
            child: new Column(

              children: <Widget>[Align(alignment: Alignment.topLeft,child:Text(this.product.name, style: TextStyle(color: Colors.black,
                  fontSize: 18.0))
              ),
                SizedBox(height:6),
                Align(alignment: Alignment.topLeft,child:Text(" X "+ product.quantity.toString(), style: TextStyle(color: darkColor,
                    fontSize: 13.0)
                )),
                SizedBox(height:5),
//                Text("Some other text", style: TextStyle(color: Colors.white,
//                    fontSize: 14.0, fontWeight: FontWeight.w400)
//                )
              ],
            )
        )
    );

    return new Container(
//        height: 100.0,
      margin: const EdgeInsets.only(top: 10.0, bottom: 8.0),
      child: new FlatButton(
        onPressed: () => {
          acquireProduct(product, context)
        },
        child: new Stack(
          children: <Widget>[
            planetCard,
            planetThumbnail,
          ],
        ),
      ),
    );
  }

  void acquireProduct(Product product, context) async{
    double number = await showDialog<double>(
      context: context,
      builder: (context) => QuantityPickerDialog(product)
    );
    var no = number.toInt();
    if (no != null){
      setState(() {
        this.product.quantity -= no;
//        if (this.product.quantity == 0)
//          this.product = null;
      });
    }
    print(number);
//    initState();
    setState(() {
    });

  }

}

class QuantityPickerDialog extends StatefulWidget {
  Product product;

  QuantityPickerDialog(this.product);
  @override
  State<StatefulWidget> createState() {
    return QuantityPickerDialogState();
  }

}

class QuantityPickerDialogState extends State<QuantityPickerDialog>{
  double number = 1;
  Product product;


  @override
  void initState(){
    super.initState();
    product = widget.product;
  }
  @override
  Widget build(BuildContext context) {

    Widget widget;

    if (product.quantity > 1)
      widget = Slider(
        value: number.toDouble(),
        min: 1,
        max: product.quantity.toDouble(),
        divisions: product.quantity-1,
        onChanged: (value) {
          setState((){
            number = value.toDouble();
          });
        },
      );
    else
      widget = SizedBox(height: 2,);
    return AlertDialog(
      title: Text('How many products?'),
      content: Container(
        height:80,
        child: Column(
          children:[
          widget,
            Text(number.toInt().toString())
          ],
    )
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            child: Text('Close')),
        FlatButton(
          onPressed: () {
            // RESERVE THE PRODUCT
            REST.acquireProduct(product.name, number.toInt());
            Navigator.pop(context, number);
//            initState();
//            Navigator.push(context,
//                MaterialPageRoute(
//                    builder: (context) => ProductList(product.category)
//                ));
          },
          child: Text('Reserve!'),
        )
      ],
    );
  }
}