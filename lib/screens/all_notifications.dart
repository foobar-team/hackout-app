import 'package:flutter/material.dart';
import 'package:foobar/model/danger_notification.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:foobar/utils/date_formatter.dart';
import 'package:foobar/utils/methods.dart';
import 'package:foobar/utils/user_constants.dart';
import 'package:intl/intl.dart';

class AllNotificationsScreen extends StatefulWidget {
  @override
  _AllNotificationsScreenState createState() => _AllNotificationsScreenState();
}

class _AllNotificationsScreenState extends State<AllNotificationsScreen> {
  DatabaseMethods _databaseMethods = DatabaseMethods();
  UtilMethods _utilMethods = UtilMethods();
  final DateFormat formatter = DateFormat('dd-MM-yyyy H:m');



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DangerNotification>>(
      stream: _databaseMethods.getAllAlertNotifications(uid:CONSTANT_UID),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          print("data available"+snapshot.data.length.toString());
          if(snapshot.data.isEmpty){
            return Center(child: Text("Everyone is feeling safe near you"),);
          }
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (_, index) {
              return ListTile(
                leading: Icon(Icons.add_alert),
                title: Text("DANGER"),
                subtitle: Text("Click to open the location in Maps"),
                trailing: Text(DateFormatter().getVerboseDateTimeRepresentation(DateTime.fromMillisecondsSinceEpoch(
                        snapshot.data[index].time)
                    )),
                onTap: () => _utilMethods.openMap(snapshot.data[index].latitude,
                    snapshot.data[index].longitude),
              );
            },
          );
        } else {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Text("Everyone is feeling safe in your area"),
            );
          }
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
