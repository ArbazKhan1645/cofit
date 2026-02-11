import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/widgets.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  // Observables
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool agreeToTerms = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // ============================================
  // SIGN IN
  // ============================================

  Future<void> signIn() async {
    // Validate input
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (passwordController.text.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showError('Please enter a valid email');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final result = await _authService.signIn(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    isLoading.value = false;

    if (result.isSuccess) {
      _navigateAfterAuth();
    } else {
      _showError(result.errorMessage ?? 'Sign in failed');
    }
  }

  // ============================================
  // SIGN UP
  // ============================================

  Future<void> signUp() async {
    // Validate input
    if (nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }

    if (emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showError('Please enter a valid email');
      return;
    }

    if (passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return;
    }

    if (passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (!agreeToTerms.value) {
      _showError('Please agree to the terms and conditions');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final result = await _authService.signUp(
      email: emailController.text.trim(),
      password: passwordController.text,
      fullName: nameController.text.trim(),
    );

    isLoading.value = false;

    if (result.isSuccess) {
      _navigateAfterAuth();
    } else {
      _showError(result.errorMessage ?? 'Sign up failed');
    }
  }

  // ============================================
  // SOCIAL AUTH
  // ============================================

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _authService.signInWithGoogle();

    isLoading.value = false;

    if (result.isSuccess) {
      // Wait a moment for user data to be fetched
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateAfterAuth();
    } else if (result.errorMessage != null &&
        !result.errorMessage!.toLowerCase().contains('cancelled')) {
      _showError(result.errorMessage!);
    }
  }

  Future<void> signInWithApple() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _authService.signInWithApple();

    isLoading.value = false;

    if (result.isSuccess) {
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateAfterAuth();
    } else if (result.errorMessage != null &&
        !result.errorMessage!.toLowerCase().contains('cancelled')) {
      _showError(result.errorMessage!);
    }
  }

  // ============================================
  // PASSWORD RESET
  // ============================================

  Future<void> resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showError('Please enter a valid email');
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final result = await _authService.resetPassword(emailController.text.trim());

    isLoading.value = false;

    if (result.isSuccess) {
      if (Get.context != null) {
        AppSnackbar.success(
          Get.context!,
          message: 'Check your inbox for password reset instructions',
          title: 'Email Sent',
          duration: const Duration(seconds: 4),
        );
      }
      Get.back();
    } else {
      _showError(result.errorMessage ?? 'Failed to send reset email');
    }
  }

  // ============================================
  // NAVIGATION
  // ============================================

  /// Navigate after successful authentication
  /// Flow: Auth → Journal Prompts → Prompt Result → Subscription → Main
  void _navigateAfterAuth() {
    // Clear form fields
    _clearFields();

    // Check if onboarding is completed
    if (!_authService.hasCompletedOnboarding) {
      // Go to journal prompts
      Get.offAllNamed(AppRoutes.journalPrompts);
      return;
    }

    // Onboarding complete - check subscription
    if (!_authService.hasActiveSubscription) {
      Get.offAllNamed(AppRoutes.subscription);
      return;
    }

    // Everything complete - go to main app
    Get.offAllNamed(AppRoutes.main);
  }

  void goToSignUp() {
    _clearFields();
    Get.toNamed(AppRoutes.signUp);
  }

  void goToSignIn() {
    _clearFields();
    Get.back();
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  // ============================================
  // HELPERS
  // ============================================

  void _showError(String message) {
    errorMessage.value = message;
    if (Get.context != null) {
      AppSnackbar.error(
        Get.context!,
        message: message,
      );
    }
  }

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    errorMessage.value = null;
    obscurePassword.value = true;
    obscureConfirmPassword.value = true;
    agreeToTerms.value = false;
  }

  void clearError() {
    errorMessage.value = null;
    _authService.clearError();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}
