import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/services/media/media_service.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/challenge_model.dart';
import '../../data/repositories/challenge_repository.dart';
import '../../shared/controllers/base_controller.dart';

class ChallangeController extends BaseController {
  final SupabaseService _supabase = SupabaseService.to;
  final ChallengeRepository _repository = ChallengeRepository();

  // List state
  final RxList<ChallengeModel> challenges = <ChallengeModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString filterStatus = 'all'.obs;

  // Form state
  final formKey = GlobalKey<FormState>();
  final RxBool isSaving = false.obs;
  final Rx<ChallengeModel?> editingChallenge = Rx<ChallengeModel?>(null);
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);

  // Text controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final targetValueController = TextEditingController();
  final maxParticipantsController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  // Reactive form fields
  final RxString imageUrl = ''.obs;
  final RxString challengeType = 'workout_count'.obs;
  final RxString targetUnit = 'workouts'.obs;
  final RxString targetCategory = ''.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 30)).obs;
  final RxString status = 'upcoming'.obs;
  final RxString visibility = 'public'.obs;
  final RxBool isFeatured = false.obs;
  final RxList<String> rules = <String>[].obs;
  final RxList<ChallengePrize> prizes = <ChallengePrize>[].obs;

  // ============================================
  // DETAIL / ANALYTICS STATE
  // ============================================
  final Rx<ChallengeModel?> selectedChallenge = Rx<ChallengeModel?>(null);
  final RxList<ChallengeParticipantModel> participants =
      <ChallengeParticipantModel>[].obs;
  final RxList<ChallengeLeaderboardEntry> leaderboard =
      <ChallengeLeaderboardEntry>[].obs;
  final Rx<ChallengeStatsModel?> challengeStats = Rx<ChallengeStatsModel?>(
    null,
  );
  final RxBool isLoadingDetail = false.obs;

  final _dateFormat = DateFormat('MMM d, yyyy');

  @override
  void onInit() {
    super.onInit();
    loadChallenges();
  }

  List<ChallengeModel> get filteredChallenges {
    var list = challenges.toList();
    if (filterStatus.value == 'active') {
      list = list.where((c) => c.status == 'active').toList();
    } else if (filterStatus.value == 'upcoming') {
      list = list.where((c) => c.status == 'upcoming').toList();
    } else if (filterStatus.value == 'completed') {
      list = list.where((c) => c.status == 'completed').toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (c) =>
                c.title.toLowerCase().contains(q) ||
                c.description.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  Future<void> loadChallenges() async {
    setLoading(true);
    try {
      final response = await _supabase
          .from('challenges')
          .select()
          .order('created_at', ascending: false);
      challenges.value = (response as List)
          .map((json) => ChallengeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> refreshChallenges() async => loadChallenges();

  // ============================================
  // FORM
  // ============================================

  void initFormForCreate() {
    editingChallenge.value = null;
    selectedImageBytes.value = null;
    imageUrl.value = '';
    titleController.clear();
    descriptionController.clear();
    targetValueController.clear();
    maxParticipantsController.clear();
    challengeType.value = 'workout_count';
    targetUnit.value = 'workouts';
    targetCategory.value = '';
    startDate.value = DateTime.now();
    endDate.value = DateTime.now().add(const Duration(days: 30));
    startDateController.text = _dateFormat.format(startDate.value);
    endDateController.text = _dateFormat.format(endDate.value);
    status.value = 'upcoming';
    visibility.value = 'public';
    isFeatured.value = false;
    rules.clear();
    prizes.clear();
  }

  void initFormForEdit(ChallengeModel challenge) {
    editingChallenge.value = challenge;
    selectedImageBytes.value = null;
    imageUrl.value = challenge.imageUrl ?? '';
    titleController.text = challenge.title;
    descriptionController.text = challenge.description;
    targetValueController.text = challenge.targetValue.toString();
    maxParticipantsController.text =
        challenge.maxParticipants?.toString() ?? '';
    challengeType.value = challenge.challengeType;
    targetUnit.value = challenge.targetUnit;
    targetCategory.value = challenge.targetCategory ?? '';
    startDate.value = challenge.startDate;
    endDate.value = challenge.endDate;
    startDateController.text = _dateFormat.format(challenge.startDate);
    endDateController.text = _dateFormat.format(challenge.endDate);
    status.value = challenge.status;
    visibility.value = challenge.visibility;
    isFeatured.value = challenge.isFeatured;
    rules.value = List<String>.from(challenge.rules);
    prizes.value = List<ChallengePrize>.from(challenge.prizes);
  }

  Future<void> pickImage() async {
    final bytes = await MediaService.to.pickImageFromGallery();
    if (bytes != null) selectedImageBytes.value = bytes;
  }

  void removeImage() {
    selectedImageBytes.value = null;
    imageUrl.value = '';
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: startDate.value,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      startDate.value = picked;
      startDateController.text = _dateFormat.format(picked);
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: endDate.value,
      firstDate: startDate.value,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      endDate.value = picked;
      endDateController.text = _dateFormat.format(picked);
    }
  }

  void addRule(String rule) {
    if (rule.trim().isNotEmpty) rules.add(rule.trim());
  }

  void removeRule(int index) {
    if (index >= 0 && index < rules.length) rules.removeAt(index);
  }

  void addPrize(ChallengePrize prize) => prizes.add(prize);
  void removePrize(int index) {
    if (index >= 0 && index < prizes.length) prizes.removeAt(index);
  }

  void showAddPrizeDialog() {
    final rankC = TextEditingController();
    final titleC = TextEditingController();
    final descC = TextEditingController();
    final xpC = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Prize'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rankC,
                decoration: const InputDecoration(
                  labelText: 'Rank (0 = all completers)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descC,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: xpC,
                decoration: const InputDecoration(labelText: 'XP Reward'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleC.text.trim().isNotEmpty) {
                addPrize(
                  ChallengePrize(
                    rank: int.tryParse(rankC.text) ?? 0,
                    title: titleC.text.trim(),
                    description: descC.text.trim(),
                    xpReward: int.tryParse(xpC.text) ?? 0,
                  ),
                );
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> saveChallenge() async {
    if (!formKey.currentState!.validate()) return;
    if (endDate.value.isBefore(startDate.value)) {
      Get.snackbar(
        'Error',
        'End date must be after start date',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;
    try {
      String? newImageUrl;
      if (selectedImageBytes.value != null) {
        newImageUrl = await MediaService.to.uploadChallengeImage(
          selectedImageBytes.value!,
        );
      }

      final data = <String, dynamic>{
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'image_url':
            newImageUrl ?? (imageUrl.value.isNotEmpty ? imageUrl.value : null),
        'challenge_type': challengeType.value,
        'target_value': int.tryParse(targetValueController.text) ?? 0,
        'target_unit': targetUnit.value,
        'target_category': targetCategory.value.isNotEmpty
            ? targetCategory.value
            : null,
        'start_date': startDate.value.toIso8601String(),
        'end_date': endDate.value.toIso8601String(),
        'status': status.value,
        'visibility': visibility.value,
        'max_participants': maxParticipantsController.text.isNotEmpty
            ? int.tryParse(maxParticipantsController.text)
            : null,
        'rules': rules.toList(),
        'prizes': prizes.map((p) => p.toJson()).toList(),
        'is_featured': isFeatured.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (editingChallenge.value != null) {
        await _supabase
            .from('challenges')
            .update(data)
            .eq('id', editingChallenge.value!.id);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        await _supabase.from('challenges').insert(data);
      }

      await loadChallenges();
      Get.back();
      Get.snackbar(
        'Success',
        editingChallenge.value != null
            ? 'Challenge updated'
            : 'Challenge added',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save challenge',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isSaving.value = false;
  }

  Future<void> deleteChallenge(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Challenge'),
        content: const Text('Are you sure you want to delete this challenge?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _supabase.from('challenges').delete().eq('id', id);
      challenges.removeWhere((c) => c.id == id);
      Get.snackbar(
        'Success',
        'Challenge deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete challenge',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // DETAIL / ANALYTICS
  // ============================================

  Future<void> loadChallengeDetail(String challengeId) async {
    isLoadingDetail.value = true;
    participants.clear();
    leaderboard.clear();
    challengeStats.value = null;

    // Find in loaded challenges or fetch
    selectedChallenge.value = challenges.firstWhereOrNull(
      (c) => c.id == challengeId,
    );
    if (selectedChallenge.value == null) {
      final result = await _repository.getChallenge(challengeId);
      result.fold(
        (error) => setError(error.message),
        (data) => selectedChallenge.value = data,
      );
    }

    // Load participants, leaderboard, stats in parallel
    await Future.wait([
      _loadParticipants(challengeId),
      _loadLeaderboard(challengeId),
      _loadStats(challengeId),
    ]);

    isLoadingDetail.value = false;
  }

  Future<void> _loadParticipants(String challengeId) async {
    final result = await _repository.getParticipants(challengeId);
    result.fold((error) {}, (data) => participants.value = data);
  }

  Future<void> _loadLeaderboard(String challengeId) async {
    final result = await _repository.getLeaderboard(challengeId, limit: 100);
    result.fold((error) {}, (data) => leaderboard.value = data);
  }

  Future<void> _loadStats(String challengeId) async {
    final result = await _repository.getChallengeStats(challengeId);
    result.fold((error) {}, (data) => challengeStats.value = data);
  }

  @override
  void onClose() {
    // titleController.dispose();
    // descriptionController.dispose();
    // targetValueController.dispose();
    // maxParticipantsController.dispose();
    // startDateController.dispose();
    // endDateController.dispose();
    super.onClose();
  }
}
