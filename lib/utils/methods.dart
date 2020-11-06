import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilMethods{
   Future<void> openMap(double latitude, double longitude) async {
     print(latitude.toString()+" asd"+longitude.toString());
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (LocationPermission.denied.index == permission.index) {
      LocationPermission permission2 = await Geolocator.requestPermission();


    }
  }
}