import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_logo_widget.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../core/router/app_routes.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _emailSent = false;
  String _sentToEmail = '';
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToConfirm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSendResetLink() {
    if (!_agreeToConfirm) {
      CustomSnackBar.show(
        context,
        message: 'برجاء تفعيل خيار التأكيد وتذكر بيانات الحساب للمتابعة ⚠️',
        type: SnackBarType.warning,
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().forgotPassword(
            email: _emailController.text,
          );
    }
  }

  void _onResetPassword() {
    if (_resetFormKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(
            email: _sentToEmail,
            code: _otpController.text.trim(),
            newPassword: _newPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is ForgotPasswordSuccess) {
              setState(() {
                _emailSent = true;
                _sentToEmail = state.email;
              });
              CustomSnackBar.show(
                context,
                message: 'تم إرسال رمز التحقق إلى بريدك الإلكتروني بنجاح! 📧',
                type: SnackBarType.success,
              );
            } else if (state is ForgotPasswordFailure) {
              CustomSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.error,
              );
            } else if (state is ResetPasswordSuccess) {
              CustomSnackBar.show(
                context,
                message: 'تم إعادة تعيين كلمة المرور بنجاح! 🎉 سجل دخولك الآن.',
                type: SnackBarType.success,
              );
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            } else if (state is ResetPasswordFailure) {
              CustomSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.error,
              );
            }
          },
          child: AuthBackgroundWidget(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _emailSent
                    ? _buildSuccessView(context)
                    : _buildFormView(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Logo
          FadeInDown(
            duration: const Duration(milliseconds: 700),
            child: const AuthLogoWidget(size: 85),
          ),

          const SizedBox(height: 40),

          // Card
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black.withValues(alpha: 0.05), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.05) : AppColors.backgroundSurface,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : AppColors.border, width: 1),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Lock icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    AppStrings.forgotPasswordWelcome,
                    style:
                        Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.forgotPasswordSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
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
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _onSendResetLink,
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

                  const SizedBox(height: 16),

                  // Remember / Confirm Checkbox
                  GestureDetector(
                    onTap: () => setState(() => _agreeToConfirm = !_agreeToConfirm),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _agreeToConfirm,
                            onChanged: (val) =>
                                setState(() => _agreeToConfirm = val ?? false),
                            activeColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            side: const BorderSide(
                                color: AppColors.border, width: 1.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'تأكيد استعادة كلمة المرور وتذكر الحساب',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Send button
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: AppStrings.sendResetLink,
                        onPressed: _onSendResetLink,
                        isLoading: state is AuthLoading,
                        icon: Icons.send_rounded,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Back to login
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      label: Text(
                        AppStrings.backToLogin,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Form(
      key: _resetFormKey,
      child: Column(
        children: [
          const SizedBox(height: 30),

          // Success animation
          FadeInDown(
            duration: const Duration(milliseconds: 700),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

          const SizedBox(height: 20),

          FadeInUp(
            duration: const Duration(milliseconds: 700),
            delay: const Duration(milliseconds: 100),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: AppColors.glassGradient,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إعادة تعيين كلمة المرور',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أدخل رمز التحقق المرسل إلى البريد الإلكتروني:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.email_outlined,
                            color: AppColors.primaryBlueLight, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _sentToEmail,
                          style: const TextStyle(
                            color: AppColors.primaryBlueLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // OTP field
                  CustomTextField(
                    label: 'رمز التحقق (OTP)',
                    hint: 'أدخل رمز التحقق المستلم',
                    controller: _otpController,
                    prefixIcon: Icons.security_rounded,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.requiredField;
                      }
                      if (value.trim().length < 4) {
                        return 'الرمز غير صحيح';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // New Password field
                  CustomTextField(
                    label: 'كلمة المرور الجديدة',
                    hint: 'أدخل كلمة المرور الجديدة',
                    controller: _newPasswordController,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !_isNewPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => setState(() =>
                          _isNewPasswordVisible = !_isNewPasswordVisible),
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
                  ),

                  const SizedBox(height: 18),

                  // Confirm Password field
                  CustomTextField(
                    label: 'تأكيد كلمة المرور الجديدة',
                    hint: 'أعد إدخال كلمة المرور الجديدة',
                    controller: _confirmPasswordController,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: !_isConfirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _onResetPassword,
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
                      if (value == null || value.isEmpty) {
                        return AppStrings.requiredField;
                      }
                      if (value != _newPasswordController.text) {
                        return AppStrings.passwordsNotMatch;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Reset button
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: 'تغيير كلمة المرور',
                        onPressed: _onResetPassword,
                        isLoading: state is AuthLoading,
                        icon: Icons.check_circle_outline_rounded,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Edit email link
                  Center(
                    child: TextButton.icon(
                      onPressed: () => setState(() {
                        _emailSent = false;
                        _otpController.clear();
                        _newPasswordController.clear();
                        _confirmPasswordController.clear();
                      }),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AppColors.accentGold,
                      ),
                      label: const Text(
                        'تعديل البريد الإلكتروني',
                        style: TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
