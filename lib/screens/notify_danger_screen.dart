import 'dart:async';

import 'package:background_geolocation_firebase/background_geolocation_firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:foobar/utils/user_constants.dart';
import 'package:foobar/utils/methods.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:holding_gesture/holding_gesture.dart';

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

import 'package:carousel_slider/carousel_slider.dart';

class NotifyDangerScreen extends StatefulWidget {
  @override
  _NotifyDangerScreenState createState() => _NotifyDangerScreenState();
}

class _NotifyDangerScreenState extends State<NotifyDangerScreen>
    with SingleTickerProviderStateMixin {
  DatabaseMethods _databaseMethods = DatabaseMethods();
  UtilMethods _utilMethods = UtilMethods();
  bool isLoading = false;
  AnimationController _controller;
  bool alertSent = false;

  List<Map<String, String>> selfDefense = [
    {
      "title": "What you can do to attack?",
      "content":
          "If You have key then hold your key ring in a tight fist, like holding a hammer, with keys extending from the side of your hand. Thrust downward toward your target."
    },
    {
      "title": "What if someone is following you and it's night time?",
      "content":
          "Don't run as you could get yourself in a big trap with the stalker and if you really feel scared, stop at a well-lit public place, such as a restaurant or hotel. Call the police or family and friends and ask them to escort you to your home, or stay with them (either police or family and friends) for a while."
    },
    {
      "title": "Where to go Now?",
      "content":
          "Don't go straight home. This will show the person where you live and is especially dangerous if you live alone. Try to go to a neighbor's house, a friend's house or another family member's house, where you know there will be other people to answer the door and take care of you or go to the police station if possible."
    },
    {
      "title": "What if someone try to attack you?",
      "content":
          "Protect your groin, throat, stomach, and eyes with your hands and arms. These are the most vulnerable parts of your body. So, block your attacker’s blows with your hands and upper arms and try to deflect any punches or slaps."
    },
    {
      "title": "How to deal with potential attackers?",
      "content":
          "Project confidence and awareness so that you’re not an easy target because they try to prey on easy targets: people who aren’t very aware of their environment and who can be ambushed easily. Avoid making eye contact with anyone who you feel may be following you, but be aware of your surroundings."
    }
  ];

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
                          vertical: 20.0, horizontal: 10.0),
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
                          vertical: 20.0, horizontal: 10.0),
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
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0))),
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 30.0),
                                      child: Text(
                                        selfDefense[i - 1]["title"],
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      )),
                                  Text(
                                    selfDefense[i - 1]["content"],
                                    style: TextStyle(fontSize: 16.0),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              )));
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
                          vertical: 20.0, horizontal: 20.0),
                      child: NeumorphicButton(
                        onPressed: () {
                          sendSafe();
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
    });
    print((await bg.BackgroundGeolocation.getCurrentPosition()).toString() +
        "ahsdhashdhhell");
    _initPlatformState(uid: CONSTANT_UID);
  }

  Future<Null> _initPlatformState({String uid}) async {
    BackgroundGeolocationFirebase.configure(BackgroundGeolocationFirebaseConfig(
        locationsCollection: "liveLocations/$uid",
        // geofencesCollection: "geofences",
        updateSingleDocument: true));
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
    print("sendSafe");
    setState(() {
      isLoading = true;
    });
    await _databaseMethods.sendSafeAlert();
    setState(() {
      alertSent = false;
      isLoading = false;
    });
    bg.BackgroundGeolocation.stop();
    _utilMethods.stopSilern();
    this._controller.reset();
  }

  alertButtonOnPress() async {
    this._controller.forward();
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
                    child: alertSent
                        ? Neumorphic(
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
                                            vertical: 20.0, horizontal: 10.0),
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
                                            vertical: 20.0, horizontal: 10.0),
                                        child: NeumorphicButton(
                                          onPressed: () {
                                            _utilMethods.startSilern();
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
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 800),
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    scrollDirection: Axis.horizontal,
                                  ),
                                  items: [1, 2, 3, 4, 5].map((i) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                            alignment: Alignment.center,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 5.0),
                                            decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0))),
                                            child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 20.0,
                                                    horizontal: 20.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 30.0),
                                                        child: Text(
                                                          selfDefense[i - 1]
                                                              ["title"],
                                                          style: TextStyle(
                                                              fontSize: 16.0),
                                                          textAlign:
                                                              TextAlign.center,
                                                        )),
                                                    Text(
                                                      selfDefense[i - 1]
                                                          ["content"],
                                                      style: TextStyle(
                                                          fontSize: 16.0),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  ],
                                                )));
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
                                            vertical: 20.0, horizontal: 20.0),
                                        child: NeumorphicButton(
                                          onPressed: () {
                                            sendSafe();
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
                          ))
                        : CircularPercentIndicator(
                            progressColor: Colors.blueGrey,
                            radius: 200,
                            lineWidth: 5,
                            percent: this._controller.value,
                            startAngle: 0,
                            center: Padding(
                              padding: const EdgeInsets.all(3),
                              child: NeumorphicButton(
                                onPressed:
                                    !alertSent ? alertButtonOnPress : () {},
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
                                                    fontWeight:
                                                        FontWeight.w300),
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
