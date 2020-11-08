import 'package:flutter/material.dart';
import 'package:foobar/model/local_location.dart';
import 'package:foobar/model/local_user.dart';
import 'package:foobar/services/database_methods.dart';
import 'dart:async';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 80;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
const LatLng DEST_LOCATION = LatLng(37.335685, -122.0605916);

class LiveLocation extends StatefulWidget {
  static String route = "live_location";

  @override
  State<LiveLocation> createState() => MapSampleState();
}

class MapSampleState extends State<LiveLocation> {

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  DatabaseMethods _databaseMethods = DatabaseMethods();

  // for my custom marker pins
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  int buildCount = 0;

  @override
  void initState() {
    super.initState();
    setSourceIcons();
  } // final Set<Heatmap> _heatmaps = {};
  // static final CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(37.42796133580664, -122.085749655962),
  //   zoom: 14.4746,
  // );

  CameraPosition initialCameraPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: SOURCE_LOCATION
  );
  StreamSubscription _locationSubscription;

  stream({String uid}) {
    _locationSubscription = _databaseMethods.getUserLiveLocation(uid: uid).listen((event) {
      print("Hellllllll"+event.longitude.toString());
      updatePinOnMap(event.latitude, event.longitude);
    });
      // You should add your code here

    }

  void updatePinOnMap(double latitude,double longitude) async {

    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(latitude,
          longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition = LatLng(latitude,
          longitude);

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere(
              (m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition, // updated position
          icon: sourceIcon
      ));
    });
  }



  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {

    final data = ModalRoute
        .of(context)
        .settings
        .arguments  as LocalUser;
    if(buildCount == 0) {
      stream(uid:data.uid);
    }
    buildCount++;
    return new Scaffold(
      body: StreamBuilder<LocalLocation>(
          stream: _databaseMethods.getUserLiveLocation(uid: data.uid),
          builder: (_, snapshot) {
            if (snapshot.hasData) {

            }
            return GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: false,
                markers: _markers,

                mapType: MapType.normal,
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  // my map has completed being created;
                  // i'm ready to show the pins on the map
                  showPinsOnMap(1,1);
                });
          }
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: Text('To the lake!'),
      //   icon: Icon(Icons.directions_boat),
      // ),
    );
  }

  void setSourceIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/intro_one.png');


  }
  void showPinsOnMap(double initialLat, double initialLong) {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition = LatLng(initialLat,
        initialLong);
    // get a LatLng out of the LocationData object
    // var destPosition = LatLng(destinationLocation.latitude,
    //     destinationLocation.longitude);
    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        icon: sourceIcon
    ));
    // destination pin
    // _markers.add(Marker(
    //     markerId: MarkerId('destPin'),
    //     position: destPosition,
    //     icon: destinationIcon
    // ));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    // setPolylines();
  }

  //heatmap generation helper functions
  // List<WeightedLatLng> _createPoints(LatLng location) {
  //   final List<WeightedLatLng> points = <WeightedLatLng>[];
  //   //Can create multiple points here
  //   points.add(_createWeightedLatLng(location.latitude, location.longitude, 1));
  //   points.add(
  //       _createWeightedLatLng(location.latitude - 1, location.longitude, 1));
  //   return points;
  // }
  //
  // WeightedLatLng _createWeightedLatLng(double lat, double lng, int weight) {
  //   return WeightedLatLng(point: LatLng(lat, lng), intensity: weight);
  // }
  //
  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }
}
