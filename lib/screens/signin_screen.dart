import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:foobar/screens/signup_screen.dart';
import 'package:foobar/services/auth_methods.dart';
import 'package:foobar/services/database_methods.dart';
import 'package:foobar/utils/user_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class SignInScreen extends StatefulWidget {
  static String route = "signin_screen_route";
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  AuthMethods _authMethods = AuthMethods();
  DatabaseMethods _databaseMethods = DatabaseMethods();

  void signIn() async {
    if (EmailValidator.validate(emailController.text) &&
        passwordController.text.trim().isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      try {
        auth.User user = await _authMethods.emailSignIn(
            emailController.text, passwordController.text);
        if (user != null) {
          SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
          sharedPreferences.setString("uid", user.uid);
          CONSTANT_UID = user.uid;
          await _databaseMethods.updateUserFcmToken(uid: user.uid);
          Navigator.pushReplacementNamed(context, HomeScreen.route);
        } else {

          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Something went wrong or Invalid Credentials"),
          ));

        }
        setState(() {
          isLoading = false;
        });
      } on Exception catch (e) {
        // TODO
        setState(() {
          isLoading = false;
        });
      }
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Email or Password invalid"),
      ));
    }
  }
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery
        .of(context)
        .size
        .height -
        MediaQuery
            .of(context)
            .padding
            .vertical;


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

    final signInButton = ButtonTheme(
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
                "Sign In",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () async {
                // if (_formKey.currentState.validate()) {
                  try {
                    signIn();
                  } catch (e) {
                    print(e.toString() + "ASDasdasda");
                  }
                // }
              },
            )),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [IgnorePointer(
          ignoring: isLoading,
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                   Text("Log In",style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF3D3D71),fontSize: 35),),
                  SizedBox(height: 50,),
                  emailField,
                  passwordField,
                  signInButton,
                  GestureDetector(
                    child: Text("Register",style: TextStyle(color: Color(0xFF3D3D71),fontSize: 20),),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, SignUpScreen.route);
                    },
                  )
                ],
              ),
            ),
          ),
        ),isLoading ? Center(child: CircularProgressIndicator()) : Container()]
      ),
    );
  }}
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
  //             onPressed: signIn,
  //             child: Text("Sign In"),
  //           ),
  //           GestureDetector(
  //             child: Text("Sign Up"),
  //             onTap: () {
  //               Navigator.pushReplacementNamed(context, SignUpScreen.route);
  //             },
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
// }
