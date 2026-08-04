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

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_agreeToTerms) {
      CustomSnackBar.show(
        context,
        message: 'برجاء تفعيل خيار الموافقة على الشروط والأحكام وتذكر البيانات للمتابعة ⚠️',
        type: SnackBarType.warning,
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phone: _phoneController.text,
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
            if (state is RegisterSuccess) {
              showAuthSuccessOverlay(
                context: context,
                firstName: state.user.firstName,
                isRegister: true,
              ).then((_) {
                if (context.mounted) {
                  // The register endpoint returns a user, not JWT tokens. Send
                  // the user to login so the next session is authenticated.
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              });
            } else if (state is RegisterFailure) {
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
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
    
                          // Logo (smaller)
                          FadeInDown(
                            duration: const Duration(milliseconds: 700),
                            child:
                                const AuthLogoWidget(size: 70, showSubtitle: false),
                          ),
    
                          const SizedBox(height: 28),
    
                          // Card
                          FadeInUp(
                            duration: const Duration(milliseconds: 700),
                            delay: const Duration(milliseconds: 200),
                            child: _buildSignUpCard(context),
                          ),
    
                          const SizedBox(height: 24),
    
                          // Login link
                          FadeInUp(
                            duration: const Duration(milliseconds: 700),
                            delay: const Duration(milliseconds: 400),
                            child: _buildLoginRow(context),
                          ),
    
                          const SizedBox(height: 24),
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

  Widget _buildSignUpCard(BuildContext context) {
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
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: subtitleColor),
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.signUpWelcome,
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    Text(
                      AppStrings.signUpSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: subtitleColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Name field
          CustomTextField(
            label: AppStrings.fullName,
            hint: AppStrings.fullNameHint,
            controller: _nameController,
            prefixIcon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) return AppStrings.requiredField;
              if (value.trim().length < 3) return AppStrings.nameTooShort;
              return null;
            },
          ),

          const SizedBox(height: 18),

          // Email field
          CustomTextField(
            label: AppStrings.email,
            hint: AppStrings.emailHint,
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            validator: (value) {
              if (value == null || value.isEmpty) return AppStrings.requiredField;
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return AppStrings.invalidEmail;
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          // Phone field
          CustomTextField(
            label: AppStrings.phone,
            hint: AppStrings.phoneHint,
            controller: _phoneController,
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            validator: (value) {
              if (value == null || value.isEmpty) return AppStrings.requiredField;
              if (!RegExp(r'^01[0-9]{9}$').hasMatch(value)) {
                return AppStrings.invalidPhone;
              }
              return null;
            },
          ),

          const SizedBox(height: 18),

          // Password field
          CustomTextField(
            label: AppStrings.password,
            hint: AppStrings.passwordHint,
            controller: _passwordController,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textHint,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return AppStrings.requiredField;
              if (value.length < 8) return AppStrings.passwordTooShort;
              return null;
            },
          ),

          const SizedBox(height: 18),

          // Confirm Password field
          CustomTextField(
            label: AppStrings.confirmPassword,
            hint: AppStrings.confirmPasswordHint,
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: !_isConfirmPasswordVisible,
            textInputAction: TextInputAction.done,
            onEditingComplete: _onRegister,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textHint,
              ),
              onPressed: () => setState(() =>
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return AppStrings.requiredField;
              if (value != _passwordController.text) {
                return AppStrings.passwordsNotMatch;
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Terms checkbox
          GestureDetector(
            onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: (val) =>
                        setState(() => _agreeToTerms = val ?? false),
                    activeColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    side: const BorderSide(
                        color: AppColors.border, width: 1.5),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  AppStrings.agreeToTerms,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Show terms
                  },
                  child: Text(
                    AppStrings.termsAndConditions,
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
          ),

          const SizedBox(height: 28),

          // Register button
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              return PrimaryButton(
                text: AppStrings.signUp,
                onPressed: _onRegister,
                isLoading: state is AuthLoading,
                icon: Icons.person_add_rounded,
              );
            },
          ),

          const SizedBox(height: 24),

          // ─── Social Login Divider ─────────────────────────────────────
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.divider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'أو سجّل بـ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.divider)),
            ],
          ),

          const SizedBox(height: 20),

          // ─── Social Login Buttons ─────────────────────────────────────
          const SocialLoginButtons(),
        ],
      ),
    );
  }

  Widget _buildLoginRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.alreadyHaveAccount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          child: ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: Text(
              AppStrings.signIn,
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
