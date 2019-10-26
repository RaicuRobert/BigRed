import 'package:flutter/material.dart';

import '../Constants.dart';
import 'CategoryList.dart';

class CharityMainPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => CharityMainPageState();

}

class CharityMainPageState extends State<CharityMainPage>{

  List<String> stores = getDumbStores();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      appBar: AppBar(title: Text("Save a Meal")),
        backgroundColor: Colors.white,
        body: Container(
        child: Column(

      children: [
        SizedBox(height: 50,),
        Image(image: AssetImage("images/tesco-logo.png"), width: 300,),
        SizedBox(height:10),
        Center(
          child: Text("stores nearby", style:TextStyle(fontSize: 20, fontFamily: 'Poppins', color: darkColor, fontWeight: FontWeight.w600)),
        ),
        Container(
          height: 600,
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: ListView.builder(
            itemCount: stores.length,
            itemBuilder: (context, index) => ListTile(
                                      contentPadding: EdgeInsets.only(top: 20, left: 20),
                                      leading: Icon(Icons.shopping_cart, color: Colors.red,),
                                      title: Text(stores[index], style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
                                      onTap: () => Navigator.push(context,
                                          MaterialPageRoute(
                                              builder: (context) => CategoryList()
                                          ))
                                      )
        ),
          color: Colors.white,

        ),
      ]
    )
    )
    );
  }

  static getDumbStores() {
    var stores = List<String>();  // list with addresses
    stores.add("Budapest, Kálvin tér 7, 1091");
    stores.add("Budapest, Bajza u. 1, 1071");
    stores.add("Budapest, Rákóczi út 20, 1072");
    stores.add("Budapest, Rákóczi út 1-3, 1088");
    stores.add("Budapest, VI. kerület, Teréz krt 55-57, 1062");
    stores.add("Budapest, Koppány u. 2-4, 1097");

    return stores;
  }

}