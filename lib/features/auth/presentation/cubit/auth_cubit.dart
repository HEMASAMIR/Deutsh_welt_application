import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/auth_repo.dart';
import 'auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthCubit({required AuthRepo authRepo})
      : _authRepo = authRepo,
        super(const AuthInitial());

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _rememberMe = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get rememberMe => _rememberMe;

  // ─── Toggle Password Visibility ──────────────────────────────────────────
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    emit(PasswordVisibilityChanged(_isPasswordVisible));
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    emit(PasswordVisibilityChanged(_isConfirmPasswordVisible));
  }

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    emit(PasswordVisibilityChanged(_rememberMe));
  }

  // ─── Login ───────────────────────────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepo.login(
      email: email.trim(),
      password: password,
      rememberMe: rememberMe,
    );

    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (authResponse) => emit(LoginSuccess(authResponse)),
    );
  }

  // ─── Logout ──────────────────────────────────────────────────────────────
  Future<void> logout({required String refresh}) async {
    emit(const AuthLoading());

    final result = await _authRepo.logout(refresh: refresh);

    result.fold(
      (failure) => emit(LogoutFailure(failure.message)),
      (_) => emit(const LogoutSuccess()),
    );
  }

  // ─── Register ────────────────────────────────────────────────────────────
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepo.register(
      name: name.trim(),
      email: email.trim(),
      password: password,
      phone: phone.trim(),
    );

    result.fold(
      (failure) => emit(RegisterFailure(failure.message)),
      (user) => emit(RegisterSuccess(user)),
    );
  }

  // ─── Forgot Password ─────────────────────────────────────────────────────
  Future<void> forgotPassword({required String email}) async {
    emit(const AuthLoading());

    final result = await _authRepo.forgotPassword(email: email.trim());

    result.fold(
      (failure) => emit(ForgotPasswordFailure(failure.message)),
      (_) => emit(ForgotPasswordSuccess(email.trim())),
    );
  }

  // ─── Reset Password ────────────────────────────────────────────────────────
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepo.resetPassword(
      email: email.trim(),
      code: code.trim(),
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(ResetPasswordFailure(failure.message)),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }

  // ─── Change Password ───────────────────────────────────────────────────────
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepo.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => emit(ChangePasswordFailure(failure.message)),
      (_) => emit(const ChangePasswordSuccess()),
    );
  }

  // ─── Google Sign In ────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    try {
      emit(const AuthLoading());

      // 1. Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        emit(const AuthInitial());
        return;
      }

      // 2. Obtain authentication details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Send the ID Token to the backend
      if (googleAuth.idToken != null) {
        final result = await _authRepo.googleAuth(token: googleAuth.idToken!);

        result.fold(
          (failure) => emit(LoginFailure(failure.message)),
          (authResponse) => emit(LoginSuccess(authResponse)),
        );
      } else {
        emit(const LoginFailure('فشل الحصول على رمز تعريف جوجل (ID Token)'));
      }
    } catch (e) {
      emit(LoginFailure('حدث خطأ أثناء تسجيل الدخول بجوجل: $e'));
    }
  }

  // ─── Google Auth (Backend Only) ───────────────────────────────────────────
  Future<void> googleAuth({required String token}) async {
    emit(const AuthLoading());

    final result = await _authRepo.googleAuth(token: token);

    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (authResponse) => emit(LoginSuccess(authResponse)),
    );
  }

  // ─── Update Profile ────────────────────────────────────────────────────────
  Future<void> updateProfile({
    String? name,
    String? phone,
  }) async {
    emit(const AuthLoading());

    final result = await _authRepo.updateProfile(
      name: name?.trim(),
      phone: phone?.trim(),
    );

    result.fold(
      (failure) => emit(UpdateProfileFailure(failure.message)),
      (user) => emit(UpdateProfileSuccess(user)),
    );
  }

  // ─── Reset State ─────────────────────────────────────────────────────────
  void resetState() {
    _isPasswordVisible = false;
    _isConfirmPasswordVisible = false;
    emit(const AuthInitial());
  }
}
