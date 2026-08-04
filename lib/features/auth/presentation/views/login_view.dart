import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_logo_widget.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_login_buttons.dart';
import '../../../../core/widgets/custom_snack_bar.dart';

import '../widgets/auth_success_overlay.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!_rememberMe) {
      CustomSnackBar.show(
        context,
        message: 'برجاء تفعيل خيار "تذكرني" للمتابعة وتأكيد حفظ بيانات الدخول ⚠️',
        type: SnackBarType.warning,
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
            email: _emailController.text,
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              final isAdmin = state.authResponse.user.isStaff;
              showAuthSuccessOverlay(
                context: context,
                firstName: state.authResponse.user.firstName,
                isRegister: false,
              ).then((_) {
                if (context.mounted) {
                  Navigator.pushReplacementNamed(
                    context,
                    isAdmin ? AppRoutes.adminDashboard : AppRoutes.home,
                  );
                }
              });
            } else if (state is LoginFailure) {
              CustomSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.error,
              );
            }
          },
          child: AuthBackgroundWidget(
            child: SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
    
                          // Logo
                          FadeInDown(
                            duration: const Duration(milliseconds: 800),
                            child: const AuthLogoWidget(size: 100),
                          ),
    
                          const SizedBox(height: 40),
    
                          // Welcome card
                          FadeInUp(
                            duration: const Duration(milliseconds: 700),
                            delay: const Duration(milliseconds: 200),
                            child: _buildLoginCard(context),
                          ),
    
                          const SizedBox(height: 30),
    
                          // Sign up link
                          FadeInUp(
                            duration: const Duration(milliseconds: 700),
                            delay: const Duration(milliseconds: 400),
                            child: _buildSignUpRow(context),
                          ),
    
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            AppStrings.loginWelcome,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.loginSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: subtitleColor,
                ),
          ),

          const SizedBox(height: 28),

          // Email field
          CustomTextField(
            label: AppStrings.email,
            hint: AppStrings.emailHint,
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.requiredField;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return AppStrings.invalidEmail;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Password field
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return CustomTextField(
                label: AppStrings.password,
                hint: AppStrings.passwordHint,
                controller: _passwordController,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.done,
                onEditingComplete: _onLogin,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  if (value.length < 8) {
                    return AppStrings.passwordTooShort;
                  }
                  return null;
                },
              );
            },
          ),

          const SizedBox(height: 16),

          // Remember me & Forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (val) =>
                            setState(() => _rememberMe = val ?? false),
                        activeColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(
                            color: AppColors.border, width: 1.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.rememberMe,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.forgotPassword);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.forgotPassword,
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.accentGold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Login button
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return PrimaryButton(
                text: AppStrings.login,
                onPressed: _onLogin,
                isLoading: state is AuthLoading,
                icon: Icons.login_rounded,
              );
            },
          ),

          const SizedBox(height: 24),

          // ─── Social Login Divider ───────────────────────────────────
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.divider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'أو تابع بـ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.divider)),
            ],
          ),

          const SizedBox(height: 20),

          // ─── Social Login Buttons (Google + Apple) ──────────────────
          const SocialLoginButtons(),

        ],
      ),
    );
  }

  Widget _buildSignUpRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.signUp);
          },
          child: ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: Text(
              AppStrings.createAccount,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryBlue,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
