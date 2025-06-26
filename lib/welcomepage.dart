import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:socialmedialogin/loginpage.dart';

class UserData {
  final String? name;
  final String? email;

  final String provider;

  UserData({required this.name, required this.email, required this.provider});
}

class WelcomePage extends StatelessWidget {
  final UserData user;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  const WelcomePage({Key? key, required this.user}) : super(key: key);

  Future<void> _signOutMicrosoft() async {
  try {
    // Microsoft OAuth logout URL
    const String logoutUrl = 'https://login.microsoftonline.com/common/oauth2/v2.0/logout'
        '?post_logout_redirect_uri=com.example.socialmedialogin://auth'; // Must match your redirect URI

    // Open browser for logout (clears Microsoft session cookies)
    await FlutterWebAuth2.authenticate(
      url: logoutUrl,
      callbackUrlScheme: 'com.example.socialmedialogin', // Your app's custom scheme
    );
  } catch (e) {
    print('Microsoft sign-out may have failed: $e');
  }
}

  Future<void> _signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    if (user.provider == 'Microsoft') {
      await _signOutMicrosoft();
    }

    await FacebookAuth.instance.logOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.name}'),
            Text('Logged in via ${user.provider}'),
            Text(user.email ?? ''),
            ElevatedButton(
              onPressed: () {
                _signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
