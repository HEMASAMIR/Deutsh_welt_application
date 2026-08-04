import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// ─── Initial ───────────────────────────────────────────────────────────────
class AuthInitial extends AuthState {
  const AuthInitial();
}

// ─── Loading ───────────────────────────────────────────────────────────────
class AuthLoading extends AuthState {
  const AuthLoading();
}

// ─── Login States ──────────────────────────────────────────────────────────
class LoginSuccess extends AuthState {
  final AuthResponseModel authResponse;
  const LoginSuccess(this.authResponse);

  @override
  List<Object?> get props => [authResponse];
}

class LoginFailure extends AuthState {
  final String message;
  const LoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Logout States ──────────────────────────────────────────────────────────
class LogoutSuccess extends AuthState {
  const LogoutSuccess();
}

class LogoutFailure extends AuthState {
  final String message;
  const LogoutFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Register States ───────────────────────────────────────────────────────
class RegisterSuccess extends AuthState {
  final UserModel user;
  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class RegisterFailure extends AuthState {
  final String message;
  const RegisterFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Forgot Password States ────────────────────────────────────────────────
class ForgotPasswordSuccess extends AuthState {
  final String email;
  const ForgotPasswordSuccess(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordFailure extends AuthState {
  final String message;
  const ForgotPasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Reset Password States ─────────────────────────────────────────────────
class ResetPasswordSuccess extends AuthState {
  const ResetPasswordSuccess();
}

class ResetPasswordFailure extends AuthState {
  final String message;
  const ResetPasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Change Password States ────────────────────────────────────────────────
class ChangePasswordSuccess extends AuthState {
  const ChangePasswordSuccess();
}

class ChangePasswordFailure extends AuthState {
  final String message;
  const ChangePasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Update Profile States ─────────────────────────────────────────────────
class UpdateProfileSuccess extends AuthState {
  final UserModel user;
  const UpdateProfileSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateProfileFailure extends AuthState {
  final String message;
  const UpdateProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Visibility States ─────────────────────────────────────────────────────
class PasswordVisibilityChanged extends AuthState {
  final bool isVisible;
  const PasswordVisibilityChanged(this.isVisible);

  @override
  List<Object?> get props => [isVisible];
}
