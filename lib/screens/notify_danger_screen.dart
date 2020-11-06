import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class NotifyDangerScreen extends StatefulWidget {
  @override
  _NotifyDangerScreenState createState() => _NotifyDangerScreenState();
}

class _NotifyDangerScreenState extends State<NotifyDangerScreen> {
  DatabaseMethods _databaseMethods = DatabaseMethods();
  bool isLoading = false;

  showSentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text("Alert Sent"),
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

  alertButtonOnPress() async {
    setState(() {
      isLoading = true;
    });
    await _databaseMethods.sendDangerAlert();

    setState(() {
      isLoading = false;
      showSentDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isLoading,
      child: Stack(children: [
        Center(
          child: CircularPercentIndicator(
            progressColor: Colors.blueGrey,
            radius: 60,
            lineWidth: 5,
            percent:.5 ,
            startAngle: 35,
            center: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                height: 200,
                child: NeumorphicButton(
                  onPressed: alertButtonOnPress,
                  child: Center(child: Text("Alert")),
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.circle(),
                    depth: 8,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
