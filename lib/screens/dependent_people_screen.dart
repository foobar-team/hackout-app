import 'package:flutter/material.dart';
import 'package:foobar/model/local_user.dart';
import 'package:foobar/screens/live_location.dart';
import 'package:foobar/services/database_methods.dart';

class DependentPeopleScreen extends StatefulWidget {
  @override
  _DependentPeopleScreenState createState() => _DependentPeopleScreenState();
}

class _DependentPeopleScreenState extends State<DependentPeopleScreen> {
  DatabaseMethods _databaseMethods = DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LocalUser>>(
      stream: _databaseMethods.getPeopleWhoTrustMe(),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          print("data available"+snapshot.data.length.toString());
          if(snapshot.data.isEmpty){
            return Center(child: Text("Everyone is feeling safe near you"),);
          }
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (_, index) {
              LocalUser user = snapshot.data[index];
              return Container(
                color: user.isSafe ? Colors.green : Colors.redAccent,
                child: ListTile(

                  leading: Icon(Icons.person),
                  title: Text(user.name),
                  subtitle: Text(user.isSafe ? "The Person is safe" : "Danger! Click to open live location"),

                  onTap: (){
                    if(!user.isSafe) {
                      Navigator.pushNamed(context, LiveLocation.route,
                          arguments: user);
                    }
                  },
                ),
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
