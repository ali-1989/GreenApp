import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
  late GoogleSignIn signObj;
  GoogleSignInAccount? _googleUser;

  GoogleService(){
    if(kIsWeb){
      signObj = GoogleSignIn(
        //client_type:3
        clientId: '579668054514-ojuoo3o4cj1vjbcqfavq6upv9e8h4d1h.apps.googleusercontent.com',
        signInOption: SignInOption.standard,
        scopes: [
          'https://www.googleapis.com/auth/userinfo.email',
          //'https://accounts.google.com/o/oauth2/auth',
        ],
      );
    }
    else {
      signObj = GoogleSignIn();
      /*signObj = GoogleSignIn(
        signInOption: SignInOption.standard,
        scopes: [
          'https://www.googleapis.com/auth/userinfo.email',
          //'https://www.googleapis.com/auth/cloud-platform.read-only',
          //'https://www.googleapis.com/auth/contacts.readonly',
          //'https://accounts.google.com/o/oauth2/auth',
        ],
      );*/
    }
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      //_googleUser = await signObj.signInSilently().timeout(const Duration(seconds: 20));

      if(kIsWeb){
        _googleUser = await signObj.signIn().timeout(const Duration(minutes: 3));
      }
      else {
        _googleUser = await signObj.signIn().timeout(const Duration(seconds: 180));
      }

      print('A===========================A');
      print('${_googleUser?.displayName}');
      print('${_googleUser?.email}');

      final googleAuth = await _googleUser!.authentication;
      print('B===========================');
      print('${googleAuth.accessToken}');
      print('${googleAuth.idToken}');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('C===========================');
      final UserCredential loginUser = await FirebaseAuth.instance.signInWithCredential(credential);
      print(loginUser.user?.email);
      print(loginUser.user?.displayName);
      print(loginUser.user?.photoURL);
      print('End===========================');
    }
    catch (e) {print('eeeeee > $e');/**/}

    //return _googleUser;
  }

  Future<GoogleSignInAccount?> signOut() async {
    try {
      return await signObj.signOut();
    }
    catch (error) {
      return null;
    }
  }

  Future<bool> isSignIn() async {
    try {
      return await signObj.isSignedIn();
    }
    catch (error) {
      return false;
    }
  }
}
