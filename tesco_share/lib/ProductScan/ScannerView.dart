import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:tesco_share/model/ProductScannedInfo.dart';


enum Step {
  ScanBarcode,
  UseBy,
  DisplayBeforeUntil
}


class ScannerView extends StatefulWidget {
  @override
  _ScannerViewState createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  ProductScannedInfo _product;
  int _step;

@override
  void initState() {
    super.initState();
    FlutterMobileVision.start();
    setState(() {
      _step = 0;
      _product = new ProductScannedInfo();
    });
  }
  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: Text("Scanner"),
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
                child: _Tree(BuildContext),
              ),
            )]
        ));

  }

  String _getCurrentStep(){
    switch(_step){
      case 0: return "Scan Barcode"; break;
      case 1: return "Does it have a UseBy date?"; break;
      case 2: return "Does it have a DisplayBefore or BestUntil date?"; break;
      default: return "None";
    }
  }

  Widget _Tree(BuildContext){
      if(_step >=3){
        return _checkData();
      }
      else{
        return _questionScreen(context);
      }
  }

  Widget _questionScreen(BuildContext context){
      return Center(child: Column(
        children: <Widget>[
          Text(_getCurrentStep()),
          ButtonBar(children: <Widget>[
            FlatButton(child: Text("No"),color: Colors.red, onPressed: _skipStep),
            FlatButton(child: Text("Yes"),color: Colors.green, onPressed: _doStep,)
          ],)
        ],
      ),);
  }

  void _doStep(){
    switch(_step){
      case 0: _scanBarcode(); break;
      case 1: _scanOcr().then((str) => setState(() => this._product.useByDate = str )); break;
      case 2: _scanOcr().then((str) => setState(() => this._product.expiryDate = str ));  break;
    }
    _skipStep();
  }

  void _skipStep(){
    setState(() {
      _step = _step+1;
    });
  }
  ///
  /// Barcode Method
  ///
  Future<Null> _scanBarcode() async {
    List<Barcode> barcodes = [];
    try {
      barcodes = await FlutterMobileVision.scan(
        flash: false,
        autoFocus: true,
        formats: Barcode.ALL_FORMATS,
        multiple: false,
        waitTap: false,
        showText: false,
        preview: FlutterMobileVision.getPreviewSizes(FlutterMobileVision.CAMERA_BACK).first,
        camera: FlutterMobileVision.CAMERA_BACK,
        fps: 15.0,
      );
    } on Exception {
    }

    if (!mounted) return;

    setState(() => _product.barcode = barcodes.first.rawValue);
  }

  Future<String> _scanOcr() async {
    List<OcrText> texts = [];
    RegExp regExp = new RegExp("[0-9]+\.[0-9]+\.[0-9]+");
    try {
      texts = await FlutterMobileVision.read(
        flash: false,
        autoFocus: true,
        multiple: false,
        waitTap: true,
        showText: true,
        preview: FlutterMobileVision.getPreviewSizes(FlutterMobileVision.CAMERA_BACK).first,
        camera: FlutterMobileVision.CAMERA_BACK,
        fps: 2.0,
      );
    } on Exception {
    }

    if (!mounted) return null;
    return texts.map((text) => regExp.firstMatch(text.value).group(0)).first;
  }
 Widget _checkData(){
   return Column(children: <Widget>[
     Text(_product.barcode),
     Text(_product.useByDate),
     Text(_product.expiryDate)
   ]);
 }
}
