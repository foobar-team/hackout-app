import 'package:background_geolocation_firebase/background_geolocation_firebase.dart';
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
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

void headlessTask(bg.HeadlessEvent headlessEvent) async {
  print('[BackgroundGeolocation HeadlessTask]: $headlessEvent');
  // Implement a 'case' for only those events you're interested in.
  switch(headlessEvent.name) {
    case bg.Event.TERMINATE:
      bg.State state = headlessEvent.event;
      print('- State: $state');
      break;
    case bg.Event.HEARTBEAT:
      bg.HeartbeatEvent event = headlessEvent.event;
      print('- HeartbeatEvent: $event');
      break;
    case bg.Event.LOCATION:
      bg.Location location = headlessEvent.event;
      print('- Location: $location');
      break;
    case bg.Event.MOTIONCHANGE:
      bg.Location location = headlessEvent.event;
      print('- Location: $location');
      break;
    case bg.Event.GEOFENCE:
      bg.GeofenceEvent geofenceEvent = headlessEvent.event;
      print('- GeofenceEvent: $geofenceEvent');
      break;
    case bg.Event.GEOFENCESCHANGE:
      bg.GeofencesChangeEvent event = headlessEvent.event;
      print('- GeofencesChangeEvent: $event');
      break;
    case bg.Event.SCHEDULE:
      bg.State state = headlessEvent.event;
      print('- State: $state');
      break;
    case bg.Event.ACTIVITYCHANGE:
      bg.ActivityChangeEvent event = headlessEvent.event;
      print('ActivityChangeEvent: $event');
      break;
    case bg.Event.HTTP:
      bg.HttpEvent response = headlessEvent.event;
      print('HttpEvent: $response');
      break;
    case bg.Event.POWERSAVECHANGE:
      bool enabled = headlessEvent.event;
      print('ProviderChangeEvent: $enabled');
      break;
    case bg.Event.CONNECTIVITYCHANGE:
      bg.ConnectivityChangeEvent event = headlessEvent.event;
      print('ConnectivityChangeEvent: $event');
      break;
    case bg.Event.ENABLEDCHANGE:
      bool enabled = headlessEvent.event;
      print('EnabledChangeEvent: $enabled');
      break;
  }
}




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



  @override
  void initState() {
    super.initState();
  }


  configureFcm(){

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
