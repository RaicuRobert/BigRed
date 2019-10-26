import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:intl/intl.dart';
import 'package:tesco_share/ProductScan/ScannedProducts.dart';
import 'package:tesco_share/model/Product.dart';
import 'package:tesco_share/model/ProductScannedInfo.dart';
import 'package:tesco_share/Constants.dart';


class ScannedProductView extends StatefulWidget {
  ProductScannedInfo product;
  int index;

  ScannedProductView();
  ScannedProductView.Edit(this.product, this.index);

  @override
  ScannedProductViewState createState() {
    if(product != null){
      return ScannedProductViewState.Edit(product, index);
    }
    return ScannedProductViewState();
  }
}

class ScannedProductViewState extends State<ScannedProductView> {
  final _formKey = GlobalKey<FormState>();
  ProductScannedInfo _productScannedInfo = new ProductScannedInfo();
  int _index;
  bool _isEdit;
  TextEditingController _barcodeController = new TextEditingController();
  TextEditingController _quantityController = new TextEditingController();


  DateFormat format = new DateFormat("dd.MM.yy");
  DateFormat formatFull = new DateFormat("dd.MM.yyyy");

  ScannedProductViewState.Edit(ProductScannedInfo product, int index){
    _productScannedInfo = ProductScannedInfo.clone(product);
    _index = index;
    _isEdit = true;
    _barcodeController.value = new TextEditingValue(text: _productScannedInfo.barcode);
    _quantityController.value = new TextEditingValue(text: _productScannedInfo.quantity.toString());
  }

