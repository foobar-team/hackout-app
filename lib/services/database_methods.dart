import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:foobar/model/danger_notification.dart';
import 'package:foobar/model/local_location.dart';
import 'package:foobar/model/local_user.dart';
import 'package:foobar/utils/user_constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';

class DatabaseMethods {
  FirebaseFirestore _database = FirebaseFirestore.instance;
  FirebaseMessaging _fcm = FirebaseMessaging();

  Future createUserDocument(
      {String email,
      String name,
      String uid,
      String phone,
      String city,
      String aadhar}) async {
    try {
      await _database.collection("users").doc(uid).set(
        {
          "email": email,
          "name": name,
          "uid": uid,
          "phone": phone,
          "city": city,
          "aadhar": aadhar,
          "isSafe":true,
        },
      );
      print(email);
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future createReviewDocument({
    String city,
    int crowd,
    int lighting,
    String locality,
    Map location,
    int policeStation,
    int safeForWomen,
    int safeToVisit,
    int altRoutes,
    int score,
  }) async {
    try {
      await _database.collection("reviews").add(
        {
          "city": city,
          "lighting": lighting,
          "locality": locality,
          "location": location,
          "policeStation": policeStation,
          "safeForWomen": safeForWomen,
          "safeToVisit": safeToVisit,
          "altRoutes": altRoutes,
          "score": score
        },
      );
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future updateUserLocation({Position location, String uid}) async {
    try {
      await _database.collection("users").doc(uid).update(
        {
          "location": {
            "longitude": location.longitude,
            "latitude": location.latitude
          },
        },
      );
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future updateUserFcmToken({String uid}) async {
    try {
      String token = await _fcm.getToken();
      await _database.collection("users").doc(uid).update(
        {"fcmToken": token},
      );
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future getUserInfo() async {
    try {
      print("userid: ");
      // print(CONSTANT_UID);
      String uid = CONSTANT_UID;
      return await _database.collection("users").doc(uid).get();
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  Future _triggerAlertCloudFunction() async {
    Position userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendDangerAlert',
    );
    await _database.collection("users").doc(CONSTANT_UID).update({"isSafe":false});
    await callable.call(<String, dynamic>{
      'latitude': userLocation.latitude,
      'longitude': userLocation.longitude,
      'uid': CONSTANT_UID
    });
  }

  Future _triggerSafeCloudFunction() async {
    Position userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'sendDangerAlert',
    );
    await callable.call(<String, double>{
      'latitude': userLocation.latitude,
      'longitude': userLocation.longitude
    });
  }

  Future sendDangerAlert() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (LocationPermission.denied.index == permission.index) {
        LocationPermission permission2 = await Geolocator.requestPermission();

        if (LocationPermission.whileInUse.index == permission2.index ||
            LocationPermission.always.index == permission2.index) {
          await _triggerAlertCloudFunction();
        }
      } else if (LocationPermission.whileInUse.index == permission.index ||
          LocationPermission.always.index == permission.index) {
        await _triggerAlertCloudFunction();
      }
    } on Exception catch (e) {}
  }

  Future sendSafeAlert() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (LocationPermission.denied.index == permission.index) {
        LocationPermission permission2 = await Geolocator.requestPermission();

        if (LocationPermission.whileInUse.index == permission2.index ||
            LocationPermission.always.index == permission2.index) {
          await _triggerAlertCloudFunction();
        }
      } else if (LocationPermission.whileInUse.index == permission.index ||
          LocationPermission.always.index == permission.index) {
        await _triggerAlertCloudFunction();
      }
    } on Exception catch (e) {}
  }

  Stream<List<DangerNotification>> getAllAlertNotifications({String uid}) {
    // _database.collection("collectionPath").doc("Asd").collection("asd").snapshots();
    return _database
        .collection("users")
        .doc(uid)
        .collection("dangerNotifications")
        .orderBy("time", descending: true)
        .snapshots()
        .map((event) {
      print(event);

      return event.docs.map((e) {
        print(e.data()["location"]["latitude"]);
        return DangerNotification(
            latitude: e.data()["location"]["latitude"],
            longitude: e.data()["location"]["longitude"],
            time: e.data()["time"]);
      }).toList();
    });
  }

  Future<bool> isMobileNumberRegistered({String phone}) async {
    QuerySnapshot querySnapshot = await _database
        .collection("users")
        .where("phone", isEqualTo: phone)
        .get();
    if (querySnapshot.docs.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addTrustedContact({String mobileNumber}) async {
    QuerySnapshot querySnapshot = await _database
        .collection("users")
        .where("phone", isEqualTo: mobileNumber)
        .get();
    if (querySnapshot.docs.length > 0) {
      await _database.collection("users").doc(CONSTANT_UID).update({
        "trustedContacts":
            FieldValue.arrayUnion([querySnapshot.docs[0].data()["uid"]])
      });
      return true;
    } else {
      return false;
    }
  }

  Stream<List<LocalUser>> getPeopleWhoTrustMe() {
    Stream<List<LocalUser>> stream =  _database
        .collection("users")
        .where("trustedContacts", arrayContains: CONSTANT_UID)
        .snapshots()
        .map((event) => event.docs
            .map((e) => firebaseUserToLocalUser(snapshot: e))
            .toList());
    stream.listen((event) {print(event.toString()+"hell");});
    return stream;
  }

  LocalUser firebaseUserToLocalUser({QueryDocumentSnapshot snapshot}) {
    return LocalUser(
        name: snapshot["name"],
        adhaar: snapshot["aadhar"],
        city: snapshot["city"],
        isSafe: snapshot["isSafe"],
        phone: snapshot["phone"],
        uid: snapshot["uid"]);
  }

  Stream<LocalLocation> getUserLiveLocation({String uid}) {
    return _database.collection("liveLocations").doc(uid).snapshots().map(
        (event) => LocalLocation(
            latitude: event.data()["location"]["coords"]["latitude"],
            longitude: event.data()["location"]["coords"]["longitude"]));
  }
}
