import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:google_maps_webservice/places.dart';

const APIKEY = "AIzaSyA8iknAxcM2PDfHEh7Z0hV42Pmcq8MnA7w";

class ReviewsMap extends StatefulWidget {
  static String route = "reviews_map";

  @override
  State<ReviewsMap> createState() => MapSampleState();
}

class MapSampleState extends State<ReviewsMap> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Heatmap> _heatmaps = {};

  Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('value'),
      position: LatLng(28.632893, 437.219491),
    )
  };

  final _searchFieldController = TextEditingController();
  DatabaseMethods _databaseMethods = DatabaseMethods();
  final _formKey = GlobalKey<FormState>();

  Future<dynamic> _getCurrentLocation() async {
    var user = await _databaseMethods.getUserInfo();
    print(user.data()['location']);
    print("AAAAAA");
    var lat = user.data()['location']['latitude'];
    var lon = user.data()['location']['longitude'];
    LatLng loc = LatLng(lat, lon);
    CameraPosition _currentLocation = CameraPosition(
      target: loc,
      zoom: 17.4746,
    );
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId('value'),
          position: loc,
        ),
      };
    });
    return _currentLocation;
  }

  final places = GoogleMapsPlaces(apiKey: APIKEY);
  LatLng _heatmapLocation = LatLng(37.42796133580664, -122.085749655962);
  List<String> _searchPlaces = [];
  void showReviewForm() {
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

  void getLocationResult(String text) async {
    if (text.isEmpty) {
      setState(() {
        _searchPlaces = [];
      });
      return;
    }
    // String requestURL =
    //     "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    // String request = '$requestURL?input=$text&key=$APIKEY';
    // Response response = await Dio().get(request);
    // final searchResults = response.data['predictions'];
    List<String> _results = [];
    // for (var i = 0; i < searchResults.length; i++) {
    //   String name = searchResults[i]['description'];
    //   _results.add(name);
    // }

    var res = await places.autocomplete(text);
    for (var p in res.predictions) {
      print('- ${p.description}');
      String name = p.description;
      _results.add(name);
    }

    setState(() {
      _searchPlaces = _results;
      _searchPlaces = ['Alam Bagh', 'Chand Bawari'];
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
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchFieldController,
                            onTap: () async {
                              print(_searchFieldController.text);
                            },
                            onChanged: (text) {
                              getLocationResult(text);
                            },
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 15),
                                hintText: "Search..."),
                          ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _searchPlaces.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_searchPlaces[index]),
                                onTap: () {
                                  print(_searchPlaces[index]);
                                },
                              );
                            },
                          ),
                        ],
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
