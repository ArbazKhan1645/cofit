import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../shared/widgets/widgets.dart';
import 'auth_controller.dart';

class SubscriptionController extends BaseController {
  final _storage = GetStorage();

  // Observables
  final RxInt selectedPlanIndex = 1.obs; // Default to annual (better value)
  final RxBool isProcessing = false.obs;
  final RxBool isPCMember = true.obs; // Default to PC Member

  // PC Member pricing
  final List<Map<String, dynamic>> pcPlans = [
    {
      'name': 'Monthly',
      'price': 14.99,
      'period': 'month',
      'isBestValue': false,
    },
    {
      'name': 'Annual',
      'price': 99.99,
      'period': 'year',
      'monthlyPrice': 8.33,
      'savings': '44%',
      'isBestValue': true,
    },
  ];

  // Non-PC Member pricing
  final List<Map<String, dynamic>> nonPcPlans = [
    {
      'name': 'Monthly',
      'price': 17.99,
      'period': 'month',
      'isBestValue': false,
    },
    {
      'name': 'Annual',
      'price': 119.99,
      'period': 'year',
      'monthlyPrice': 10.00,
      'savings': '44%',
      'isBestValue': true,
    },
  ];

  List<Map<String, dynamic>> get plans =>
      isPCMember.value ? pcPlans : nonPcPlans;

  void toggleMemberType(bool pcMember) {
    isPCMember.value = pcMember;
    selectedPlanIndex.value = 1; // Reset to annual
  }

  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  Future<void> continueToPurchase() async {
    isProcessing.value = true;

    try {
      final selectedPlan = plans[selectedPlanIndex.value];
      final planName = selectedPlan['name'] as String;
      final period = selectedPlan['period'] as String;
      final now = DateTime.now();
      final endDate = period == 'year'
          ? DateTime(now.year + 1, now.month, now.day)
          : DateTime(now.year, now.month + 1, now.day);

      // Save to Supabase users table (persists across restarts)
      // await _saveSubscriptionToSupabase(
      //   plan: planName,
      //   startDate: now,
      //   endDate: endDate,
      // );

      // Also save locally for quick checks
      _storage.write('hasSubscription', true);
      _storage.write('subscriptionPlan', planName);

      await AuthController.ensureHomeReady();
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      if (Get.context != null) {
        AppSnackbar.error(
          Get.context!,
          message: 'Failed to process subscription. Please try again.',
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> startFreeTrial() async {
    isProcessing.value = true;

    try {} finally {
      isProcessing.value = false;
    }
  }

  Future<void> restorePurchases() async {
    isProcessing.value = true;

    try {
      // TODO: Implement restore purchases
      await Future.delayed(const Duration(seconds: 2));

      if (Get.context != null) {
        AppSnackbar.success(
          Get.context!,
          message: 'Purchases restored successfully!',
        );
      }
    } catch (e) {
      if (Get.context != null) {
        AppSnackbar.error(
          Get.context!,
          message: 'No previous purchases found.',
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> skipSubscription() async {
    // Save as free-tier so user isn't redirected again on restart
    await _saveSubscriptionToSupabase(
      plan: 'Free',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    _storage.write('hasSubscription', false);
    await AuthController.ensureHomeReady();
    Get.offAllNamed(AppRoutes.main);
  }

  /// Save subscription status to Supabase users table + refresh cached user
  Future<void> _saveSubscriptionToSupabase({
    required String plan,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final userId = SupabaseService.to.userId;
    if (userId == null) return;

    await SupabaseService.to.client
        .from('users')
        .update({
          'subscription_status': 'active',
          'subscription_plan': plan,
          'subscription_start_date': startDate.toIso8601String(),
          'subscription_end_date': endDate.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);

    // Refresh cached user so hasActiveSubscription returns true immediately
    await AuthService.to.refreshUser();
  }
}
