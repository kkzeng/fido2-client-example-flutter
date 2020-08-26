import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthApi {
  static const String BASE_URL =
      'https://webauthn-server-demo.herokuapp.com/auth';
  static const String TEST_URL = 'http://192.168.1.25:8080/auth';

  var _client = http.Client();

  Future<String> username(String username) async {
    var response = await _client.post('$BASE_URL/username',
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({'username': username}));
    String rawCookie = response.headers[HttpHeaders.setCookieHeader];
    if (rawCookie == null) return null;
    Cookie user = Cookie.fromSetCookieValue(rawCookie);
    print(response.body);
    return user.value;
  }

  Future<RegisterOptions> registerRequest(String username) async {
    var response = await _client.post('$BASE_URL/registerRequest',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.cookieHeader: 'username=$username; signed-in=yes',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: jsonEncode(
          {
            'attestation': 'none',
            'authenticatorSelection': {
              'authenticatorAttachment': 'platform',
              'userVerification': 'required'
            },
          },
        ));
    print(response.body);
    return _parseRegisterReq(response.body);
  }

  Future<User> registerResponse(String username, String challenge,
      String keyHandle, String clientDataJSON, String attestationObj) async {
    var response = await _client.post('$BASE_URL/registerResponse',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.cookieHeader:
              'username=$username; challenge=$challenge; signed-in=yes',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: jsonEncode(
          {
            'id': keyHandle,
            'type': 'public-key',
            'rawId': keyHandle,
            'response': {
              'clientDataJSON': clientDataJSON,
              'attestationObject': attestationObj,
            }
          },
        ));
    print(response.body);
    return _parseUser(response.body);
  }

  Future<SigningOptions> signingRequest(
      String username, String keyHandle) async {
    String url = '$BASE_URL/signingRequest';
    if (keyHandle != null) {
      url += '?credId=$keyHandle';
    }
    var response = await _client.post(url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.cookieHeader: 'username=$username',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: jsonEncode({}));
    print(response.body);
    return _parseSigningReq(response.body);
  }

  Future<User> signingResponse(
      String username,
      String keyHandle,
      String challenge,
      String clientData,
      String authData,
      String signature,
      String userHandle) async {
    String url = '$BASE_URL/signingResponse';
    var response = await _client.post(url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.cookieHeader: 'username=$username; challenge=$challenge',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: jsonEncode({
          'id': keyHandle,
          'type': 'public-key',
          'rawId': keyHandle,
          'response': {
            'clientDataJSON': clientData,
            'authenticatorData': authData,
            'signature': signature,
            'userHandle': userHandle ?? ''
          }
        }));
    print(response.body);
    return _parseUser(response.body);
  }

  Future<void> resetDB() async {
    await _client.post('$BASE_URL/resetDB',
        headers: {}, body: {});
  }

  RegisterOptions _parseRegisterReq(String responseBody) {
    var json = jsonDecode(responseBody);
    String rpId = json['rp']['id'];
    String rpName = json['rp']['name'];
    String username = json['user']['name'];
    String userId = json['user']['id'];
    int algoId = json['pubKeyCredParams'][0]['alg'];
    String challenge = json['challenge'];
    return RegisterOptions(
        rpId: rpId,
        rpName: rpName,
        userId: userId,
        username: username,
        algoId: algoId,
        challenge: challenge);
  }

  SigningOptions _parseSigningReq(String responseBody) {
    var json = jsonDecode(responseBody);
    String rpId = json['rpId'];
    String challenge = json['challenge'];
    return SigningOptions(rpId: rpId, challenge: challenge);
  }

  User _parseUser(String responseBody) {
    var json = jsonDecode(responseBody);
    if (json['error'] != null) {
      return User(error: json['error']);
    }
    String username = json['username'];
    String userId = json['id'];
    return User(username: username, id: userId);
  }
}

class User {
  User({this.username, this.id, this.error});

  String username;
  String id;
  String error;
}

class SigningOptions {
  SigningOptions({this.rpId, this.challenge});

  String rpId;
  String challenge;
}

class RegisterOptions {
  RegisterOptions(
      {this.rpId,
      this.rpName,
      this.userId,
      this.username,
      this.algoId,
      this.challenge});

  String rpId;
  String rpName;
  String username;
  String userId;
  int algoId;
  String challenge;
}
