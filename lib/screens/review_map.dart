import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';

class ReviewsMap extends StatefulWidget {
  static String route = "reviews_map";

  @override
  State<ReviewsMap> createState() => MapSampleState();
}

class MapSampleState extends State<ReviewsMap> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Heatmap> _heatmaps = {};
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('value'),
      position: LatLng(28.632893, 437.219491),
    )
  };

  final _searchFieldController = TextEditingController();
  // DatabaseMethods _databaseMethods = DatabaseMethods();
  final _formKey = GlobalKey<FormState>();

  Future<dynamic> _getCurrentLocation() async {
    CameraPosition _currentLocation = CameraPosition(
      target: LatLng(28.632893, 437.219491),
      zoom: 14.4746,
    );
    return _currentLocation;
  }

  LatLng _heatmapLocation = LatLng(37.42796133580664, -122.085749655962);

  void showReviewForm() {
    print(_markers.first.position);
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Colors.white,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              'What is the lighting like?',
                            ),
                          ),
                          Text('Hello'),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ButtonTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            // width: double.infinity,
                            child: RaisedButton(
                              color: Color(0xffdf1d38),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ) // Add TextFormFields and ElevatedButton here.
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              body: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.hybrid,
                    initialCameraPosition: snapshot.data,
                    heatmaps: _heatmaps,
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 15,
                    left: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Expanded(
                        child: TextField(
                          controller: _searchFieldController,
                          onTap: () async {
                            print(_searchFieldController.text);
                          },
                          cursorColor: Colors.black,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 15),
                              hintText: "Search..."),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: Color(0xFFFF7274),
                onPressed: showReviewForm,
                label: Text('Add Review'),
                icon: Icon(Icons.add),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  void _addHeatmap() {
    setState(() {
      _heatmaps.add(Heatmap(
          heatmapId: HeatmapId(_heatmapLocation.toString()),
          points: _createPoints(_heatmapLocation),
          radius: 20,
          visible: true,
          gradient: HeatmapGradient(
              colors: <Color>[Colors.green, Colors.red],
              startPoints: <double>[0.2, 0.8])));
    });
  }

  //heatmap generation helper functions
  List<WeightedLatLng> _createPoints(LatLng location) {
    final List<WeightedLatLng> points = <WeightedLatLng>[];
    //Can create multiple points here
    points.add(_createWeightedLatLng(location.latitude, location.longitude, 1));
    points.add(
        _createWeightedLatLng(location.latitude - 1, location.longitude, 1));
    return points;
  }

  WeightedLatLng _createWeightedLatLng(double lat, double lng, int weight) {
    return WeightedLatLng(point: LatLng(lat, lng), intensity: weight);
  }
}
