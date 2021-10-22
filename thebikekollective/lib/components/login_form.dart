import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/waiver_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';

class LoginFields {
  String? username;
  String? password;
  String toString() {
    return 'Username: $username, Password: $password';
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormFieldState> usernameKey = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> passwordKey = GlobalKey<FormFieldState>();

  bool loginSuccessful = false;

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = 60;
    final double buttonWidth = 260;

    return Form(
        key: formKey,
        child: Column(children: [
          Container(width: 325, child: usernameEntry()),
          SizedBox(height: 10),
          Container(width: 325, child: passwordEntry()),
          SizedBox(height: 10),
          loginButton(buttonWidth, buttonHeight),
        ]));
  }

  Widget usernameEntry() {
    return TextFormField(
        autofocus: true,
        key: usernameKey,
        style: TextStyle(color: Color(s_jungleGreen)),
        decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            hintText: 'E.g. BikeLover3000@tires.com',
            hintStyle: TextStyle(color: Color(s_jungleGreen)),
            errorStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
        onSaved: (value) {
          LoginFields().username = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter an email.';
          } else if (!loginSuccessful) {
            return 'Incorrect login or password!';
          } else {
            return null;
          }
        });
  }

  Widget passwordEntry() {
    return TextFormField(
        autofocus: true,
        key: passwordKey,
        obscureText: true,
        style: TextStyle(color: Color(s_jungleGreen)),
        decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            hintStyle: TextStyle(color: Color(s_jungleGreen)),
            errorStyle: TextStyle(
                color: Color(s_jungleGreen), fontWeight: FontWeight.bold),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(s_jungleGreen), width: 2.0))),
        onSaved: (value) {
          LoginFields().password = value;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a password.';
          } else if (!loginSuccessful) {
            return 'Incorrect login or password!';
          } else {
            return null;
          }
        });
  }

  Widget loginButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          loginSuccessful = await loginCheck(
              usernameKey.currentState!.value, passwordKey.currentState!.value);
          setState(() {});
          if (formKey.currentState!.validate()) {
            formKey.currentState?.save();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WaiverScreen()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
            primary: Color(s_jungleGreen),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: FormattedText(
          text: 'Login',
          size: s_fontSizeLarge,
          color: Colors.white,
          font: s_font_AmaticSC,
          weight: FontWeight.bold,
        ));
  }

  Future<bool> loginCheck(String? username, String? password) async {
    bool successfulLogin = false;
    var snapshotUsername = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    snapshotUsername.docs.forEach((result) {
      if (result.data()['password'] == password) {
        successfulLogin = true;
      }
    });
    return successfulLogin;
  }
}
