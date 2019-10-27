import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tesco_share/Constants.dart';
import 'package:tesco_share/pages/CategoryList.dart';

class Deliveries extends StatefulWidget {

  var delivery;

  Deliveries(this.delivery);

  @override
  State<Deliveries> createState() => DeliveriesState(this.delivery);
}

class DeliveriesState extends State<Deliveries> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  var delivery;

  DeliveriesState(this.delivery);

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(47.4754267,19.0979369),
      tilt: 0,
      zoom: 10.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Nearby shops"),

      ),
      body: GoogleMap(
        initialCameraPosition: _kLake,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {

          _controller.complete(controller);

          setState(() {
            _markers.add(Marker(
              // This marker id can be anything that uniquely identifies each marker.
              markerId: MarkerId( delivery['from']),
              position:  delivery['latlng_from'],
              infoWindow: InfoWindow(
                  title: delivery['from'],

                  snippet: delivery['observations']
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(200),
            ));
            _markers.add(Marker(
              // This marker id can be anything that uniquely identifies each marker.
              markerId: MarkerId( delivery['to']),
              position:  delivery['latlng_to'],
              infoWindow: InfoWindow(
                  title: delivery['to'],
                  snippet: delivery['observations']
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          });
        },
      )
    );
  }


}