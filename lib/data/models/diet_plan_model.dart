// Diet Plan Module Models
// Supabase Tables: diet_plans, diet_plan_days, diet_plan_meals

// ============================================
// INGREDIENT MODEL
// ============================================

class IngredientModel {
  final String name;
  final String? quantity;
  final String? unit;

  IngredientModel({required this.name, this.quantity, this.unit});

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as String?,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
      };

  String get display {
    final parts = <String>[];
    if (quantity != null && quantity!.isNotEmpty) parts.add(quantity!);
    if (unit != null && unit!.isNotEmpty) parts.add(unit!);
    parts.add(name);
    return parts.join(' ');
  }
}

// ============================================
// MEAL MODEL
// ============================================

class DietPlanMealModel {
  final String id;
  final String dayId;
  final String mealType;
  final String title;
  final String? description;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final String? imageUrl;
  final String? recipeInstructions;
  final int? prepTimeMinutes;
  final List<IngredientModel> ingredients;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  DietPlanMealModel({
    required this.id,
    required this.dayId,
    required this.mealType,
    required this.title,
    this.description,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.fiberG = 0,
    this.imageUrl,
    this.recipeInstructions,
    this.prepTimeMinutes,
    this.ingredients = const [],
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DietPlanMealModel.fromJson(Map<String, dynamic> json) {
    return DietPlanMealModel(
      id: json['id'] as String,
      dayId: json['day_id'] as String,
      mealType: json['meal_type'] as String? ?? 'breakfast',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      calories: json['calories'] as int? ?? 0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0,
      fiberG: (json['fiber_g'] as num?)?.toDouble() ?? 0,
      imageUrl: json['image_url'] as String?,
      recipeInstructions: json['recipe_instructions'] as String?,
      prepTimeMinutes: json['prep_time_minutes'] as int?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) =>
                  IngredientModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'day_id': dayId,
        'meal_type': mealType,
        'title': title,
        'description': description,
        'calories': calories,
        'protein_g': proteinG,
        'carbs_g': carbsG,
        'fat_g': fatG,
        'fiber_g': fiberG,
        'image_url': imageUrl,
        'recipe_instructions': recipeInstructions,
        'prep_time_minutes': prepTimeMinutes,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'sort_order': sortOrder,
      };

  /// Full serialization for local cache (includes id, timestamps)
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        ...toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  DietPlanMealModel copyWith({
    String? id,
    String? dayId,
    String? mealType,
    String? title,
    String? description,
    int? calories,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? fiberG,
    String? imageUrl,
    String? recipeInstructions,
    int? prepTimeMinutes,
    List<IngredientModel>? ingredients,
    int? sortOrder,
  }) {
    return DietPlanMealModel(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      mealType: mealType ?? this.mealType,
      title: title ?? this.title,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      proteinG: proteinG ?? this.proteinG,
      carbsG: carbsG ?? this.carbsG,
      fatG: fatG ?? this.fatG,
      fiberG: fiberG ?? this.fiberG,
      imageUrl: imageUrl ?? this.imageUrl,
      recipeInstructions: recipeInstructions ?? this.recipeInstructions,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      ingredients: ingredients ?? this.ingredients,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':
        return 'Breakfast';
      case 'morning_snack':
        return 'Morning Snack';
      case 'lunch':
        return 'Lunch';
      case 'afternoon_snack':
        return 'Afternoon Snack';
      case 'dinner':
        return 'Dinner';
      case 'evening_snack':
        return 'Evening Snack';
      default:
        return mealType;
    }
  }

  String get mealTypeEmoji {
    switch (mealType) {
      case 'breakfast':
        return '🌅';
      case 'morning_snack':
        return '🍎';
      case 'lunch':
        return '☀️';
      case 'afternoon_snack':
        return '🥜';
      case 'dinner':
        return '🌙';
      case 'evening_snack':
        return '🫖';
      default:
        return '🍽️';
    }
  }

  bool get hasMacros => proteinG > 0 || carbsG > 0 || fatG > 0;
}

// ============================================
// DAY MODEL
// ============================================

class DietPlanDayModel {
  final String id;
  final String planId;
  final int dayNumber;
  final String? title;
  final String? notes;
  final int totalCalories;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Nested meals
  final List<DietPlanMealModel> meals;

  DietPlanDayModel({
    required this.id,
    required this.planId,
    required this.dayNumber,
    this.title,
    this.notes,
    this.totalCalories = 0,
    this.totalProteinG = 0,
    this.totalCarbsG = 0,
    this.totalFatG = 0,
    required this.createdAt,
    required this.updatedAt,
    this.meals = const [],
  });

  factory DietPlanDayModel.fromJson(Map<String, dynamic> json) {
    List<DietPlanMealModel> meals = [];
    if (json['diet_plan_meals'] != null) {
      meals = (json['diet_plan_meals'] as List<dynamic>)
          .map((e) => DietPlanMealModel.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return DietPlanDayModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      dayNumber: json['day_number'] as int,
      title: json['title'] as String?,
      notes: json['notes'] as String?,
      totalCalories: json['total_calories'] as int? ?? 0,
      totalProteinG: (json['total_protein_g'] as num?)?.toDouble() ?? 0,
      totalCarbsG: (json['total_carbs_g'] as num?)?.toDouble() ?? 0,
      totalFatG: (json['total_fat_g'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      meals: meals,
    );
  }

  Map<String, dynamic> toJson() => {
        'plan_id': planId,
        'day_number': dayNumber,
        'title': title,
        'notes': notes,
        'total_calories': totalCalories,
        'total_protein_g': totalProteinG,
        'total_carbs_g': totalCarbsG,
        'total_fat_g': totalFatG,
      };

  /// Full serialization for local cache (includes id, timestamps, meals)
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        ...toJson(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'diet_plan_meals': meals.map((m) => m.toCacheJson()).toList(),
      };

  DietPlanDayModel copyWith({
    String? id,
    String? planId,
    int? dayNumber,
    String? title,
    String? notes,
    int? totalCalories,
    double? totalProteinG,
    double? totalCarbsG,
    double? totalFatG,
    List<DietPlanMealModel>? meals,
  }) {
    return DietPlanDayModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProteinG: totalProteinG ?? this.totalProteinG,
      totalCarbsG: totalCarbsG ?? this.totalCarbsG,
      totalFatG: totalFatG ?? this.totalFatG,
      createdAt: createdAt,
      updatedAt: updatedAt,
      meals: meals ?? this.meals,
    );
  }

  String get dayLabel => title ?? 'Day $dayNumber';
  int get mealCount => meals.length;
  int get computedCalories =>
      meals.fold(0, (sum, m) => sum + m.calories);
  bool get hasMeals => meals.isNotEmpty;

  List<DietPlanMealModel> getMealsByType(String type) =>
      meals.where((m) => m.mealType == type).toList();
}

// ============================================
// DIET PLAN MODEL
// ============================================

class DietPlanModel {
  final String id;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final String planType;
  final int durationDays;
  final String category;
  final String difficultyLevel;
  final int? caloriesPerDay;
  final List<String> tags;
  final bool isPublished;
  final bool isFeatured;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Nested days (loaded with detail)
  final List<DietPlanDayModel> days;

  DietPlanModel({
    required this.id,
    required this.title,
    this.description,
    this.coverImageUrl,
    this.planType = 'custom',
    this.durationDays = 7,
    this.category = 'general',
    this.difficultyLevel = 'beginner',
    this.caloriesPerDay,
    this.tags = const [],
    this.isPublished = false,
    this.isFeatured = false,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.days = const [],
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json) {
    List<DietPlanDayModel> days = [];
    if (json['diet_plan_days'] != null) {
      days = (json['diet_plan_days'] as List<dynamic>)
          .map((e) => DietPlanDayModel.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    }

    return DietPlanModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      planType: json['plan_type'] as String? ?? 'custom',
      durationDays: json['duration_days'] as int? ?? 7,
      category: json['category'] as String? ?? 'general',
      difficultyLevel: json['difficulty_level'] as String? ?? 'beginner',
      caloriesPerDay: json['calories_per_day'] as int?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPublished: json['is_published'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      days: days,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'cover_image_url': coverImageUrl,
        'plan_type': planType,
        'duration_days': durationDays,
        'category': category,
        'difficulty_level': difficultyLevel,
        'calories_per_day': caloriesPerDay,
        'tags': tags,
        'is_published': isPublished,
        'is_featured': isFeatured,
        'updated_at': DateTime.now().toIso8601String(),
      };

  /// Full serialization for local cache (includes id, timestamps, days)
  Map<String, dynamic> toCacheJson() => {
        'id': id,
        ...toJson(),
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'diet_plan_days': days.map((d) => d.toCacheJson()).toList(),
      };

  DietPlanModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImageUrl,
    String? planType,
    int? durationDays,
    String? category,
    String? difficultyLevel,
    int? caloriesPerDay,
    List<String>? tags,
    bool? isPublished,
    bool? isFeatured,
    List<DietPlanDayModel>? days,
  }) {
    return DietPlanModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      planType: planType ?? this.planType,
      durationDays: durationDays ?? this.durationDays,
      category: category ?? this.category,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      caloriesPerDay: caloriesPerDay ?? this.caloriesPerDay,
      tags: tags ?? this.tags,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      days: days ?? this.days,
    );
  }

  // Computed
  String get planTypeLabel {
    switch (planType) {
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return '$durationDays Days';
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'weight_loss':
        return 'Weight Loss';
      case 'muscle_gain':
        return 'Muscle Gain';
      case 'maintenance':
        return 'Maintenance';
      case 'keto':
        return 'Keto';
      case 'vegan':
        return 'Vegan';
      case 'high_protein':
        return 'High Protein';
      default:
        return 'General';
    }
  }

  String get difficultyLabel {
    switch (difficultyLevel) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return difficultyLevel;
    }
  }

  int get configuredDaysCount => days.where((d) => d.hasMeals).length;
  bool get isFullyConfigured => configuredDaysCount == durationDays;
  int get avgCaloriesPerDay {
    if (days.isEmpty) return caloriesPerDay ?? 0;
    final total = days.fold(0, (sum, d) => sum + d.computedCalories);
    return days.isNotEmpty ? (total / days.length).round() : 0;
  }
}

// ============================================
// MEAL TYPES CONSTANT
// ============================================

const List<String> kMealTypes = [
  'breakfast',
  'morning_snack',
  'lunch',
  'afternoon_snack',
  'dinner',
  'evening_snack',
];

const Map<String, String> kMealTypeLabels = {
  'breakfast': 'Breakfast',
  'morning_snack': 'Morning Snack',
  'lunch': 'Lunch',
  'afternoon_snack': 'Afternoon Snack',
  'dinner': 'Dinner',
  'evening_snack': 'Evening Snack',
};

const List<String> kPlanCategories = [
  'general',
  'weight_loss',
  'muscle_gain',
  'maintenance',
  'keto',
  'vegan',
  'high_protein',
];

const Map<String, String> kCategoryLabels = {
  'general': 'General',
  'weight_loss': 'Weight Loss',
  'muscle_gain': 'Muscle Gain',
  'maintenance': 'Maintenance',
  'keto': 'Keto',
  'vegan': 'Vegan',
  'high_protein': 'High Protein',
};