  ScannedProductViewState(){
    _isEdit = false;
    _productScannedInfo.canBeFrozen = false;
    _productScannedInfo.quantity = 1;
    _quantityController.value = new TextEditingValue(text: _productScannedInfo.quantity.toString());
  }

  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: Text('Product details')),
        body: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Builder(
                builder: (context) => Form(
                    key: _formKey,
                    child:LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                            child: ConstrainedBox(
                            constraints: BoxConstraints(
                             minHeight: viewportConstraints.maxHeight,
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _barcodeField(),
                                  SizedBox(height: 25.0,),
                                  Text("Use by date"),
                                  _useByDateTimeField(),
                                  SizedBox(height: 25.0,),
                                  Text("Expiry date"),
                                  _expiryDateTimeField (),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                                    child: Text('Extra Details'),
                                  ),
                                  SwitchListTile(
                                      title: const Text('Can be frozen?'),
                                      value: _productScannedInfo.canBeFrozen,
                                      onChanged: (bool val) =>
                                          setState(() => _productScannedInfo.canBeFrozen = val)),
                                  SizedBox(
                                      width: 300,
                                      child:Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                                        child: TextFormField(
                                          keyboardType: TextInputType.numberWithOptions(),
                                          controller: _quantityController,
                                          decoration:
                                          InputDecoration(labelText: 'Quantity'),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please enter the quantity';
                                            }
                                          },
                                          onSaved: (val) =>
                                              setState(() => _productScannedInfo.quantity = int.parse(val)),
                                        ),)),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 16.0),
                                      child: RaisedButton(
                                          onPressed: _getButtonFunctionality,
                                          child: Text(_productScannedInfo.isValid() ? 'Save' : 'Invalid'))),
                            ])));})))));
      }
  _showDialog(BuildContext context) {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Submitting form')));
  }

  void _getButtonFunctionality(){
      bool isValid = _productScannedInfo.isValid();
      final form = _formKey.currentState;

      if(isValid == false){
        Navigator.pop(context);
        return;
      }

      if(_isEdit == true){
        form.save();
        scannedProducts.removeAt(_index);
        scannedProducts.insert(_index, _productScannedInfo);
        Navigator.pop(context);
        return;
      }



      if (form.validate()) {
        form.save();
        scannedProducts.add(_productScannedInfo);
        Navigator.push(context,MaterialPageRoute(
            builder: (context) => ScannedProductsView()
        ));
        //_user.save();
        //_showDialog(context);

        return;
      }
  }


  Future<Null>  _barcodeFieldCheck() async{
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

      setState(() => {
        _productScannedInfo.barcode = barcodes.first.rawValue,
        _barcodeController.value = new TextEditingValue(text: _productScannedInfo.barcode)
      });
  }


  _useByDateTimeFieldCheck(){
    _scanOcr().then((str){
      DateTime time = format.parse(str);
      setState(() =>  this._productScannedInfo.useByDate =new DateTime(time.year + 2000, time.month, time.day));
    });
  }

  _expiryDateTimeFieldCheck(){
    _scanOcr().then((str){
      DateTime time = format.parse(str);
      setState(() =>  this._productScannedInfo.expiryDate =new DateTime(time.year + 2000, time.month, time.day));
    });
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

  Widget _barcodeField(){
    return Row(children: <Widget>[
      SizedBox(
        width: 300,
        child:Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
          child: TextFormField(
            controller: _barcodeController,
        decoration:
        InputDecoration(labelText: 'Barcode'),
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter the barcode';
          }
        },
        onSaved: (val) =>
            setState(()
                {_productScannedInfo.barcode = val;
                _productScannedInfo.apiData = null;}),
      ),)),
      Container(
          width: 60,
          height: 50,
          child: RaisedButton(
            onPressed: _barcodeFieldCheck,
            child: Icon(Icons.photo_camera),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 4.0,
            color: Colors.white,))


    ],);
  }

  Widget _useByDateTimeField (){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _useByDateTimePicker(),
        Container(
            width: 60,
            height: 50,
            child: RaisedButton(
            onPressed: _useByDateTimeFieldCheck,
            child: Icon(Icons.photo_camera),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            elevation: 4.0,
            color: Colors.white,))

      ],
    );
  }

  Widget _expiryDateTimeField (){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _expiryDateTimePicker(),
        Container(
        width: 60,
        height: 50,
          child: RaisedButton(
            onPressed: _expiryDateTimeFieldCheck,
            child: Icon(Icons.photo_camera),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0)),
        elevation: 4.0,
        color: Colors.white,))
          ],
    );
  }

  Widget _useByDateTimePicker(){
    return  SizedBox(
        width: 300,
        child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              elevation: 4.0,
              onPressed: () {
                DatePicker.showDatePicker(context,
                    theme: DatePickerTheme(
                      containerHeight: 210.0,
                    ),
                    showTitleActions: true,
                    minTime: DateTime(2000, 1, 1),
                    maxTime: DateTime(2022, 12, 31), onConfirm: (date) {
                      setState(() {
                        print('confirm $date');
                        _productScannedInfo.useByDate = date;});
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: Container(
                alignment: Alignment.center,
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.date_range,
                                size: 18.0,
                                color: Colors.teal,
                              ),
                              Text(
                                  _productScannedInfo.useByDate == null? "Not set" :  formatFull.format(_productScannedInfo.useByDate),
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(
                      "  Change",
                      style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                  ],
                ),
              ),
              color: Colors.white,
            )
          ],
        ),
      ),
    ));
  }

  DateTime CheckCurrentTime(ProductScannedInfo product){
    if(product.useByDate == null)
      return DateTime.now();
    else
      return product.useByDate;
  }

  Widget _expiryDateTimePicker(){
    return SizedBox(
        width: 300,
        child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              elevation: 4.0,
              onPressed: () {
                DatePicker.showDatePicker(context,
                    theme: DatePickerTheme(
                      containerHeight: 210.0,
                    ),
                    showTitleActions: true,
                    minTime: DateTime(2000, 1, 1),
                    maxTime: DateTime(2022, 12, 31), onConfirm: (date) {
                      setState(() {
                        print('confirm $date');
                        _productScannedInfo.expiryDate = date;});
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: Container(
                alignment: Alignment.center,
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.date_range,
                                size: 18.0,
                                color: Colors.teal,
                              ),
                              Text(
                                _productScannedInfo.expiryDate == null? "Not set" : formatFull.format(_productScannedInfo.expiryDate),
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Text(
                      "  Change",
                      style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                  ],
                ),
              ),
              color: Colors.white,
            )
          ],
        ),
      ),
    ));
  }
}