import 'package:app/views/sign_in/google_stub_button.dart';
import 'package:flutter/material.dart';

Widget buildSignInButton({HandleSignInFn? onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    child: const Text('SIGN IN'),
  );
}