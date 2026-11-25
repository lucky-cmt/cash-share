import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Remote authentication data source backed by Google Sign-In and Supabase Auth.
abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;
  final String? serverClientId;
  final String? clientId;
  bool _googleInitialized = false;

  AuthRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.googleSignIn,
    this.serverClientId,
    this.clientId,
  });

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
    _googleInitialized = true;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) return null;
      return UserModel.fromSupabaseUser(session.user);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final googleUser = await googleSignIn.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const ServerException(
          'Missing ID Token from Google. Ensure GOOGLE_WEB_CLIENT_ID in .env '
          'contains your Web Client ID (not Android Client ID).',
        );
      }

      String? accessToken;
      try {
        final authz = await googleUser.authorizationClient
            .authorizationForScopes(const ['email', 'profile']);
        accessToken = authz?.accessToken;
      } catch (_) {
        // accessToken is optional for Supabase signInWithIdToken when idToken is present.
      }

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) {
        throw const ServerException('Failed to sign in with Supabase.');
      }

      return UserModel.fromSupabaseUser(user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const ServerException('Google sign-in was cancelled.');
      }
      throw ServerException(e.description ?? e.toString());
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        supabaseClient.auth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user != null) {
        try {
          await supabaseClient
              .from('expense_splits')
              .delete()
              .eq('user_id', user.id);
        } catch (_) {}
        try {
          await supabaseClient
              .from('expenses')
              .delete()
              .eq('paid_by_user_id', user.id);
        } catch (_) {}
      }

      try {
        await googleSignIn.disconnect();
      } catch (_) {
        await googleSignIn.signOut();
      }
      await supabaseClient.auth.signOut();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
