import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
  });
  Future<UserModel> updateCurrency({
    required String userId,
    required String currency,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _google;

  AuthRemoteDataSourceImpl(this._auth, this._db, this._google);

  CollectionReference get _users => _db.collection(AppConstants.colUsers);

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((u) async {
      if (u == null) return null;
      try {
        return await _ensureUserDoc(u);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // On web, try popup first (works on desktop + modern mobile).
        // On iOS Safari it may fail — Firebase automatically falls back
        // to redirect. We handle the redirect result in authStateChanges
        // via the Firebase auth state listener, so no extra handling needed.
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');
        try {
          final uc = await _auth.signInWithPopup(provider);
          return await _ensureUserDoc(uc.user!);
        } on FirebaseAuthException catch (e) {
          // popup blocked or cancelled — fall back to redirect
          if (e.code == 'popup-blocked' ||
              e.code == 'popup-closed-by-user' ||
              e.code == 'cancelled-popup-request') {
            await _auth.signInWithRedirect(provider);
            // Redirect will reload the page — auth state listener picks it up
            // Return a dummy that won't be used (page reloads)
            throw const AuthException('redirect_initiated');
          }
          rethrow;
        }
      } else {
        final gUser = await _google.signIn();
        if (gUser == null) throw const AuthException('Sign-in cancelled');
        final gAuth = await gUser.authentication;
        final cred = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );
        final uc = await _auth.signInWithCredential(cred);
        return await _ensureUserDoc(uc.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (e.message == 'redirect_initiated') rethrow;
      throw AuthException(e.message ?? 'Firebase auth error');
    }
  }

  /// Ensures the user has a Firestore doc and returns the model.
  Future<UserModel> _ensureUserDoc(User fUser) async {
    final ref = _users.doc(fUser.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      final model = UserModel(
        id: fUser.uid,
        name: fUser.displayName ?? 'User',
        email: fUser.email ?? '',
        photoUrl: fUser.photoURL,
        createdAt: DateTime.now(),
      );
      await ref.set(model.toMap());
      return model;
    }
    return UserModel.fromFirestore(snap);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _google.signOut()]);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final u = _auth.currentUser;
    if (u == null) throw const AuthException('No signed-in user');
    final doc = await _users.doc(u.uid).get();
    if (!doc.exists) throw const AuthException('User not in Firestore');
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (data.isNotEmpty) await _users.doc(userId).update(data);
    if (name != null) await _auth.currentUser?.updateDisplayName(name);
    if (photoUrl != null) await _auth.currentUser?.updatePhotoURL(photoUrl);
    final doc = await _users.doc(userId).get();
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<UserModel> updateCurrency({
    required String userId,
    required String currency,
  }) async {
    await _users.doc(userId).update({'defaultCurrency': currency});
    final doc = await _users.doc(userId).get();
    return UserModel.fromFirestore(doc);
  }
}
