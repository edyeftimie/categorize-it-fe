import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final _instance = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '443168285776-ftsj11uqcrlr5epb1qba4kbn2rbrrqg5.apps.googleusercontent.com',
  );

  static Future<String?> getIdToken() async {
    try {
      final account = await _instance.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.idToken;
    } catch (e) {
      return null;
    }
  }

  static Future<void> signOut() => _instance.signOut();
}