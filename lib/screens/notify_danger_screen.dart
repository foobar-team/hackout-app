import 'dart:async';

import 'package:background_geolocation_firebase/background_geolocation_firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:foobar/utils/user_constants.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:holding_gesture/holding_gesture.dart';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'package:carousel_slider/carousel_slider.dart';


class NotifyDangerScreen extends StatefulWidget {
  @override
  _NotifyDangerScreenState createState() => _NotifyDangerScreenState();
}

class _NotifyDangerScreenState extends State<NotifyDangerScreen>
    with SingleTickerProviderStateMixin {
  DatabaseMethods _databaseMethods = DatabaseMethods();
  bool isLoading = false;
  AnimationController _controller;
  bool alertSent = false;

  @override
  void initState() {
    super.initState();
    this._controller = AnimationController(
      duration: const Duration(seconds: 5),

      vsync: this,
    )..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          await sendAlert();

          // _controller.value = -1;
          print(_controller.value);
        }
      });
  }

  @override
  void dispose() {
    this._controller.dispose();
    super.dispose();
  }

  showSentDialog() {
    showDialog(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 20),
        child: Neumorphic(
            child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 40.0, horizontal: 20.0),
                      child: NeumorphicButton(
                        onPressed: () {
                          print('Pressed !');
                        },
                        child: Text(
                          "Record Audio",
                          style: TextStyle(fontSize: 20),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 40.0, horizontal: 20.0),
                      child: NeumorphicButton(
                        onPressed: () {
                          print('Pressed !');
                        },
                        child: Text(
                          'Trigger Siren',
                          style: TextStyle(fontSize: 20),
                        ),
                      ))
                ],
              ),
              CarouselSlider(
                options: CarouselOptions(
                  height: 300,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  scrollDirection: Axis.horizontal,
                ),
                items: [1, 2, 3, 4, 5].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          child: Text(
                            'text $i',
                            style: TextStyle(fontSize: 16.0),
                          ));
                    },
                  );
                }).toList(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 40.0, horizontal: 20.0),
                      child: NeumorphicButton(
                        onPressed: () {
                          print('Pressed !');
                        },
                        child: Text(
                          "I'm safe now :-)",
                          style: TextStyle(fontSize: 20),
                        ),
                      ))
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }

  sendAlert() async {
    setState(() {
      isLoading = true;
    });
    await _databaseMethods.sendDangerAlert();

    setState(() {
      alertSent = true;
      isLoading = false;
      showSentDialog();
    });
    print((await bg.BackgroundGeolocation.getCurrentPosition()).toString()+"ahsdhashdhhell");
    _initPlatformState(uid:CONSTANT_UID);
  }
  Future<Null> _initPlatformState({String uid}) async {

    BackgroundGeolocationFirebase.configure(BackgroundGeolocationFirebaseConfig(
        locationsCollection: "liveLocations/$uid",
        // geofencesCollection: "geofences",
        updateSingleDocument: true
    ));
    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
    });
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[onLocation] $location');
    });

    bg.BackgroundGeolocation.ready(bg.Config(

      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 1.0,
      stopOnTerminate: false,
      startOnBoot: true,
      debug: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      enableHeadless: true,
      // stopOnTerminate: false,
      // startOnBoot: true,
      // debug: true,
    )).then((bg.State state) {
      if (!state.enabled) {
        ////
        // 3.  Start the plugin.
        //
        bg.BackgroundGeolocation.start();
      }
    });
  }

  sendSafe() async {
    setState(() {
      isLoading = true;
    });
    await _databaseMethods.sendSafeAlert();
    setState(() {
      alertSent = false;
      isLoading = false;
    });
  }

  alertButtonOnPress() async {
    this._controller.forward();
  }

  Timer timer;

  void startTimer() {
    // Start the periodic timer which prints something every 1 seconds
    timer = Timer.periodic(new Duration(seconds: 1), (time) {
      print('Something');
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isLoading,
      child: Stack(children: [
        Center(
          child: AnimatedBuilder(
            animation: this._controller,
            builder: (_, ch) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HoldDetector(
                    onHold: () => {print("holding")},
                    child: CircularPercentIndicator(
                      progressColor: Colors.blueGrey,
                      radius: 200,
                      lineWidth: 5,
                      percent: this._controller.value,
                      startAngle: 0,
                      center: Padding(
                        padding: const EdgeInsets.all(3),
                        child: NeumorphicButton(
                          onPressed: !alertSent ? alertButtonOnPress : () {},
                          child: Center(
                              child: alertSent
                                  ? Text(
                                      "ALERT SENT!",
                                      style: TextStyle(fontSize: 25),
                                    )
                                  : (this._controller.value == 0
                                      ? Text(
                                          "Alert",
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w300),
                                        )
                                      : Text(
                                          "${(5 - this._controller.value * 5).toStringAsFixed(0)}",
                                          style: TextStyle(fontSize: 30),
                                        ))),
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.convex,
                            boxShape: NeumorphicBoxShape.circle(),
                            depth: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _controller.isAnimating
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: NeumorphicButton(
                            child: Text("Cancel Alert"),
                            onPressed: () {
                              this._controller.reset();
                            },
                          ),
                        )
                      : Container()
                ],
              );
            },
          ),
        ),
        isLoading
            ? Center(
                child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ))
            : Container(),
      ]),
    );
  }
}

// InkWell(
// onTap: () async {
// setState(() {
// isLoading = true;
// });
// await _databaseMethods.sendDangerAlert();
//
// setState(() {
// isLoading = false;
// showSentDialog();
// });
// },
// child: Padding(
// padding: const EdgeInsets.all(8.0),
// child: Container(
// width: 200,
// height: 200,
// color: Colors.grey,
// child: IconButton(
// color: Colors.white,
// icon: Icon(Icons.report_gmailerrorred_outlined),
// iconSize: 100,
// ),
// ),
// ),
// ),
