import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/base_state.dart';

class AuthCubit extends Cubit<BaseState<User>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  AuthCubit() : super(const BaseState());

  Future<void> sendOtp(String phoneNumber) async {
    print('sendOtp called with: $phoneNumber');
    emit(state.copyWith(isLoading: true, error: null));

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (PhoneAuthCredential credential) async {
        print('verificationCompleted fired');
        await _signIn(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        print('verificationFailed: ${e.code} - ${e.message}');
        emit(state.copyWith(isLoading: false, error: e.message ?? 'Verification failed'));
      },

      codeSent: (String verificationId, int? resendToken) {
        print('codeSent fired, verificationId: $verificationId');
        _verificationId = verificationId;
        emit(state.copyWith(isLoading: false));
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        print('codeAutoRetrievalTimeout fired');
        _verificationId = verificationId;
      },
    );
  }

  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      emit(state.copyWith(error: 'No verification in progress'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    await _signIn(credential);
  }

  Future<void> _signIn(PhoneAuthCredential credential) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      emit(state.copyWith(isLoading: false, data: result.user));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message ?? 'Sign-in failed'));
    }
  }

  bool get isSignedIn => _auth.currentUser != null;
}