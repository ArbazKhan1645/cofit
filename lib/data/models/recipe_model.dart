import 'community_model.dart';

/// Recipe Model - Healthy recipes shared in the community
/// Supabase Table: recipes
class RecipeModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String> imageUrls;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty; // easy, medium, hard
  final String mealType; // breakfast, lunch, dinner, snack, dessert
  final List<String> dietaryTags; // vegan, vegetarian, gluten-free, keto, etc.
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> instructions;
  final NutritionInfo? nutritionInfo;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final bool isPublic;
  final bool isFeatured;
  final int likesCount;
  final int savesCount;
  final double averageRating;
  final int ratingsCount;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final UserSummary? author;
  final bool isLikedByMe;
  final bool isSavedByMe;

  RecipeModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageUrls = const [],
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.mealType,
    this.dietaryTags = const [],
    this.ingredients = const [],
    this.instructions = const [],
    this.nutritionInfo,
    this.calories = 0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.isPublic = true,
    this.isFeatured = false,
    this.likesCount = 0,
    this.savesCount = 0,
    this.averageRating = 0.0,
    this.ratingsCount = 0,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.isLikedByMe = false,
    this.isSavedByMe = false,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      prepTimeMinutes: json['prep_time_minutes'] as int,
      cookTimeMinutes: json['cook_time_minutes'] as int,
      servings: json['servings'] as int,
      difficulty: json['difficulty'] as String,
      mealType: json['meal_type'] as String,
      dietaryTags: (json['dietary_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => RecipeStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nutritionInfo: json['nutrition_info'] != null
          ? NutritionInfo.fromJson(json['nutrition_info'] as Map<String, dynamic>)
          : null,
      calories: json['calories'] as int? ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      isPublic: json['is_public'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      savesCount: json['saves_count'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: json['ratings_count'] as int? ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['users'] != null
          ? UserSummary.fromJson(json['users'] as Map<String, dynamic>)
          : null,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      isSavedByMe: json['is_saved_by_me'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'meal_type': mealType,
      'dietary_tags': dietaryTags,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions.map((e) => e.toJson()).toList(),
      'nutrition_info': nutritionInfo?.toJson(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'is_public': isPublic,
      'is_featured': isFeatured,
      'likes_count': likesCount,
      'saves_count': savesCount,
      'average_rating': averageRating,
      'ratings_count': ratingsCount,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty,
      'meal_type': mealType,
      'dietary_tags': dietaryTags,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'instructions': instructions.map((e) => e.toJson()).toList(),
      'nutrition_info': nutritionInfo?.toJson(),
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'is_public': isPublic,
      'tags': tags,
    };
  }

  RecipeModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    String? difficulty,
    String? mealType,
    List<String>? dietaryTags,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? instructions,
    NutritionInfo? nutritionInfo,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    bool? isPublic,
    bool? isFeatured,
    int? likesCount,
    int? savesCount,
    double? averageRating,
    int? ratingsCount,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserSummary? author,
    bool? isLikedByMe,
    bool? isSavedByMe,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      mealType: mealType ?? this.mealType,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      isPublic: isPublic ?? this.isPublic,
      isFeatured: isFeatured ?? this.isFeatured,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isSavedByMe: isSavedByMe ?? this.isSavedByMe,
    );
  }

  /// Get total time (prep + cook)
  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  /// Get formatted total time
  String get formattedTotalTime {
    final total = totalTimeMinutes;
    if (total >= 60) {
      final hours = total ~/ 60;
      final mins = total % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '$total min';
  }

  /// Get main image
  String? get mainImage => imageUrl ?? (imageUrls.isNotEmpty ? imageUrls.first : null);

  /// Get author name
  String get authorName => author?.displayName ?? 'Unknown';

  /// Get author avatar
  String? get authorAvatar => author?.avatarUrl;
}

/// Recipe Ingredient - Individual ingredient in a recipe
class RecipeIngredient {
  final String name;
  final double quantity;
  final String unit;
  final String? notes; // e.g., "diced", "room temperature"
  final bool isOptional;

  RecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.notes,
    this.isOptional = false,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      notes: json['notes'] as String?,
      isOptional: json['is_optional'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'is_optional': isOptional,
    };
  }

  /// Get formatted display string
  String get displayText {
    final qtyStr = quantity == quantity.roundToDouble()
        ? quantity.round().toString()
        : quantity.toString();
    final noteStr = notes != null ? ' ($notes)' : '';
    final optionalStr = isOptional ? ' (optional)' : '';
    return '$qtyStr $unit $name$noteStr$optionalStr';
  }
}

/// Recipe Step - Instruction step in a recipe
class RecipeStep {
  final int stepNumber;
  final String instruction;
  final String? imageUrl;
  final int? timerMinutes;
  final String? tip;

  RecipeStep({
    required this.stepNumber,
    required this.instruction,
    this.imageUrl,
    this.timerMinutes,
    this.tip,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepNumber: json['step_number'] as int,
      instruction: json['instruction'] as String,
      imageUrl: json['image_url'] as String?,
      timerMinutes: json['timer_minutes'] as int?,
      tip: json['tip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step_number': stepNumber,
      'instruction': instruction,
      'image_url': imageUrl,
      'timer_minutes': timerMinutes,
      'tip': tip,
    };
  }
}

/// Nutrition Info - Detailed nutrition information
class NutritionInfo {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final double cholesterol;
  final double saturatedFat;
  final double transFat;
  final double potassium;
  final double vitaminA;
  final double vitaminC;
  final double calcium;
  final double iron;

  NutritionInfo({
    this.calories = 0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fat = 0.0,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.cholesterol = 0.0,
    this.saturatedFat = 0.0,
    this.transFat = 0.0,
    this.potassium = 0.0,
    this.vitaminA = 0.0,
    this.vitaminC = 0.0,
    this.calcium = 0.0,
    this.iron = 0.0,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: json['calories'] as int? ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
      cholesterol: (json['cholesterol'] as num?)?.toDouble() ?? 0.0,
      saturatedFat: (json['saturated_fat'] as num?)?.toDouble() ?? 0.0,
      transFat: (json['trans_fat'] as num?)?.toDouble() ?? 0.0,
      potassium: (json['potassium'] as num?)?.toDouble() ?? 0.0,
      vitaminA: (json['vitamin_a'] as num?)?.toDouble() ?? 0.0,
      vitaminC: (json['vitamin_c'] as num?)?.toDouble() ?? 0.0,
      calcium: (json['calcium'] as num?)?.toDouble() ?? 0.0,
      iron: (json['iron'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'cholesterol': cholesterol,
      'saturated_fat': saturatedFat,
      'trans_fat': transFat,
      'potassium': potassium,
      'vitamin_a': vitaminA,
      'vitamin_c': vitaminC,
      'calcium': calcium,
      'iron': iron,
    };
  }
}

/// Saved Recipe Model - User's saved recipes
/// Supabase Table: saved_recipes
class SavedRecipeModel {
  final String id;
  final String userId;
  final String recipeId;
  final DateTime savedAt;
  final String? collectionName; // For organizing saved recipes
  final String? note;
  final DateTime createdAt;

  // Joined data
  final RecipeModel? recipe;

  SavedRecipeModel({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.savedAt,
    this.collectionName,
    this.note,
    required this.createdAt,
    this.recipe,
  });

  factory SavedRecipeModel.fromJson(Map<String, dynamic> json) {
    return SavedRecipeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recipeId: json['recipe_id'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
      collectionName: json['collection_name'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      recipe: json['recipes'] != null
          ? RecipeModel.fromJson(json['recipes'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'saved_at': savedAt.toIso8601String(),
      'collection_name': collectionName,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'recipe_id': recipeId,
      'saved_at': savedAt.toIso8601String(),
      'collection_name': collectionName,
      'note': note,
    };
  }
}

/// Recipe Rating Model - User ratings for recipes
/// Supabase Table: recipe_ratings
class RecipeRatingModel {
  final String id;
  final String userId;
  final String recipeId;
  final int rating; // 1-5
  final String? review;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final UserSummary? author;

  RecipeRatingModel({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.rating,
    this.review,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory RecipeRatingModel.fromJson(Map<String, dynamic> json) {
    return RecipeRatingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      recipeId: json['recipe_id'] as String,
      rating: json['rating'] as int,
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['users'] != null
          ? UserSummary.fromJson(json['users'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipe_id': recipeId,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'recipe_id': recipeId,
      'rating': rating,
      'review': review,
    };
  }
}
