import 'package:flutter/material.dart';
import 'package:tesco_share/model/ProductScannedInfo.dart';

var darkColor = MaterialColor(0xFF7DB419, const<int, Color>{
  50: _dark,
  100: _dark,
  200: _dark,
  300: _dark,
  400: _dark,
  500: _dark,
  600: _dark,
  700: _dark,
  800: _dark,
  900: _dark,

});
//var lightColor = Colors.lightGreenAccent;

Color lightColor = MaterialColor(0xFFA4E30D, const<int, Color>{
  50:_color,
  100:_color,
  200:_color,
  300:_color,
  400:_color,
  500:_color,
  600:_color,
  700:_color,
  800:_color,
  900:_color
});

const _color = Color(0xFFA4E30D);
const _dark = Color(0xFF7DB419);
//MaterialColor lightColor = MaterialColor(0x49f540, color);

var logoPath = "images/logo_transparent.png";

List<ProductScannedInfo> scannedProducts = new List<ProductScannedInfo>();