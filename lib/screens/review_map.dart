import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:google_maps_webservice/places.dart';

const APIKEY = "AIzaSyAL66XlbNv6qIjjY70sf9WYGpCuLjDeP0w";

///////////////////THIS FEATURE IS JUST A DUMMY///////////////////////////////////

class ReviewsMap extends StatefulWidget {
  static String route = "reviews_map";

  @override
  State<ReviewsMap> createState() => MapSampleState();
}

class MapSampleState extends State<ReviewsMap> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Heatmap> _heatmaps = {};
  BitmapDescriptor sourceIcon;

  Set<Marker> _markers;

  final _searchFieldController = TextEditingController();
  DatabaseMethods _databaseMethods = DatabaseMethods();
  final _formKey = GlobalKey<FormState>();

  Future<dynamic> _getCurrentLocation() async {
    print('1');
    var user = await _databaseMethods.getUserInfo();
    var lat = user.data()['location']['latitude'];
    var lon = user.data()['location']['longitude'];
    LatLng loc = LatLng(lat, lon);
    _heatmapLocation = loc;


    CameraPosition _currentLocation = CameraPosition(
      target: loc,
      zoom: 17.4746,
    );
    setState(() {
      _markers = {
        Marker(markerId: MarkerId('value'), position: loc, icon: sourceIcon),
      };
    });
    return _currentLocation;
  }

  final List<Map> dummyPlaces = [
    {"city": "Bhopal", "latitude": 23.2599, "longitude": 77.4126},
    {"city": "Jhansi", "latitude": 25.4484, "longitude": 78.5685},
    {"city": "Delhi", "latitude": 28.7041, "longitude": 77.1025}
  ];

  Map reviewLoc = {"latitude": 1, "longitude": 1};

  final places = GoogleMapsPlaces(apiKey: APIKEY);
  LatLng _heatmapLocation ;
  List<Map> _searchPlaces = [];

  int q1, q2, q3, q4, q5, q6, q7, q8;

  @override
  void initState() {
    super.initState();
    q1 = q2 = q3 = q4 = q5 = q6 = q7 = q8 = -1;
    setSourceIcons();
    _markers = {
      Marker(
        markerId: MarkerId('value'),
        position: LatLng(28.632893, 437.219491),
        icon: sourceIcon,
      )
    };
  }

  void setSourceIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
          devicePixelRatio: 2.5,
        ),
        'assets/images/marker.png');
  }

  var isValid = true;

  void calcAndSubmitScore() {
    int score = 0;
    if (q1 == 0)
      score += 10;
    else if (q1 == 1)
      score += 8;
    else if (q1 == 2)
      score += 5;
    else if (q1 == 3) score += 1;

    if (q2 == 0)
      score += 10;
    else if (q2 == 1)
      score += 8;
    else if (q2 == 2) score += 5;

    if (q3 == 0)
      score += 10;
    else if (q3 == 1)
      score += 6;
    else if (q3 == 2) score += 1;

    if (q4 == 0)
      score += 10;
    else if (q4 == 1)
      score += 8;
    else if (q4 == 2)
      score += 1;
    else if (q4 == 3) score += 1;

    if (q5 == 0)
      score += 10;
    else if (q5 == 1)
      score += 1;
    else if (q5 == 2) score += 3;

    if (q6 == 0)
      score += 10;
    else if (q6 == 1)
      score += 1;
    else if (q6 == 2) score += 3;

    _databaseMethods.createReviewDocument(
        city: "Demo",
        lighting: q1,
        crowd: q2,
        altRoutes: q3,
        policeStation: q4,
        safeToVisit: q5,
        safeForWomen: q6,
        locality: "Demo. Demo.",
        location: reviewLoc,
        score: score);
  }

  void showReviewForm() {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter state) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.white,
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        "How is the lighthing at this locality?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                          value: 0,
                                          groupValue: q1,
                                          onChanged: (val) {
                                            state(() {
                                              q1 = val;
                                            });
                                          },
                                        ),
                                        Flexible(
                                          child: Text('Very Good'),
                                        ),
                                        Radio(
                                          value: 1,
                                          groupValue: q1,
                                          onChanged: (val) {
                                            state(() {
                                              q1 = val;
                                            });
                                          },
                                        ),
                                        Flexible(
                                          child: Text('Good'),
                                        ),
                                        Radio(
                                          value: 2,
                                          groupValue: q1,
                                          onChanged: (val) {
                                            state(() {
                                              q1 = val;
                                            });
                                          },
                                        ),
                                        Flexible(
                                          child: Text('Okay'),
                                        ),
                                        Radio(
                                          value: 3,
                                          groupValue: q1,
                                          onChanged: (val) {
                                            state(() {
                                              q1 = val;
                                            });
                                          },
                                        ),
                                        Flexible(
                                          child: Text('Bad'),
                                        )
                                      ],
                                    ),
                                    ListTile(
                                      title: Text(
                                        "How crowded is the place normally?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                          value: 0,
                                          groupValue: q2,
                                          onChanged: (val) {
                                            state(() {
                                              q2 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('Crowded')),
                                        Radio(
                                          value: 1,
                                          groupValue: q2,
                                          onChanged: (val) {
                                            state(() {
                                              q2 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('Normal')),
                                        Radio(
                                          value: 2,
                                          groupValue: q2,
                                          onChanged: (val) {
                                            state(() {
                                              q2 = val;
                                            });
                                          },
                                        ),
                                        Flexible(
                                          child: Text('Deserted'),
                                        ),
                                      ],
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Can you take alternative routes that are well lit?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                          value: 0,
                                          groupValue: q3,
                                          onChanged: (val) {
                                            state(() {
                                              q3 = val;
                                            });
                                          },
                                        ),
                                        Flexible(
                                          child: Text('Yes'),
                                        ),
                                        Radio(
                                          value: 1,
                                          groupValue: q3,
                                          onChanged: (val) {
                                            state(() {
                                              q3 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('No')),
                                        Radio(
                                          value: 2,
                                          groupValue: q3,
                                          onChanged: (val) {
                                            state(() {
                                              q3 = val;
                                            });
                                          },
                                        ),
                                        Flexible(
                                          child: Text('Don\'t know'),
                                        )
                                      ],
                                    ),
                                    ListTile(
                                      title: Text(
                                        " How close is the nearest police station?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                          value: 0,
                                          groupValue: q4,
                                          onChanged: (val) {
                                            state(() {
                                              q4 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('< 1km')),
                                        Radio(
                                          value: 1,
                                          groupValue: q4,
                                          onChanged: (val) {
                                            state(() {
                                              q4 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('1-5 km')),
                                        Radio(
                                          value: 2,
                                          groupValue: q4,
                                          onChanged: (val) {
                                            state(() {
                                              q4 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('5+ km')),
                                        Radio(
                                          value: 3,
                                          groupValue: q4,
                                          onChanged: (val) {
                                            state(() {
                                              q4 = val;
                                            });
                                          },
                                        ),
                                        Flexible(
                                          child: Text(
                                            'Don\'t know',
                                          ),
                                        )
                                      ],
                                    ),
                                    ListTile(
                                      title: Text(
                                        " Would you visit this place at night?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                          value: 0,
                                          groupValue: q5,
                                          onChanged: (val) {
                                            state(() {
                                              q5 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('Yes')),
                                        Radio(
                                          value: 1,
                                          groupValue: q5,
                                          onChanged: (val) {
                                            state(() {
                                              q5 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('No')),
                                        Radio(
                                          value: 2,
                                          groupValue: q5,
                                          onChanged: (val) {
                                            state(() {
                                              q5 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('Don\'t know')),
                                      ],
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Do you consider this place safe for women?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                          value: 0,
                                          groupValue: q6,
                                          onChanged: (val) {
                                            state(() {
                                              q6 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('Yes')),
                                        Radio(
                                          value: 1,
                                          groupValue: q6,
                                          onChanged: (val) {
                                            state(() {
                                              q6 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('No')),
                                        Radio(
                                          value: 2,
                                          groupValue: q6,
                                          onChanged: (val) {
                                            state(() {
                                              q6 = val;
                                            });
                                          },
                                        ),
                                        Flexible(child: Text('Don\'t know')),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            isValid
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Please fill all answers!',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.red),
                                    ),
                                  ),
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
                                    onPressed: () {
                                      if (q1 == -1 ||
                                          q2 == -1 ||
                                          q3 == -1 ||
                                          q4 == -1 ||
                                          q5 == -1 ||
                                          q6 == -1) {
                                        state(() {
                                          isValid = false;
                                        });
                                      }
                                      if (isValid) {
                                        calcAndSubmitScore();
                                        Navigator.pop(context);
                                        state(() {
                                          q1 = q2 = q3 = q4 = q5 = q6 = -1;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ) // Add TextFormFields and ElevatedButton here.
                      ],
                    ),
                  ),
                ),
              );
            },
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
    // print("AAAAAAAAAAAAAAA");
    // print(response);
    // final searchResults = response.data['predictions'];

    List<Map> _results = [];
    final searchResults = dummyPlaces;
    for (var i = 0; i < searchResults.length; i++) {
      Map name = searchResults[i];
      _results.add(name);
    }

    // var res = await places.autocomplete(text);
    // for (var p in res.predictions) {
    //   print('- ${p.description}');
    //   String name = p.description;
    //   _results.add(name);
    // }

    setState(() {
      _searchPlaces = _results;
      // _searchPlaces = ['Alam Bagh', 'Chand Bawari'];
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
                      setState(() {
                        _heatmaps.add(
                            Heatmap(
                                heatmapId: HeatmapId(_heatmapLocation.toString()),
                                points: _createPoints(_heatmapLocation),
                                radius: 50,
                                visible: true,
                                gradient:  HeatmapGradient(
                                    colors: <Color>[Colors.green, Colors.red], startPoints: <double>[0.2, 0.8]
                                )
                            )
                        );
                      });
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
                                title: Text(_searchPlaces[index]["city"]),
                                onTap: () async {
                                  var latitude =
                                      _searchPlaces[index]["latitude"];
                                  var longitude =
                                      _searchPlaces[index]["longitude"];
                                  CameraPosition cPosition = CameraPosition(
                                    zoom: 5.5,
                                    target: LatLng(latitude, longitude),
                                  );
                                  final GoogleMapController controller =
                                      await _controller.future;
                                  controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                          cPosition));

                                  setState(() {
                                    _searchPlaces = [];
                                    _searchFieldController.text = "";
                                    _markers.removeWhere(
                                        (m) => m.markerId.value == 'value');
                                    _markers.add(Marker(
                                        markerId: MarkerId('value'),
                                        position: LatLng(latitude, longitude)));
                                  });

                                  print(_markers);
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
