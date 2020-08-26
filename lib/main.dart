import 'dart:convert';

import 'package:fido2_client/fido2_client.dart';
import 'package:fido2_example_app/fido_login.dart';
import 'package:fido2_example_app/key_repository.dart';
import 'package:fido2_example_app/logged_in.dart';
import 'package:flutter/material.dart';

import 'auth_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Fido 2 Client Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool startedLogin = false;
  bool loggedIn = false;
  TextEditingController _tc = TextEditingController();
  AuthApi _api = AuthApi();
  String keyHandle;

  Widget buildTextField() {
    return TextField(
      controller: _tc,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter a username',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildTextField(),
            (startedLogin && !loggedIn) ? CircularProgressIndicator(value: null) : RaisedButton(
              child: Text('Press to login'),
              onPressed: () async {
                setState(() => startedLogin = true);
                String username = _tc.text;
                await _api.username(username);
                setState(() => loggedIn = true);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoggedInPage(loggedInUser: username)));
              },
            ),
            RaisedButton(
              child: Text('Press to login with FIDO'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => FidoLogin(username: _tc.text)));
              }
            ),
            RaisedButton(
                child: Text('DEBUG: Press to reset everything'),
                onPressed: () async {
                  _api.resetDB(); // Server-side
                  KeyRepository.removeAllKeys(); // Client-side
                }
            )
          ],
        ),
      ),
    );
  }
}
