import 'dart:convert';
import 'dart:math';

import 'package:fido2_client/fido2_client.dart';
import 'package:fido2_client/registration_result.dart';
import 'package:fido2_example_app/key_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'auth_api.dart';
import 'fido_registration.dart';

class LoggedInPage extends StatefulWidget {
  LoggedInPage({Key key, this.loggedInUser}) : super(key: key);
  String loggedInUser;
  @override
  _LoggedInPageState createState() => _LoggedInPageState();
}

class _LoggedInPageState extends State<LoggedInPage> {
  get loggedInUser => widget.loggedInUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Logged in as $loggedInUser'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Logged in page'),
          FutureBuilder<String>(
            future: KeyRepository.loadKeyHandle(loggedInUser),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if(!snapshot.hasData) {
                return RaisedButton(
                  child: Text('Press to go to FIDO credential registration page'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FidoRegistration(loggedInUser: loggedInUser)));
                  },
                );
              }
              else {
                return Container();
              }
            }
          )
        ],
      )
      )
    );
  }


}