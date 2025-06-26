import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:auth_buttons/auth_buttons.dart';
// import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:socialmedialogin/welcomepage.dart';

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

  final FlutterAppAuth appAuth = FlutterAppAuth();

  Future<Map<String, dynamic>?> signInWithMicrosoft() async {
    try {
      const String clientId =
          'ae504adf-7d2a-49eb-a7cd-06e94408b540'; // Replace with your actual client ID
      const String redirectUrl =
          'com.example.socialmedialogin://auth'; // Must match AndroidManifest and Azure
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
              'https://login.microsoftonline.com/7538b3a0-7ec7-4a03-82c7-b91e45e7e293/v2.0/.well-known/openid-configuration',
          scopes: scopes,
          promptValues: ['login'], // Optional
          preferEphemeralSession: true, // Optional: avoids previous cache
        ),
      );

 

      if (result == null) {
        print('❌ Authorization failed or cancelled');
        return null;
      }
      print("✅ Authorization successful");

   

      return {'accessToken': result.accessToken};
    } catch (e) {
      print('❌ Microsoft sign-in error: $e');
    
      return null;
    }
  }

  Future<Map<String, dynamic>> getMicrosoftUserInfo(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://graph.microsoft.com/v1.0/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch Microsoft user profile');
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

  // Future<UserCredential> signInWithFacebook() async {
  //   final LoginResult result = await FacebookAuth.i.login();
  //   final credential = FacebookAuthProvider.credential(
  //     result.accessToken!.token,
  //   );
  //   return await FirebaseAuth.instance.signInWithCredential(credential);
  // }

  Future<void> signInWithFacebook() async {
    try {
      

      final LoginResult result = await FacebookAuth.instance.login(
        loginBehavior: LoginBehavior.webOnly, // Forces web-based login dialog
        permissions: [
          'public_profile',
          'email',
        ], // Explicitly request these permissions
      );

      if (result.status != LoginStatus.success) {
        print('❌ Facebook login failed: ${result.message}');
        return null;
      }

      final fbUserData = await FacebookAuth.instance.getUserData(
        fields: "name,email,picture.width(200)",
      );

      if (fbUserData['name'] == null || fbUserData['email'] == null) {
        throw Exception('Incomplete user data received');
      }

      // 6. Create UserData object
      final userData = UserData(
        name: fbUserData['name'],
        email: fbUserData['email'],
        provider: 'Facebook',
      );

      print('✅ Facebook Name: ${userData.name}');
      print('📧 Facebook Email: ${userData.email}');

      // 7. Navigate to WelcomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomePage(user: userData)),
      );

      // final OAuthCredential credential = FacebookAuthProvider.credential(
      //   result.accessToken!.token,
      // );

      // 5. Sign in to Firebase
      // final UserCredential userCredential = await FirebaseAuth.instance
      //     .signInWithCredential(credential);
      // print('✅ Firebase user signed in: ${userCredential.user?.displayName}');
      // // 6. Return the Firebase user
      // // return userCredential.user;
    } catch (e) {
      print('🔥 Facebook login error: $e');
      return null;
    }
  }

  //   // Sign-Out

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Page')),
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            GoogleAuthButton(
              onPressed: () async {
                User? user = await _signInWithGoogle();

                if (user != null) {
                  // Create UserData object
                  final userData = UserData(
                    name: user.displayName,
                    email: user.email,
                    provider: 'Google',
                  );

                  print('✅ Google Name: ${userData.name}');
                  print('📧 Google Email: ${userData.email}');

                  // Navigate to WelcomePage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WelcomePage(user: userData),
                    ),
                  );
                }
                
              },
              style:
                AuthButtonStyle(buttonType: AuthButtonType.icon)
            
            ),
            MicrosoftAuthButton(
              onPressed: () async {
                final result = await signInWithMicrosoft();
                if (result != null) {
                  final userInfo = await getMicrosoftUserInfo(
                    result['accessToken']!,
                  );

                  // Create UserData object
                  final userData = UserData(
                    name: userInfo['displayName'],
                    email: userInfo['mail'] ?? userInfo['userPrincipalName'],
                    provider: 'Microsoft',
                  );

                  print('✅ Microsoft Name: ${userData.name}');
                  print('📧 Microsoft Email: ${userData.email}');

                  // Navigate to WelcomePage
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WelcomePage(user: userData),
                    ),
                  );
                }
              },
               style:
                AuthButtonStyle(buttonType: AuthButtonType.icon)
            ),

            FacebookAuthButton(
              onPressed: () async {
                await signInWithFacebook();
              },
               style:
                AuthButtonStyle(buttonType: AuthButtonType.icon)
            ),
          ],
        ),
      ),
    );
  }
}
