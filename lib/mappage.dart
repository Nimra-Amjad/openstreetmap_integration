import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapPageProject extends StatefulWidget {
  const MapPageProject({Key? key}) : super(key: key);

  @override
  State<MapPageProject> createState() => _MapPageProjectState();
}

class _MapPageProjectState extends State<MapPageProject> {
  final MapController _mapController = MapController();
  String _address = "Enter an pick up address"; // The address input by the user
  String _dropoffaddress =
      "Enter an drop off address"; // The address input by the user
  double? picklat;
  double? picklong;
  double? droplat;
  double? droplong;
  double distanceInKm =
      0.0; // Declare a variable to store the distance in kilometers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Address'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _address = value;
                      });
                      fetchCoordinatesFromAddress(_address,
                          true); // true indicates it's the pick-up address
                    },
                    decoration: const InputDecoration(
                      labelText: "Enter Pick Up Address",
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _dropoffaddress = value;
                      });
                      fetchCoordinatesFromAddress(_dropoffaddress,
                          false); // false indicates it's the drop-off address
                    },
                    decoration: const InputDecoration(
                      labelText: "Enter Drop Off Address",
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(24.8607, 67.0011),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    if (picklat != null &&
                        picklong != null &&
                        droplat != null &&
                        droplong != null)
                      Polyline(
                        points: [
                          LatLng(picklat!, picklong!),
                          LatLng(droplat!, droplong!),
                        ],
                        color: Colors
                            .green, // Change the color of the polyline here
                        strokeWidth:
                            3.0, // Adjust the width of the polyline here
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (picklat != null && picklong != null)
                      Marker(
                        width: 60.0,
                        height: 60.0,
                        point: LatLng(picklat!, picklong!),
                        builder: (ctx) =>
                            const Icon(Icons.location_on, color: Colors.red),
                      ),
                    if (droplat != null && droplong != null)
                      Marker(
                        width: 60.0,
                        height: 60.0,
                        point: LatLng(droplat!, droplong!),
                        builder: (ctx) =>
                            const Icon(Icons.location_on, color: Colors.blue),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to get the latitude and longitude from an address using Nominatim API
  // Future<void> fetchCoordinatesFromAddress(String address) async {
  //   const baseUrl = 'https://nominatim.openstreetmap.org/search/';
  //   const format = 'json';

  //   final encodedAddress = Uri.encodeQueryComponent(address);
  //   final url = '$baseUrl$encodedAddress?format=$format';

  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     if (data.isNotEmpty) {
  //       picklat = double.parse(data[0]['lat']);
  //       picklong = double.parse(data[0]['lon']);
  //       _mapController.move(LatLng(picklat!, picklong!),
  //           13.0); // Move the map to the new location
  //       print('Latitude: $picklat, Longitude: $picklong');
  //     } else {
  //       print('No results found.');
  //     }
  //   } else {
  //     print('Failed to fetch data from the API.');
  //   }
  //   setState(() {});
  //   if (picklat != null &&
  //       picklong != null &&
  //       droplat != null &&
  //       droplong != null) {
  //     distanceInKm =
  //         calculateDistance(picklat!, picklong!, droplat!, droplong!);
  //     print('Distance: $distanceInKm km');
  //   }

  //   setState(() {});
  // }
  // Future<void> fetchCoordinatesDropOffAddress(String dropaddress) async {
  //   const apiKey =
  //       '0b0b8623bdce489a99e2858f7c9c9e78'; // Replace with your OpenCage API key
  //   const baseUrl = 'https://api.opencagedata.com/geocode/v1/json';

  //   final encodedAddress = Uri.encodeQueryComponent(dropaddress);
  //   final url = '$baseUrl?q=$encodedAddress&key=$apiKey';

  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     if (data.isNotEmpty) {
  //       droplat = double.parse(data[0]['lat']);
  //       droplong = double.parse(data[0]['lon']);
  //       _mapController.move(LatLng(droplat!, droplong!),
  //           13.0); // Move the map to the new location
  //       print('Latitude: $droplat, Longitude: $droplong');
  //     } else {
  //       print('No results found.');
  //     }
  //   } else {
  //     print('Failed to fetch data from the API.');
  //   }
  //   if (picklat != null &&
  //       picklong != null &&
  //       droplat != null &&
  //       droplong != null) {
  //     distanceInKm =
  //         calculateDistance(picklat!, picklong!, droplat!, droplong!);
  //     print('Distance: $distanceInKm km');
  //   }

  //   setState(() {});
  // }

  Future<void> fetchCoordinatesFromAddress(
      String address, bool isPickUp) async {
    const apiKey =
        '0b0b8623bdce489a99e2858f7c9c9e78'; // Replace with your OpenCage API key
    const baseUrl = 'https://api.opencagedata.com/geocode/v1/json';

    final encodedAddress = Uri.encodeQueryComponent(address);
    final url = '$baseUrl?q=$encodedAddress&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final lat = data['results'][0]['geometry']['lat'];
        final long = data['results'][0]['geometry']['lng'];
        _mapController.move(LatLng(lat, long), 13.0);
        if (isPickUp) {
          setState(() {
            picklat = lat;
            picklong = long;
          });
        } else {
          setState(() {
            droplat = lat;
            droplong = long;
          });
        }
        print('Latitude: $lat, Longitude: $long');
      } else {
        print('No results found.');
      }
    } else {
      print('Failed to fetch data from the API.');
    }

    if (picklat != null &&
        picklong != null &&
        droplat != null &&
        droplong != null) {
      distanceInKm =
          calculateDistance(picklat!, picklong!, droplat!, droplong!);
      print('Distance: $distanceInKm km');
    }
  }

  double calculateDistance(
      double startLat, double startLong, double endLat, double endLong) {
    const int earthRadius = 6371; // Earth's radius in kilometers

    double dLat = degreesToRadians(endLat - startLat);
    double dLon = degreesToRadians(endLong - startLong);

    double a = pow(sin(dLat / 2), 2) +
        cos(degreesToRadians(startLat)) *
            cos(degreesToRadians(endLat)) *
            pow(sin(dLon / 2), 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
