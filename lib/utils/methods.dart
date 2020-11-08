import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class UtilMethods {
  Future<void> openMap(double latitude, double longitude) async {
    print(latitude.toString() + " asd" + longitude.toString());
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
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

  void startSilern() {
    FlutterRingtonePlayer.play(
      android: AndroidSounds.alarm,
      ios: IosSounds.glass,
      looping: true, // Android only - API >= 28
      volume: 1, // Android only - API >= 28
      asAlarm: true, // Android only - all APIs
    );
  }

  void stopSilern() {
    FlutterRingtonePlayer.stop();
  }
}
