import 'base_repository.dart';
import '../models/diet_plan_model.dart';

class DietPlanRepository extends BaseRepository {
  // ============================================
  // DIET PLANS - CRUD
  // ============================================

  /// Get all diet plans (admin - all, user - published only)
  Future<Result<List<DietPlanModel>>> getAllPlans({bool adminMode = false}) async {
    try {
      var query = client.from('diet_plans').select();
      if (!adminMode) {
        query = query.eq('is_published', true);
      }
      final response = await query.order('created_at', ascending: false);
      final plans = (response as List)
          .map((json) => DietPlanModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(plans);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get a single plan with all days and meals
  Future<Result<DietPlanModel>> getPlanWithDetails(String planId) async {
    try {
      final response = await client
          .from('diet_plans')
          .select('*, diet_plan_days(*, diet_plan_meals(*))')
          .eq('id', planId)
          .single();
      return Result.success(
          DietPlanModel.fromJson(response as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get featured plans for user home
  Future<Result<List<DietPlanModel>>> getFeaturedPlans() async {
    try {
      final response = await client
          .from('diet_plans')
          .select()
          .eq('is_published', true)
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(5);
      final plans = (response as List)
          .map((json) => DietPlanModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(plans);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get plans by category
  Future<Result<List<DietPlanModel>>> getPlansByCategory(String category) async {
    try {
      final response = await client
          .from('diet_plans')
          .select()
          .eq('is_published', true)
          .eq('category', category)
          .order('created_at', ascending: false);
      final plans = (response as List)
          .map((json) => DietPlanModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(plans);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Create a new diet plan (admin)
  Future<Result<DietPlanModel>> createPlan(Map<String, dynamic> data) async {
    try {
      data['created_by'] = userId;
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();
      final response =
          await client.from('diet_plans').insert(data).select().single();
      return Result.success(
          DietPlanModel.fromJson(response as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Update a diet plan (admin)
  Future<Result<DietPlanModel>> updatePlan(
      String planId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      final response = await client
          .from('diet_plans')
          .update(data)
          .eq('id', planId)
          .select()
          .single();
      return Result.success(
          DietPlanModel.fromJson(response as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Delete a diet plan (admin)
  Future<Result<void>> deletePlan(String planId) async {
    try {
      await client.from('diet_plans').delete().eq('id', planId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // DIET PLAN DAYS
  // ============================================

  /// Get all days for a plan (with meals)
  Future<Result<List<DietPlanDayModel>>> getPlanDays(String planId) async {
    try {
      final response = await client
          .from('diet_plan_days')
          .select('*, diet_plan_meals(*)')
          .eq('plan_id', planId)
          .order('day_number', ascending: true);
      final days = (response as List)
          .map(
              (json) => DietPlanDayModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(days);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Create a day for a plan
  Future<Result<DietPlanDayModel>> createDay(Map<String, dynamic> data) async {
    try {
      final response = await client
          .from('diet_plan_days')
          .insert(data)
          .select()
          .single();
      return Result.success(
          DietPlanDayModel.fromJson(response as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Batch create days (when plan is first created)
  Future<Result<List<DietPlanDayModel>>> createDays(
      String planId, int durationDays) async {
    try {
      final daysData = List.generate(
        durationDays,
        (i) => {
          'plan_id': planId,
          'day_number': i + 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
      final response = await client
          .from('diet_plan_days')
          .insert(daysData)
          .select();
      final days = (response as List)
          .map(
              (json) => DietPlanDayModel.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
      return Result.success(days);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Update day metadata
  Future<Result<void>> updateDay(
      String dayId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      await client.from('diet_plan_days').update(data).eq('id', dayId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // MEALS
  // ============================================

  /// Get meals for a day
  Future<Result<List<DietPlanMealModel>>> getDayMeals(String dayId) async {
    try {
      final response = await client
          .from('diet_plan_meals')
          .select()
          .eq('day_id', dayId)
          .order('sort_order', ascending: true);
      final meals = (response as List)
          .map((json) =>
              DietPlanMealModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(meals);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Add a meal to a day
  Future<Result<DietPlanMealModel>> addMeal(Map<String, dynamic> data) async {
    try {
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();
      final response = await client
          .from('diet_plan_meals')
          .insert(data)
          .select()
          .single();
      return Result.success(
          DietPlanMealModel.fromJson(response as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Update a meal
  Future<Result<DietPlanMealModel>> updateMeal(
      String mealId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      final response = await client
          .from('diet_plan_meals')
          .update(data)
          .eq('id', mealId)
          .select()
          .single();
      return Result.success(
          DietPlanMealModel.fromJson(response as Map<String, dynamic>));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Delete a meal
  Future<Result<void>> deleteMeal(String mealId) async {
    try {
      await client.from('diet_plan_meals').delete().eq('id', mealId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Copy meals from one day to another (uses Supabase function)
  Future<Result<void>> copyDayMeals(
      String sourceDayId, String targetDayId) async {
    try {
      await client.rpc('copy_diet_plan_day_meals', params: {
        'source_day_id': sourceDayId,
        'target_day_id': targetDayId,
      });
      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Update day totals after meal changes
  Future<Result<void>> recalculateDayTotals(String dayId) async {
    try {
      final mealsResult = await getDayMeals(dayId);
      if (!mealsResult.isSuccess) return Result.success(null);

      final meals = mealsResult.data!;
      final totals = {
        'total_calories': meals.fold(0, (sum, m) => sum + m.calories),
        'total_protein_g': meals.fold(0.0, (sum, m) => sum + m.proteinG),
        'total_carbs_g': meals.fold(0.0, (sum, m) => sum + m.carbsG),
        'total_fat_g': meals.fold(0.0, (sum, m) => sum + m.fatG),
        'updated_at': DateTime.now().toIso8601String(),
      };
      await client.from('diet_plan_days').update(totals).eq('id', dayId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }
}
