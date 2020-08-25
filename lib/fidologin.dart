import 'dart:convert';

import 'package:fido2_client/fido2_client.dart';
import 'package:fido2_example_app/key_repository.dart';
import 'package:flutter/material.dart';

import 'auth_api.dart';
import 'logged_in.dart';

class FidoLogin extends StatefulWidget {
  FidoLogin({Key key, this.username}) : super(key: key);
  String username;
  @override
  _FidoLoginPageState createState() => _FidoLoginPageState();
}

class _FidoLoginPageState extends State<FidoLogin> {
  TextEditingController _tc = TextEditingController();
  AuthApi _api = AuthApi();
  SigningOptions _signingOptions;

  get username => widget.username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Trying to login to $username using FIDO'),
        ),
        body: Center(
            child: Column(
              children: [
                Text('Request signing options and then use them to login with FIDO'),
                RaisedButton(
                    child: Text('Press to request signing options'),
                    onPressed: () async {
                      String username = _tc.text;
                      String keyHandle = await KeyRepository.loadKeyHandle(username);
                      if(keyHandle == null) return; // Error
                      SigningOptions response = await _api.signingRequest(username, keyHandle);
                      _signingOptions = response;
                    }
                ),
                RaisedButton(
                    child: Text('Press to sign using cred'),
                    onPressed: () async {
                      String username = _tc.text;
                      Fido2Client f = Fido2Client();
                      f.addSigningResultListener((keyHandle, clientData, authData, signature, userHandle) async {
                        KeyRepository.storeKeyHandle(keyHandle, username);
                        User u = await _api.signingResponse(username, keyHandle, _signingOptions.challenge, clientData, authData, signature, userHandle);
                        if(u.error == null) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoggedInPage(loggedInUser: username)));
                        }
                      });
                      String kh = await KeyRepository.loadKeyHandle(username);
                      f.initiateSigningProcess(kh, _signingOptions.challenge, _signingOptions.rpId);
                    }
                )
              ],
            )
        )
    );
  }


}