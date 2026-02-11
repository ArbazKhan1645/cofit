import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../shared/widgets/widgets.dart';

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
      await Future.delayed(const Duration(seconds: 1));

      // Save subscription state
      _storage.write('hasSubscription', true);
      _storage.write(
        'subscriptionPlan',
        plans[selectedPlanIndex.value]['name'],
      );

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

    try {
      await Future.delayed(const Duration(seconds: 1));

      _storage.write('hasSubscription', true);
      _storage.write('subscriptionPlan', 'Trial');
      _storage.write(
        'trialEndDate',
        DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      );

      Get.offAllNamed(AppRoutes.main);
    } finally {
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

  void skipSubscription() {
    // Allow limited access without subscription
    _storage.write('hasSubscription', false);
    Get.offAllNamed(AppRoutes.main);
  }
}
