import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In
  Future<User?> _signInWithGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    return userCredential.user;
  }

  //   // // Microsoft Sign-In
  //   // Future<User?> _signInWithMicrosoft() async {
  //   //   // Microsoft OAuth 2.0 login
  //   //   final result = await FlutterMicrosoftAuthentication.login(
  //   //     clientId: "YOUR_MICROSOFT_CLIENT_ID", // Your Microsoft client ID from Azure portal
  //   //     scopes: ["User.Read"],
  //   //   );

  //   //   if (result != null && result.accessToken != null) {
  //   //     final OAuthCredential microsoftAuthCredential = OAuthProvider("microsoft.com").credential(
  //   //       accessToken: result.accessToken,
  //   //     );
  //   //     final UserCredential userCredential = await _auth.signInWithCredential(microsoftAuthCredential);
  //   //     return userCredential.user;
  //   //   }
  //   //   return null;
  //   // }

  //   // Microsoft OAuth Sign-In
  //   Future<User?> _signInWithMicrosoft() async {
  //     // Replace these with your Azure AD app's details
  //     const clientId =
  //         'ae504adf-7d2a-49eb-a7cd-06e94408b540'; // Your Microsoft Application (client) ID
  //     const tenantId =
  //         '7538b3a0-7ec7-4a03-82c7-b91e45e7e293'; // Your Directory (tenant) ID
  //     const redirectUri =
  //         'https://socialmedialogin-964d8.firebaseapp.com/__/auth/handler'; // You can use 'https://login.microsoftonline.com/common/oauth2/nativeclient'
  //     const scope = 'user.read'; // Add any other required scopes

  //     // Construct the authorization URL
  //     final authUrl =
  //         'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&response_mode=query&scope=$scope&state=12345';

  //     // Trigger the WebAuth flow
  //     final result = await FlutterWebAuth.authenticate(
  //       url: authUrl,
  //       callbackUrlScheme:
  //           'https://socialmedialogin-964d8.firebaseapp.com/__/auth/handler', // Example: com.myapp
  //     );

  //     // Extract the authorization code from the result
  //     final code = Uri.parse(result).queryParameters['code'];

  //     if (code != null) {
  //       // Exchange the authorization code for an access token
  //       final tokenUrl =
  //           'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';
  //       final response = await http.post(
  //         Uri.parse(tokenUrl),
  //         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  //         body: {
  //           'client_id': clientId,
  //           'scope': scope,
  //           'code': code,
  //           'redirect_uri': redirectUri,
  //           'grant_type': 'authorization_code',
  //         },
  //       );

  //       // Parse the response to get the access token
  //       final responseBody = jsonDecode(response.body);
  //       final accessToken = responseBody['access_token'];

  //       if (accessToken != null) {
  //         // Sign in with Firebase using the obtained access token
  //         final OAuthCredential microsoftCredential = OAuthProvider(
  //           "microsoft.com",
  //         ).credential(accessToken: accessToken);
  //         final UserCredential userCredential = await _auth.signInWithCredential(
  //           microsoftCredential,
  //         );
  //         return userCredential.user;
  //       }
  //     }
  //     return null;
  //   }

  final FlutterAppAuth appAuth = FlutterAppAuth();

  Future<User?> signInWithMicrosoft() async {
    try {
     
      const String clientId = 'ae504adf-7d2a-49eb-a7cd-06e94408b540';
      const String redirectUrl = 'com.example.socialmedialogin://auth';
      const List<String> scopes = [
        'openid',
        'email',
        'profile',
        'offline_access',
      ];

      final AuthorizationTokenResponse?
      result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          discoveryUrl:
              'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration',
          scopes: scopes,
          promptValues: ['login'], // optional: force login prompt
        ),
      );
      print("Microsoft sign-in result: $result");

      if (result != null) {
        final OAuthCredential credential = OAuthProvider(
          "microsoft.com",
        ).credential(idToken: result.idToken, accessToken: result.accessToken);

        // 🔐 Sign in with Firebase
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );

        print("Signed in as: ${userCredential.user?.email}");
        return userCredential.user;
      }
      return null;
    } catch (e) {
      print('Microsoft sign-in error: $e');
      return null;
    }
  }

  //   // Twitter Sign-In
  //   Future<User?> _signInWithTwitter() async {
  //     final twitterLogin = TwitterLogin(
  //       apiKey: 'F63X8r4QpIxW28wPmM79ng6yj',
  //       apiSecretKey: 'pWKqpdd2cuXXodeo3aOPztAnwhfbs5qccbKARAY1XeCyhnN0pf',
  //       redirectURI:
  //           'https://socialmedialogin-964d8.firebaseapp.com/__/auth/handler',
  //     );

  //     final authResult = await twitterLogin.login();
  //     if (authResult.status == TwitterLoginStatus.loggedIn) {
  //       final AuthCredential twitterAuthCredential =
  //           TwitterAuthProvider.credential(
  //             accessToken: authResult.authToken!,
  //             secret: authResult.authTokenSecret!,
  //           );
  //       final UserCredential userCredential = await _auth.signInWithCredential(
  //         twitterAuthCredential,
  //       );
  //       return userCredential.user;
  //     }
  //     return null;
  //   }

  //   // Sign-Out
  Future<void> _signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                User? user = await _signInWithGoogle();
                if (user != null) {
                  print('Logged in as ${user.displayName}');
                }
              },
              child: Text('Login with Google'),
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = await signInWithMicrosoft();
                if (user != null) {
                  print('Logged in as ${user.displayName}');
                }
              },
              child: Text('Login with Microsoft'),
            ),
            //             ElevatedButton(
            //               onPressed: () async {
            //                 User? user = await _signInWithTwitter();
            //                 if (user != null) {
            //                   print('Logged in as ${user.displayName}');
            //                 }
            //               },
            //               child: Text('Login with Twitter'),
            //             ),
            ElevatedButton(onPressed: _signOut, child: Text('Sign out')),
          ],
        ),
      ),
    );
  }
}
