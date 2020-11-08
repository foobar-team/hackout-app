import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foobar/screens/home.dart';
import 'package:foobar/screens/signin_screen.dart';
import 'package:foobar/services/auth_methods.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:foobar/utils/user_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  static String route = "signup_screen_route";

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController aadharController = TextEditingController();

  bool isLoading = false;

  AuthMethods _authMethods = AuthMethods();
  DatabaseMethods _databaseMethods = DatabaseMethods();

  bool isValidPhoneNumber(String phoneNumber) {
  final pattern = r'^[0-9]*$';
  final regExp = RegExp(pattern);

  if (phoneNumber == null || phoneNumber.isEmpty) {
    return false;
  }

  if (!regExp.hasMatch(phoneNumber)) {
    return false;
  }
  if(phoneNumber.length!=10){
    return false;
  }
  return true;
}
bool isValidAadharNumber(String aadharNumber) {
  final pattern = r'^[0-9]*$';
  final regExp = RegExp(pattern);

  if (aadharNumber == null || aadharNumber.isEmpty) {
    return false;
  }

  if (!regExp.hasMatch(aadharNumber)) {
    return false;
  }
  if(aadharNumber.length!=12){
    return false;
  }
  return true;
}

  void signUp() async {
    if (EmailValidator.validate(emailController.text) &&
        passwordController.text.trim().isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      try {
        User user = await _authMethods.emailSignUp(
            emailController.text, passwordController.text);
        if (user != null) {
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString("uid", user.uid);
          CONSTANT_UID = user.uid;
          await _databaseMethods.createUserDocument(
              email: user.email,
              uid: user.uid,
              name: nameController.text,
              phone: phoneController.text,
              aadhar: aadharController.text,
              city: cityController.text);
          await _databaseMethods.updateUserFcmToken(uid: user.uid);

          Navigator.pushReplacementNamed(context, HomeScreen.route);
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Something went wrong"),
          ));
        }
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        // TODO
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Email or Password invalid"),
      ));
    }
  }

  //  TextEditingController emailController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.vertical;

    final emailField = Padding(
        padding: EdgeInsets.all(8),
        child: TextFormField(
          controller: emailController,
          validator: (value) {
            if (EmailValidator.validate(value)) {
              return null;
            }
            return "Enter valid Email";
          },
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.email),
              hintText: "Email",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
        ));

    final nameField = Padding(
        padding: EdgeInsets.all(8),
        child: TextFormField(
          controller: nameController,
          validator: (value) {
            if (value.trim().isNotEmpty) {
              return null;
            }
            return "Enter valid Name";
          },
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              hintText: "Name",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
        ));

    final phoneField = Padding(
        padding: EdgeInsets.all(8),
        child: TextFormField(
          controller: phoneController,
          validator: (value) {
            if (isValidPhoneNumber(value)) {
              return null;
            }
            return "Enter a 10 digit valid Phone No.";
          },
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone),
              hintText: "Phone No.",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
        ));

    final cityField = Padding(
        padding: EdgeInsets.all(8),
        child: TextFormField(
          controller: cityController,
          validator: (value) {
            if (value.trim().isNotEmpty) {
              return null;
            }
            return "Enter valid City Name";
          },
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_city),
              hintText: "City",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
        ));

    final aadharField = Padding(
        padding: EdgeInsets.all(8),
        child: TextFormField(
          controller: aadharController,
          validator: (value) {
            if (isValidAadharNumber(value)) {
              return null;
            }
            return "Enter valid Aadhar No.";
          },
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.perm_identity),
              hintText: "Aadhar",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
        ));

    final passwordField = Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        obscureText: true,
        validator: (value) {
          if (value.length >= 6) {
            return null;
          }
          return "Password should be atleast 6 character long";
        },
        controller: passwordController,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.vpn_key),
            hintText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8)),
      ),
    );

    final signUpButton = ButtonTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
            height: availableHeight * .06,
            width: double.infinity,
            child: RaisedButton(
              color: Color(0xffdf1d38),
              child: Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  try {
                    signUp();
                  } catch (e) {
                    print(e.toString() + "ASDasdasda");
                  }
                }
              },
            )),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      body:  Stack(children: [
          IgnorePointer(
            ignoring: isLoading,
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Sign Up",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                              fontSize: 35),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        nameField,
                        emailField,
                        phoneField,
                        cityField,
                        aadharField,
                        passwordField,
                        signUpButton,
                        GestureDetector(
                          child: Text(
                            "Log In",
                            style: TextStyle(color: Colors.blueGrey, fontSize: 20),
                          ),
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, SignInScreen.route);
                          },
                        )
                      ],
                    ),

                ),
              ),
            ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container()
        ]),

    );
  }
}

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     key: _scaffoldKey,
//     body: Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: emailController,
//             decoration: InputDecoration(hintText: "Email"),
//           ),
//           TextField(
//             controller: passwordController,
//             decoration: InputDecoration(hintText: "Password"),
//           ),
//           RaisedButton(
//             onPressed: signUp,
//             child: Text("Sign Up"),
//           ),
//           GestureDetector(
//             child: Text("Sign In"),
//             onTap: () {
//               Navigator.pushReplacementNamed(context, SignInScreen.route);
//             },
//           )
//         ],
//       ),
//     ),
//   );
// }}
