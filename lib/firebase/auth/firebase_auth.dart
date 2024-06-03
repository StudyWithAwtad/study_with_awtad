// This file is dedicated to implement all the firebase authentication functions and logics
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;

void createUserWithPhoneNumber(String phoneNumber) async {
  try {
    await auth.verifyPhoneNumber(
      phoneNumber: '+972 55 111 2233',
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android Only, Automatic handling of the SMS code on Android devices
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle failure events such as invalid phone numbers or whether the SMS quota has been exceeded
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code.
        // Update the UI - wait for the user to enter the SMS code
        String smsCode = '123456';
        print('verificationId: ${verificationId}');
        // Create a PhoneAuthCredential with the code
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: smsCode);
        print('PhoneAuthCredential: ${credential}');
        // Sign the user in (or link) with the credential
        // Return type UserCredential, We need the UserCredential.user
        UserCredential result = await auth.signInWithCredential(credential);
        print('UserCredential: ${result}');
        String? jwt = await result.user?.getIdToken();
        print('UserCredential: ${jwt}');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle a timeout of when automatic SMS code handling fails.
      },
    );
  } catch (e) {
    print('Error with verifyPhoneNumber: ${e}');
  }
}

// Create and login new user by providing email and password
Future<UserCredential?> createUser(String email, String password) async {
  try {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
    return null;
  } catch (e) {
    print(e);
    return null;
  }
}
