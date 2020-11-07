import 'package:flutter/material.dart';
import 'package:foobar/screens/all_notifications.dart';
import 'package:foobar/screens/notify_danger_screen.dart';
import 'package:foobar/screens/signin_screen.dart';
import 'package:foobar/screens/reviews_map.dart';
import 'package:foobar/services/auth_methods.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:foobar/utils/methods.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  static String route = "home_route";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthMethods _authMethods = AuthMethods();

  UtilMethods _utilMethods = UtilMethods();

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
    // return FutureBuilder<LocationPermission>(
    //   future: Geolocator.checkPermission(),
    //   builder:(_,snapshot){
    //     if(snapshot.hasData) {
    //       if (snapshot.data == LocationPermission.denied ||
    //           snapshot.data == LocationPermission.whileInUse) {
    //         showPermissionDialog();
    // Geolocator.checkPermission();
    Geolocator.requestPermission();
    updateUserLocation(_authMethods.getCurrentUser().uid);

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: TabBarView(children: <Widget>[
            NotifyDangerScreen(),
            AllNotificationsScreen(),
            ReviewsMap()
          ]),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              "HelpFem",
              style: TextStyle(color: Colors.black),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.blueGrey,
                ),
                onPressed: () {
                  _authMethods.logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, SignInScreen.route, (route) => false);
                },
              )
            ],
            bottom: TabBar(
              indicatorColor: Colors.blueGrey,
              tabs: <Widget>[
                Tab(
                    child:
                        Text("Alert", style: TextStyle(color: Colors.black))),
                Tab(
                    child: Text("Notification",
                        style: TextStyle(color: Colors.black))),
                Tab(
                    child: Text("Reviews Map",
                        style: TextStyle(color: Colors.black)))
              ],
            ),
          ),
        ));
    // }
    // }
    //     return Center(child: CircularProgressIndicator(),);
    //
    //   },
    // );
  }
}
