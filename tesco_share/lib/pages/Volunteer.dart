import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Volunteer extends StatelessWidget{
  var deliveries =[{'from': 'TESCO Expressz', 'to': 'Telekom HQ','observations':'The package to be carried is small', 'latlng_from': LatLng(47.498140,19.040550),
    'latlng_to': LatLng(47.513747, 19.060396)}
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer')
      ),
      body:
        ListView.builder(
          itemCount: deliveries.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text('From ' + deliveries[index]['from'] + " to " + deliveries[index]['to'] ),
              subtitle: Text(deliveries[index]['observations']),
              trailing: Image(image: AssetImage('images/google-maps.png'), width: 40,),
            );
          },

        )
    );
  }

}