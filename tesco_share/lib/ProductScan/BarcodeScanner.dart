import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import './barcode_detail.dart';

class BarcodeScanner extends StatefulWidget {
  @override
  _BarcodeScannerState createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  var _barcodes;


  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start();
  }

  @override
  Widget build(BuildContext context) {
    return _getBarcodeScreen(context);


  }
  ///
  /// Barcode Screen
  ///
  Widget _getBarcodeScreen(BuildContext context) {
    List<Widget> items = [];

    items.add(
      new Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          bottom: 12.0,
        ),
        child: new RaisedButton(
          onPressed: _scan,
          child: new Text('SCAN!'),
        ),
      ),
    );

    items.addAll(
      ListTile.divideTiles(
        context: context,
        tiles: _barcodes
            .map(
              (barcode) => new BarcodeWidget(barcode),
        )
            .toList(),
      ),
    );

    return new ListView(
      padding: const EdgeInsets.only(
        top: 12.0,
      ),
      children: items,
    );
  }

  ///
  /// Barcode Method
  ///
  Future<Null> _scan() async {
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
      barcodes.add(new Barcode('Failed to get barcode.'));
    }

    if (!mounted) return;

    setState(() => _barcodes = barcodes);
  }
}
///
/// BarcodeWidget
///
class BarcodeWidget extends StatelessWidget {
  final Barcode barcode;

  BarcodeWidget(this.barcode);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      leading: const Icon(Icons.star),
      title: new Text(barcode.displayValue),
      subtitle: new Text(
        '${barcode.getFormatString()} (${barcode.format}) - '
            '${barcode.getValueFormatString()} (${barcode.valueFormat})',
      ),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (context) => new BarcodeDetail(barcode),
        ),
      ),
    );
  }
}
