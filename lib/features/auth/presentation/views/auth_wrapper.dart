import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../cubit/auth_cubit.dart';
import 'login_view.dart';
import 'sign_up_view.dart';
import 'forgot_password_view.dart';

/// Auth routing wrapper - wraps all auth views with the AuthCubit provider
/// Simplified version without nested Navigator to avoid routing conflicts
class AuthWrapper extends StatelessWidget {
  final String initialRoute;

  const AuthWrapper({
    super.key,
    this.initialRoute = AppRoutes.login,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>(),
      child: Builder(
        builder: (context) {
          if (initialRoute == AppRoutes.signUp) {
            return const SignUpView();
          } else if (initialRoute == AppRoutes.forgotPassword) {
            return const ForgotPasswordView();
          } else {
            return const LoginView();
          }
        },
      ),
    );
  }
}
