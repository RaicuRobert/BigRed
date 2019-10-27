import 'package:flutter/material.dart';
import 'package:tesco_share/Constants.dart';

import 'package:tesco_share/ProductScan/ScannedProducts.dart';

import 'package:tesco_share/pages/CategoryList.dart';
import 'package:tesco_share/pages/CharityMainPage.dart';

import '../REST.dart';

class Login extends StatefulWidget{

  @override
  LoginState createState() => LoginState();

}

class LoginState extends State<Login>{

  LoginState(){
    REST.startListening();
  }

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final logo = Image(
      image: AssetImage(logoPath)
      , height: 250, fit: BoxFit.fitHeight,
    );

    final username = Container(
        child:TextFormField(
          controller: usernameController,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Username',
            contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
        ),
        margin: const EdgeInsets.only(right: 20, left: 20)
    );

    final password =  Container(
        child:TextFormField(
          controller: passwordController,
          autofocus: false,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
        ),
        margin: const EdgeInsets.only(right: 20, left: 20)
    );

    final loginButton = Container(
      child: Container(
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            onPressed: () {
              logIn();
            },
            padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            color: lightColor,
            child: Text('Log In', style: TextStyle(color: Colors.black),
            ),
          )
      ),
      margin: const EdgeInsets.only(right: 20, left: 20),);

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );


    return Scaffold(
        body: SafeArea(
            child: Container(

                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 24.0, right: 24.0, top: 50),
                  children: <Widget>[
                    logo,
                    SizedBox(height: 50.0),
                    username,
                    SizedBox(height: 20.0),
                    password,
                    SizedBox(height: 30.0),
                    loginButton,
                    SizedBox(height: 15),
                    forgotLabel,
                  ],
                )
            )
        )
    );
  }

  void logIn() async{

    //bool succeeded = await REST.tryToLogIn(usernameController.text, passwordController.text);
    bool succeeded = true;
    print("Succeeded to log in?  " + succeeded.toString());
    if (usernameController.value.text == 'charity')  // if this is a legit user, redirect to the main page and set a sort of cookie or whatevs
      {
      Navigator.push(context,
          MaterialPageRoute(
              builder: (context) => CharityMainPage()
          )
      );
    }

    if (usernameController.value.text == 'shop')  // if this is a legit user, redirect to the main page and set a sort of cookie or whatevs
        {
      Navigator.push(context,
          MaterialPageRoute(
              builder: (context) => ScannedProductsView()
          )
      );
    }
  }


}