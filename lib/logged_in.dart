import 'dart:convert';

import 'package:fido2_client/fido2_client.dart';
import 'package:fido2_example_app/key_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'auth_api.dart';

class LoggedInPage extends StatefulWidget {
  LoggedInPage({Key key, this.loggedInUser}) : super(key: key);
  String loggedInUser;
  @override
  _LoggedInPageState createState() => _LoggedInPageState();
}

class _LoggedInPageState extends State<LoggedInPage> {
  AuthApi _api = AuthApi();
  RegisterOptions _registerOptions;

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
          RaisedButton(
              child: Text('Press to request registration options'),
              onPressed: () async {
                _registerOptions = await _api.registerRequest(loggedInUser);
              }
          ),
          RaisedButton(
              child: Text('Press to register credentials'),
              onPressed: () async {
                Fido2Client f = Fido2Client();
                f.addRegistrationResultListener((keyHandle, clientData, attestationObj) async {
                  var clientDataJSON = base64Url.decode(clientData);
                  var str = utf8.decode(clientDataJSON);
                  KeyRepository.storeKeyHandle(keyHandle, loggedInUser);
                  User u = await _api.registerResponse(loggedInUser, _registerOptions.challenge, keyHandle, clientData, attestationObj);
                  if(u.error == null) {
                    print('Successful registration');
                  }
                });
                f.initiateRegistrationProcess(_registerOptions.challenge, _registerOptions.userId, _registerOptions.username, _registerOptions.rpId, _registerOptions.rpName, _registerOptions.algoId);
              }
          ),
        ],
      )
      )
    );
  }


}