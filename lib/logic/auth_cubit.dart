import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/base_state.dart';

class AuthCubit extends Cubit<BaseState<User>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int _requestId = 0;
  bool _sendingOtp = false;

  AuthCubit() : super(const BaseState());

  /// Resolves only after codeSent, automatic sign-in, or a failure.
  Future<bool> sendOtp(String phoneNumber) async {
    if (_sendingOtp) return false;
    if (!RegExp(r'^\+91[6-9][0-9]{9}$').hasMatch(phoneNumber)) {
      emit(const BaseState(error: 'Enter a valid 10-digit mobile number.'));
      return false;
    }

    _sendingOtp = true;
    final requestId = ++_requestId;
    final result = Completer<bool>();
    _verificationId = null;
    emit(const BaseState(isLoading: true));

    bool isCurrent() => !isClosed && requestId == _requestId;
    void finish(bool success) {
      if (!result.isCompleted) result.complete(success);
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          if (!isCurrent()) return;
          await _signIn(credential);
          if (isCurrent()) finish(state.data != null);
        },
        verificationFailed: (error) {
          if (!isCurrent()) return;
          emit(BaseState(error: error.message ?? 'Verification failed.'));
          finish(false);
        },
        codeSent: (verificationId, resendToken) {
          if (!isCurrent()) return;
          _verificationId = verificationId;
          if (state.data == null) emit(const BaseState());
          finish(true);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (!isCurrent()) return;
          _verificationId = verificationId;
          // A normal auto-retrieval timeout does not invalidate a sent OTP.
        },
      );
      return await result.future.timeout(const Duration(seconds: 90));
    } on FirebaseAuthException catch (error) {
      if (isCurrent()) {
        emit(BaseState(error: error.message ?? 'Could not send OTP.'));
      }
      return false;
    } catch (_) {
      if (isCurrent()) {
        emit(const BaseState(error: 'Could not send OTP. Please try again.'));
      }
      return false;
    } finally {
      _sendingOtp = false;
      if (!result.isCompleted) {
        // Ignore callbacks belonging to a failed or timed-out request.
        _requestId++;
        finish(false);
      }
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    if (state.isLoading) return;
    if (!RegExp(r'^[0-9]{6}$').hasMatch(smsCode)) {
      emit(const BaseState(error: 'Enter the complete 6-digit code.'));
      return;
    }
    if (_verificationId == null) {
      emit(const BaseState(error: 'No verification in progress. Request a new code.'));
      return;
    }

    emit(const BaseState(isLoading: true));
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    await _signIn(credential);
  }

  Future<void> _signIn(PhoneAuthCredential credential) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      if (!isClosed) emit(BaseState(data: result.user));
    } on FirebaseAuthException catch (error) {
      if (!isClosed) {
        emit(BaseState(error: error.message ?? 'Sign-in failed.'));
      }
    } catch (_) {
      if (!isClosed) {
        emit(const BaseState(error: 'Sign-in failed. Please try again.'));
      }
    }
  }

  bool get isSignedIn => _auth.currentUser != null;

  @override
  Future<void> close() {
    _requestId++;
    return super.close();
  }
}
