import 'package:get/get.dart';

enum ViewState { initial, loading, success, error, empty }

abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ViewState> viewState = ViewState.initial.obs;

  void setLoading(bool value) {
    isLoading.value = value;
    if (value) {
      viewState.value = ViewState.loading;
    }
  }

  void setError(String message) {
    errorMessage.value = message;
    viewState.value = ViewState.error;
    isLoading.value = false;
  }

  void setSuccess() {
    viewState.value = ViewState.success;
    isLoading.value = false;
    errorMessage.value = '';
  }

  void setEmpty() {
    viewState.value = ViewState.empty;
    isLoading.value = false;
  }

  void resetState() {
    viewState.value = ViewState.initial;
    isLoading.value = false;
    errorMessage.value = '';
  }

  Future<T?> safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      setLoading(true);
      final result = await apiCall();
      setSuccess();
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    }
  }
}
