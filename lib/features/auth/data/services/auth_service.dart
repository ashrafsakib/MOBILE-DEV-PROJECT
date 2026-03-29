import 'package:abroadready/core/firestore/schemas/schemas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  bool get isSignedIn => _firebaseAuth.currentUser != null;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Unable to create account right now. Please try again.',
      );
    }

    await user.updateDisplayName(fullName);

    final appUser = AppUser.fromFirebaseAuth(
      user,
    ).copyWith(displayName: fullName);

    await _upsertUserProfile(appUser);
  }

  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..setCustomParameters({'prompt': 'select_account'});

    await _signInWithProvider(provider);
  }

  Future<void> signInWithGithub() async {
    final provider = GithubAuthProvider();
    await _signInWithProvider(provider);
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  Future<void> _signInWithProvider(AuthProvider provider) async {
    final userCredential = await _firebaseAuth.signInWithProvider(provider);
    final user = userCredential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to complete sign in. Please try again.',
      );
    }

    await _upsertUserProfile(AppUser.fromFirebaseAuth(user));
  }

  Future<void> _upsertUserProfile(AppUser appUser) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(appUser.uid)
        .set(appUser.toMap(), SetOptions(merge: true));
  }

  String readableErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email or password.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'Password is too weak. Use at least 8 characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Check your internet connection.';
        case 'user-not-created':
          return 'Unable to create account right now. Please try again.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with different sign-in method.';
        case 'popup-closed-by-user':
        case 'web-context-cancelled':
          return 'Sign in was cancelled.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled for this app.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }

    return 'Something went wrong. Please try again.';
  }
}
