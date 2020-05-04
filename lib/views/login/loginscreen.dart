import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meditation/models/hexcode.dart';
import 'package:meditation/theme/primary.dart';
import 'package:meditation/views/main/navigation.dart';
import 'package:progress_dialog/progress_dialog.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class SignInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryTheme.nearlyWhite,
      body: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/logo_app.png', width: 80, height: 80),
              Text('เจริญสติ',
                  style: Theme.of(context).textTheme.headline,
                  textAlign: TextAlign.center),
              Container(height: 18.0),
              _AnonymouslySignInSection(),
              _GoogleSignInSection(),
            ]),
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.center,
      ),
    );
  }
}

class _AnonymouslySignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AnonymouslySignInSectionState();
}

class _AnonymouslySignInSectionState extends State<_AnonymouslySignInSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton.icon(
              icon: FaIcon(FontAwesomeIcons.userSecret),
              onPressed: () async {
                _signInAnonymously();
              },
              label: Text(
                  FlutterI18n.translate(context, 'auth.signInWithAnonymous'),
                  style: PrimaryTheme.body1)),
        ),
      ],
    );
  }

  // sign in anonymously.
  void _signInAnonymously() async {
    ProgressDialog pr = new ProgressDialog(context);
    pr.style(message: FlutterI18n.translate(context, 'auth.inProcess'));
    try {
      pr.show();
      final FirebaseUser user = (await _auth.signInAnonymously()).user;      
      assert(user != null);
      assert(user.isAnonymous);
      assert(!user.isEmailVerified);
      assert(await user.getIdToken() != null);
      if (Platform.isIOS) {
        // Anonymous auth doesn't show up as a provider on iOS
        assert(user.providerData.isEmpty);
      } else if (Platform.isAndroid) {
        // Anonymous auth does show up as a provider on Android
        assert(user.providerData.length == 1);
        assert(user.providerData[0].providerId == 'firebase');
        assert(user.providerData[0].uid != null);
        assert(user.providerData[0].displayName == null);
        assert(user.providerData[0].photoUrl == null);
        assert(user.providerData[0].email == null);
      }

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      
      if (user != null) {
        pr.hide();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationHomeScreen()),
        );
      }
    } catch (e) {
      pr.hide();
      print('Error: $e');
    }
  }
}

class _GoogleSignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoogleSignInSectionState();
}

class _GoogleSignInSectionState extends State<_GoogleSignInSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton.icon(
              icon: FaIcon(FontAwesomeIcons.google, color: HexColor('#D44638')),
              onPressed: () async {
                _signInWithGoogle();
              },
              label: Text(
                FlutterI18n.translate(context, 'auth.signInWithGmail'),
                style: PrimaryTheme.body1,
              )),
        )
      ],
    );
  }

  // sign in with google.
  void _signInWithGoogle() async {
    ProgressDialog pr = new ProgressDialog(context);
    pr.style(message: FlutterI18n.translate(context, 'auth.inProcess'));
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      pr.show();
      
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      
      if (user != null) {
        pr.hide();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationHomeScreen()),
        );
      }
    } catch (e) {
      pr.hide();
      print('Error: $e');
    }
  }
}
