import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:holding_gesture/holding_gesture.dart';

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
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text("Alert successfully sent"),
          subtitle: Text("Don't worry! Someone will be coming to help you."),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('I am strong.'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
    var user = await _databaseMethods.getUserInfo();
    print("user info ${user.data()} end");
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
                                          "${(this._controller.value * 5).toStringAsFixed(0)}",
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
                      : Container(),
                  alertSent
                      ? Row(
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
