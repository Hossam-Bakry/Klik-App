import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/services/otp_cooldown_store.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/social_account.dart';
import '../../domain/usecases/get_current_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/send_phone_otp_usecase.dart';
import '../../domain/usecases/social_sign_in_usecase.dart';
import '../../domain/usecases/verify_phone_otp_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// App-level BLoC: its lifecycle spans the whole app and the router's
/// `redirect` guard reacts to its state. Because of that it's the one BLoC we
/// register as a singleton in get_it (unlike page-scoped BLoCs like Catalog).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
    required GetCurrentSessionUseCase getCurrentSession,
    required SocialSignInUseCase socialSignIn,
    required VerifyPhoneOtpUseCase verifyPhoneOtp,
    required SendPhoneOtpUseCase sendPhoneOtp,
    required OtpCooldownStore otpCooldown,
  }) : _login = login,
       _register = register,
       _logout = logout,
       _getCurrentSession = getCurrentSession,
       _socialSignIn = socialSignIn,
       _verifyPhoneOtp = verifyPhoneOtp,
       _sendPhoneOtp = sendPhoneOtp,
       _otpCooldown = otpCooldown,
       super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthSocialSignInRequested>(_onSocialSignInRequested);
    on<AuthPhoneOtpSubmitted>(_onPhoneOtpSubmitted);
    on<AuthPhoneOtpRequested>(_onPhoneOtpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final GetCurrentSessionUseCase _getCurrentSession;
  final SocialSignInUseCase _socialSignIn;
  final VerifyPhoneOtpUseCase _verifyPhoneOtp;
  final SendPhoneOtpUseCase _sendPhoneOtp;
  final OtpCooldownStore _otpCooldown;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Must always resolve so the splash guard can advance — a failed secure
    // storage read (e.g. iOS Keychain error) falls back to unauthenticated
    // rather than leaving the app stuck on the splash screen.
    AuthSession? session;
    try {
      session = await _getCurrentSession();
    } catch (_) {
      session = null;
    }
    emit(
      state.copyWith(
        status: session != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        session: session,
      ),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    final result = await _login(
      phone: event.phone,
      password: event.password,
      countryIso: event.countryIso,
      countryCode: event.countryCode,
    );
    _emitAuthResult(result, emit);
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    // Registration creates the account and triggers the activation OTP; it does
    // NOT authenticate. On success we surface the phone awaiting verification
    // so the UI advances to the verify-phone screen.
    final result = await _register(
      name: event.name,
      email: event.email,
      password: event.password,
      phone: event.phone,
      country: event.country,
      countryIso: event.countryIso,
      countryCode: event.countryCode,
      gender: event.gender,
    );
    switch (result) {
      case ApiSuccess():
        // Account created. The OTP itself is requested when the verify screen
        // opens (AuthPhoneOtpRequested), so a same-number re-entry within the
        // cooldown reuses the live code instead of sending a new one.
        emit(
          state.copyWith(
            isSubmitting: false,
            pendingVerification: PendingPhoneVerification(
              phone: event.phone,
              countryIso: event.countryIso,
              countryCode: event.countryCode,
            ),
          ),
        );
      case ApiFailure(:final failure):
        emit(
          state.copyWith(isSubmitting: false, errorMessage: failure.message),
        );
    }
  }

  /// Verify the activation OTP for the pending phone; success activates the
  /// account and yields an authenticated session.
  Future<void> _onPhoneOtpSubmitted(
    AuthPhoneOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final pending = state.pendingVerification;
    if (pending == null) return;
    emit(state.copyWith(isSubmitting: true));
    final result = await _verifyPhoneOtp(
      phone: pending.phone,
      otp: event.otp,
      countryIso: pending.countryIso,
      countryCode: pending.countryCode,
    );
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            session: data,
            isSubmitting: false,
            clearPendingVerification: true,
          ),
        );
      case ApiFailure(:final failure):
        emit(
          state.copyWith(isSubmitting: false, errorMessage: failure.message),
        );
    }
  }

  /// Request an OTP for the pending phone, honoring the persistent per-phone
  /// cooldown: if the same number was sent a code that's still within its
  /// window, skip the call and let the live code stand; otherwise send and
  /// (re)start the cooldown. A changed number has no active window, so it sends.
  Future<void> _onPhoneOtpRequested(
    AuthPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    final pending = state.pendingVerification;
    if (pending == null) return;
    if (!_otpCooldown.canRequest(pending.phone)) return;
    final result = await _sendPhoneOtp(
      phone: pending.phone,
      countryIso: pending.countryIso,
      countryCode: pending.countryCode,
    );
    switch (result) {
      case ApiSuccess():
        // Start the cooldown from now (persisted; survives navigation). The
        // verify screen's per-second tick re-reads the store, so no emit needed.
        await _otpCooldown.markSent(pending.phone);
      case ApiFailure(:final failure):
        emit(state.copyWith(errorMessage: failure.message));
    }
  }

  Future<void> _onSocialSignInRequested(
    AuthSocialSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    final result = await _socialSignIn(event.type);
    if (result == null) {
      // User cancelled the native dialog — no error, just stop the spinner.
      emit(state.copyWith(isSubmitting: false));
      return;
    }
    _emitAuthResult(result, emit);
  }

  /// Shared success/failure handling for login, register & social sign-in.
  void _emitAuthResult(ApiResult<AuthSession> result, Emitter<AuthState> emit) {
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            session: data,
            isSubmitting: false,
          ),
        );
      case ApiFailure(:final failure):
        emit(
          state.copyWith(isSubmitting: false, errorMessage: failure.message),
        );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
