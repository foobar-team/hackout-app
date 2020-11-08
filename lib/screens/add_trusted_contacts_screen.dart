import 'package:flutter/material.dart';
import 'package:foobar/screens/home.dart';
import 'package:foobar/services/database_methods.dart';

class AddTrustedContactsScreen extends StatefulWidget {
  @override
  _AddTrustedContactsScreenState createState() =>
      _AddTrustedContactsScreenState();
}

class _AddTrustedContactsScreenState extends State<AddTrustedContactsScreen> {
  DatabaseMethods _databaseMethods = DatabaseMethods();
  TextEditingController phoneController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  addTrustedContact() async {
    setState(() {
      isLoading = true;
    });
    try {
      bool added = await _databaseMethods.addTrustedContact(
          mobileNumber: phoneController.text);
      if (added == true) {
        HomeScreen.scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Mobile number added as your trusted contact"),
        ));
        setState(() {
          isLoading = false;
        });
      } else if (added == false) {
        HomeScreen.scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Mobile number entered is not registered with us"),
        ));
        setState(() {
          isLoading = false;
        });
      } else {
        HomeScreen.scaffoldKey.currentState.showSnackBar(SnackBar(
          content:
              Text("Couldn't add trusted contact. Please try again later."),
        ));
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // TODO
      HomeScreen.scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Couldn't add trusted contact. Please try again later."),
      ));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneField = Padding(
        padding: EdgeInsets.all(8),
        child: TextFormField(
          controller: phoneController,
          validator: (value) {
            if (phoneController.text.trim().length == 10) {
              return null;
            }
            return "Enter a valid phone number";
          },
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone),
              hintText: "Phone Number",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
        ));
    final submitButton = ButtonTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
            height: 50,
            width: double.infinity,
            child: RaisedButton(
              color: Color(0xffdf1d38),
              child: Text(
                "Submit",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  try {
                    await addTrustedContact();
                  } catch (e) {
                    print(e.toString() + "ASDasdasda");
                  }
                }
              },
            )),
      ),
    );

    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  phoneField,
                  SizedBox(
                    height: 16,
                  ),
                  submitButton
                ],
              ),
            ),
          ),
        ),
        isLoading ? Center(child: CircularProgressIndicator(),) : Container()
      ],
    );
  }
}
