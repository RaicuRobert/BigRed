import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tesco_share/Constants.dart';
import 'package:tesco_share/pages/CategoryList.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

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
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('Find shops'),
        icon: Icon(Icons.location_on),
        backgroundColor: darkColor,
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));

    setState(() {
      _markers.clear();
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId( LatLng(47.4754267,19.0979369).toString()),
        position:  LatLng(47.4754267,19.0979369),
        infoWindow: InfoWindow(
          title: 'My location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(200),
      ));
    });

    if(markerCache.containsKey(LatLng(47.4754267,19.0979369))) {
        setState(() {
          for (var data in markerCache[LatLng(47.4754267,19.0979369)]) {
            _markers.add(data);
          }
        });
        print("Maps from cache");
    }else {

      final response = await http.get(
          'https://dev.tescolabs.com/locations/search?sort=near: "47.4754267,19.0979369"',
          headers: {
            "Ocp-Apim-Subscription-Key": "d8bc2a3938d54c03a415206c8a02223c"
          });
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.

          markerCache[LatLng(47.4754267,19.0979369)] = new List<Marker>();
          setState(() {
            for (var data in json.decode(response.body)['results']) {
              var geo = data['location']['geo']['coordinates'];
              double long = geo['longitude'];
              double latitude = geo['latitude'];
              var position = LatLng(latitude, long);
              Marker mkr = Marker(
                // This marker id can be anything that uniquely identifies each marker.
                markerId: MarkerId(position.toString()),
                position: position,
                infoWindow: InfoWindow(
                    title: data['location']['name'],
                    snippet: '${data['distanceFrom']['value']} ${data['distanceFrom']['unit']}',
                    onTap: _navigateToShop
                ),
                icon: BitmapDescriptor.defaultMarker,
              );
              markerCache[LatLng(47.4754267,19.0979369)].add(mkr);
            _markers.add(mkr);
          }
          });
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load post; ${response.statusCode}');
      }
    }
  }

  void _navigateToShop(){
    Navigator.push(context,MaterialPageRoute(
        builder: (context) => CategoryList()
    ));
  }


}