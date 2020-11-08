import 'package:flutter/material.dart';
import 'package:foobar/screens/add_trusted_contacts_screen.dart';
import 'package:foobar/screens/all_notifications.dart';
import 'package:foobar/screens/dependent_people_screen.dart';
import 'package:foobar/screens/live_location.dart';
import 'package:foobar/screens/notify_danger_screen.dart';
import 'package:foobar/screens/review_map.dart';
import 'package:foobar/screens/signin_screen.dart';
import 'package:foobar/services/auth_methods.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:foobar/utils/methods.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  static String route = "home_route";
  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions = <Widget>[
    NotifyDangerScreen(),
    AllNotificationsScreen(),
    ReviewsMap(),
    DependentPeopleScreen(),
    AddTrustedContactsScreen(),
  ];



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
    return Scaffold(
      key: HomeScreen.scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "HelpHer",
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
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.announcement),
              label: 'Alert',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Reviews',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_history),
              label: 'Live',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail_rounded),
              label: 'Contacts',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFFFF7274),
          onTap: _onItemTapped,
        ));
  }
}
