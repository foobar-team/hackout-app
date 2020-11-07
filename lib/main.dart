import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foobar/screens/home.dart';
import 'package:foobar/screens/intro_screen/intro_screen.dart';
import 'package:foobar/screens/notify_danger_screen.dart';
import 'package:foobar/screens/signin_screen.dart';
import 'package:foobar/screens/signup_screen.dart';
import 'package:foobar/services/auth_methods.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:foobar/utils/methods.dart';
import 'package:foobar/utils/user_constants.dart';
import 'package:geolocator/geolocator.dart';

import 'package:workmanager/workmanager.dart';

const fetchBackground = "fetchLocationBackground"; //

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    await Firebase.initializeApp();
    DatabaseMethods _databaseMethods = DatabaseMethods();
    AuthMethods _authMethods = AuthMethods();
    auth.User user = _authMethods.getCurrentUser();
    switch (task) {
      case fetchBackground:
        if (user != null) {
          Position userLocation = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          _databaseMethods.updateUserLocation(
              location: userLocation, uid: user.uid);
        }

        break;
    }
    return Future.value(true);
  });
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Made Tommy'),
      home: MyHomePage(),
      routes: {
        SignUpScreen.route: (_) => SignUpScreen(),
        SignInScreen.route: (_) => SignInScreen(),
        HomeScreen.route: (_) => HomeScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  UtilMethods _utilMethods = UtilMethods();

  configureFcm() {
    FirebaseMessaging _fcm = FirebaseMessaging();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Open location in Maps'),
                onPressed: () => _utilMethods.openMap(
                    double.parse(message['data']['latitude']),
                    double.parse(message['data']['longitude'])),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _utilMethods.openMap(double.parse(message['data']['latitude']),
            double.parse(message['data']['longitude']));
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _utilMethods.openMap(double.parse(message['data']['latitude']),
            double.parse(message['data']['longitude']));
        // TODO optional
      },
    );
  }

  updateUserLocation(String uid) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (LocationPermission.whileInUse.index == permission.index ||
        LocationPermission.always.index == permission.index) {
      DatabaseMethods _databaseMethods = DatabaseMethods();
      Position userLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _databaseMethods.updateUserLocation(location: userLocation, uid: uid);
    } else {
      LocationPermission permission2 = await Geolocator.requestPermission();

      if (LocationPermission.whileInUse.index == permission2.index ||
          LocationPermission.always.index == permission2.index) {
        DatabaseMethods _databaseMethods = DatabaseMethods();
        Position userLocation = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        _databaseMethods.updateUserLocation(location: userLocation, uid: uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("Something went wrong"),
              ),
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            AuthMethods _authMethods = AuthMethods();
            auth.User user = _authMethods.getCurrentUser();
            if (user != null) {
              CONSTANT_UID = user.uid;
              updateUserLocation(user.uid);
            }

            configureFcm();
            Workmanager.initialize(
              callbackDispatcher,
              isInDebugMode: true,
            );

            Workmanager.registerPeriodicTask(
              "1",
              fetchBackground,
              frequency: Duration(minutes: 30),
            );
            return user != null ? HomeScreen() : IntroductionScreen();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
