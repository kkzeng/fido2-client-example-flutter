import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthApi {
  static const String BASE_URL = 'https://webauthn-server-demo.herokuapp.com/auth';
  static const String TEST_URL = 'http://192.168.1.25:8080/auth';


  var _client = http.Client();

  Future<String> username(String username) async {
    var response = await _client.post('$TEST_URL/username',
        headers: { HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({'username': username}));
    String rawCookie = response.headers[HttpHeaders.setCookieHeader];
    if (rawCookie == null) return null;
    Cookie user = Cookie.fromSetCookieValue(rawCookie);
    return user.value;
  }

  Future<RegisterOptions> registerRequest(String username) async {
    var response = await _client.post('$TEST_URL/registerRequest',
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
    return _parseRegisterReq(response.body);
  }

  Future<void> registerResponse(String username, String challenge, String keyHandle, String clientDataJSON, String attestationObj) async {
    var response = await _client.post('$TEST_URL/registerResponse',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.cookieHeader: 'username=$username; signed-in=yes',
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
        )
    );
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
}

class RegisterOptions {
  RegisterOptions({this.rpId, this.rpName, this.userId, this.username, this.algoId, this.challenge});
  String rpId;
  String rpName;
  String username;
  String userId;
  int algoId;
  String challenge;
}