import 'package:flutter/material.dart';
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

    if (showRequests == true){
      products = getDumbProducts();
    }
    else {
      products = getDumbProducts();
    }

    var notificationIcon = Icon(iconPressed ? Icons.notifications_active : Icons.notifications);
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
        floatingActionButton: FloatingActionButton(
          onPressed: acquireProduct,
          child: Icon(Icons.add),
          foregroundColor: Colors.white,
          backgroundColor: darkColor,
        ),
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
                    newProducts = getDumbProducts();
                    setState(() {
                      str = "Already requested";
                    });
                  }
                  else{
                    newProducts = getDumbProducts();
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
                  color: Colors.white,
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

  List<Product> getDumbProducts() {
    var products = List<Product> ();
    products.add(Product("Banana"));
    products.add(Product("Chicken wings"));
    products.add(Product("Tomato"));
    products.add(Product("Milk"));

    return products;
  }



  void acquireProduct() {
  }
}

class ProductRow extends StatelessWidget{
  final Product product;

  ProductRow(this.product);

  @override
  Widget build(BuildContext context) {
    final planetThumbnail = new Container(
        alignment: new FractionalOffset(0.0, 0.5),
        margin: const EdgeInsets.only(top: 10.0, left: 260),
        child: new Container(
          width: 80.0,
          height: 80.0,
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
        height: 140,
        margin: const EdgeInsets.only(left: 3.0, right: 3.0),
        decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: new BorderRadius.circular(10.0),
            color: darkColor
        ),
        child: Container(
            height: 100,
            margin: const EdgeInsets.only(top: 16.0, left: 45.0, right: 10),
            constraints: new BoxConstraints.expand(),
            child: new Column(

              children: <Widget>[Align(alignment: Alignment.topLeft,child:Text(this.product.name, style: TextStyle(color: Colors.white,
                  fontSize: 25.0, fontWeight: FontWeight.w400))
              ),
                SizedBox(height:5),
                Align(alignment: Alignment.topLeft,child:Text("Quantity: "+ "5", style: TextStyle(color: Colors.white,
                    fontSize: 16.0)
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
//        onPressed: () => {
//          Navigator.push(context,
//              MaterialPageRoute(
//                  builder: (context) => MessageScreen(product)
//              ))
//        },
        child: new Stack(
          children: <Widget>[
            planetCard,
            planetThumbnail,
          ],
        ),
      ),
    );
  }


}