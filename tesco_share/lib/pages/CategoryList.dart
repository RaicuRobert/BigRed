import 'package:flutter/material.dart';
import 'package:tesco_share/pages/ProductList.dart';

import 'package:tesco_share/Constants.dart';


class CategoryList extends StatefulWidget{
  @override
  CategoryListState createState() => CategoryListState();
}

class CategoryListState extends State<CategoryList>{


  String _searchText = "";
  var _filtered_categories = new List();
  var _searchIcon = Icon(Icons.search);
  Widget _appBarTitle = new Text("All Categories");
  final TextEditingController _filter = new TextEditingController();

  CategoryListState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          this._searchText = "";
          this._filtered_categories = categories;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });

    _filtered_categories = categories;
  }

  Widget _buildList() {
    if (_searchText.isNotEmpty) {
      List tempList = new List();
      for (int i = 0; i < _filtered_categories.length; i++) {
        if (_filtered_categories[i].toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(_filtered_categories[i]);
        }
      }
      _filtered_categories = tempList;
    }

    return GridView.count(
      crossAxisCount: 2,

      padding: const EdgeInsets.all(4),
//      mainAxisSpacing: 1,
//      crossAxisSpacing: 4,
        children:_filtered_categories.map((f) => new CategoryRow(f)).toList()
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          autofocus: true,
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search...'
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('All Categories');
        _filtered_categories = categories;
        _filter.clear();
      }
    });
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: _buildBar(context),

        body:
              new Container(
                color: Colors.white,
                child: _buildList(),
              ),

        );

  }

}

class CategoryRow extends StatelessWidget{
  final String category;

  CategoryRow(this.category);

  @override
  Widget build(BuildContext context) {
    final planetThumbnail = new Container(
        alignment: new FractionalOffset(0.0, 0.5),
        margin: const EdgeInsets.only(left: 60.0),
        child: new Container(
          width: 50.0,
          height: 50.0,
          decoration: new BoxDecoration(
//            shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image:  AssetImage("images/${this.category}.png")
                  ),
          ),
        )
    );

    final planetCard = new Container(
        height: 140,
        margin: const EdgeInsets.only(left: 5.0, right: 5.0),
        decoration: new BoxDecoration(
          color: lightColor,
          shape: BoxShape.rectangle,
          borderRadius: new BorderRadius.circular(20.0),
        ),
        child: Container(
//            height: 100,
            margin: const EdgeInsets.only(top: 25.0, left: 30.0, right: 18),
            constraints: new BoxConstraints.expand(),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[Text(category, style: TextStyle(color: Colors.white, fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0)
              )],
            )
        )
    );

    return new Container(
//        height: 100.0,
      margin: const EdgeInsets.only(top: 20.0, bottom: 1.0),
      child: new FlatButton(
        onPressed: () => {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => ProductList(category)
                ))

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

}