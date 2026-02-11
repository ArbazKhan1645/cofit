import '../models/models.dart';
import 'base_repository.dart';

/// Recipe Repository - Handles recipe operations
class RecipeRepository extends BaseRepository {
  // ============================================
  // RECIPES
  // ============================================

  /// Get all recipes with pagination
  Future<Result<List<RecipeModel>>> getRecipes({
    int limit = 20,
    int offset = 0,
    String? category,
    String? searchQuery,
  }) async {
    try {
      var query = client
          .from('recipes')
          .select('*, users(id, full_name, username, avatar_url)');

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final recipes = (response as List)
          .map((json) => RecipeModel.fromJson(json))
          .toList();

      // Check if user has saved each recipe
      if (userId != null) {
        final savedIds = await _getSavedRecipeIds();
        return Result.success(recipes.map((r) {
          return r.copyWith(isSavedByMe: savedIds.contains(r.id));
        }).toList());
      }

      return Result.success(recipes);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get featured recipes
  Future<Result<List<RecipeModel>>> getFeaturedRecipes() async {
    try {
      final response = await client
          .from('recipes')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(10);

      final recipes = (response as List)
          .map((json) => RecipeModel.fromJson(json))
          .toList();

      return Result.success(recipes);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get recipe by ID
  Future<Result<RecipeModel>> getRecipe(String recipeId) async {
    try {
      final response = await client
          .from('recipes')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('id', recipeId)
          .single();

      var recipe = RecipeModel.fromJson(response);

      // Check if saved by user
      if (userId != null) {
        final isSaved = await _isRecipeSaved(recipeId);
        recipe = recipe.copyWith(isSavedByMe: isSaved);
      }

      return Result.success(recipe);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get recipes by category
  Future<Result<List<RecipeModel>>> getRecipesByCategory(String category) async {
    try {
      final response = await client
          .from('recipes')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('category', category)
          .order('average_rating', ascending: false);

      final recipes = (response as List)
          .map((json) => RecipeModel.fromJson(json))
          .toList();

      return Result.success(recipes);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get recipes by meal type
  Future<Result<List<RecipeModel>>> getRecipesByMealType(String mealType) async {
    try {
      final response = await client
          .from('recipes')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('meal_type', mealType)
          .order('average_rating', ascending: false);

      final recipes = (response as List)
          .map((json) => RecipeModel.fromJson(json))
          .toList();

      return Result.success(recipes);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get recipes by user
  Future<Result<List<RecipeModel>>> getUserRecipes(String authorId) async {
    try {
      final response = await client
          .from('recipes')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('user_id', authorId)
          .order('created_at', ascending: false);

      final recipes = (response as List)
          .map((json) => RecipeModel.fromJson(json))
          .toList();

      return Result.success(recipes);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Create a new recipe
  Future<Result<RecipeModel>> createRecipe({
    required String title,
    required String description,
    required List<RecipeIngredient> ingredients,
    required List<RecipeStep> instructions,
    required int prepTimeMinutes,
    required int cookTimeMinutes,
    required int servings,
    required String difficulty,
    required String mealType,
    String? imageUrl,
    List<String>? imageUrls,
    List<String>? dietaryTags,
    NutritionInfo? nutritionInfo,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    List<String>? tags,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('recipes')
          .insert({
            'user_id': userId!,
            'title': title,
            'description': description,
            'ingredients': ingredients.map((e) => e.toJson()).toList(),
            'instructions': instructions.map((e) => e.toJson()).toList(),
            'prep_time_minutes': prepTimeMinutes,
            'cook_time_minutes': cookTimeMinutes,
            'servings': servings,
            'difficulty': difficulty,
            'meal_type': mealType,
            'image_url': imageUrl,
            'image_urls': imageUrls ?? [],
            'dietary_tags': dietaryTags ?? [],
            'nutrition_info': nutritionInfo?.toJson(),
            'calories': calories ?? 0,
            'protein': protein ?? 0.0,
            'carbs': carbs ?? 0.0,
            'fat': fat ?? 0.0,
            'fiber': fiber ?? 0.0,
            'tags': tags ?? [],
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select('*, users(id, full_name, username, avatar_url)')
          .single();

      return Result.success(RecipeModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Update a recipe
  Future<Result<RecipeModel>> updateRecipe(
    String recipeId, {
    String? title,
    String? description,
    List<RecipeIngredient>? ingredients,
    List<RecipeStep>? instructions,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    String? difficulty,
    String? mealType,
    String? imageUrl,
    List<String>? imageUrls,
    List<String>? dietaryTags,
    NutritionInfo? nutritionInfo,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    List<String>? tags,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (ingredients != null) updates['ingredients'] = ingredients.map((e) => e.toJson()).toList();
      if (instructions != null) updates['instructions'] = instructions.map((e) => e.toJson()).toList();
      if (prepTimeMinutes != null) updates['prep_time_minutes'] = prepTimeMinutes;
      if (cookTimeMinutes != null) updates['cook_time_minutes'] = cookTimeMinutes;
      if (servings != null) updates['servings'] = servings;
      if (difficulty != null) updates['difficulty'] = difficulty;
      if (mealType != null) updates['meal_type'] = mealType;
      if (imageUrl != null) updates['image_url'] = imageUrl;
      if (imageUrls != null) updates['image_urls'] = imageUrls;
      if (dietaryTags != null) updates['dietary_tags'] = dietaryTags;
      if (nutritionInfo != null) updates['nutrition_info'] = nutritionInfo.toJson();
      if (calories != null) updates['calories'] = calories;
      if (protein != null) updates['protein'] = protein;
      if (carbs != null) updates['carbs'] = carbs;
      if (fat != null) updates['fat'] = fat;
      if (fiber != null) updates['fiber'] = fiber;
      if (tags != null) updates['tags'] = tags;

      final response = await client
          .from('recipes')
          .update(updates)
          .eq('id', recipeId)
          .eq('user_id', userId!)
          .select('*, users(id, full_name, username, avatar_url)')
          .single();

      return Result.success(RecipeModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Delete a recipe
  Future<Result<void>> deleteRecipe(String recipeId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('recipes')
          .delete()
          .eq('id', recipeId)
          .eq('user_id', userId!);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // SAVED RECIPES
  // ============================================

  /// Get user's saved recipes
  Future<Result<List<RecipeModel>>> getSavedRecipes() async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('saved_recipes')
          .select('*, recipes(*, users(id, full_name, username, avatar_url))')
          .eq('user_id', userId!)
          .order('saved_at', ascending: false);

      final recipes = (response as List)
          .map((json) => RecipeModel.fromJson(json['recipes']))
          .map((r) => r.copyWith(isSavedByMe: true))
          .toList();

      return Result.success(recipes);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Save a recipe
  Future<Result<void>> saveRecipe(String recipeId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client.from('saved_recipes').insert({
        'user_id': userId!,
        'recipe_id': recipeId,
        'saved_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Unsave a recipe
  Future<Result<void>> unsaveRecipe(String recipeId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('saved_recipes')
          .delete()
          .eq('user_id', userId!)
          .eq('recipe_id', recipeId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Toggle save status
  Future<Result<bool>> toggleSave(String recipeId) async {
    final isSaved = await _isRecipeSaved(recipeId);
    if (isSaved) {
      final result = await unsaveRecipe(recipeId);
      return result.isSuccess ? Result.success(false) : Result.failure(result.error!);
    } else {
      final result = await saveRecipe(recipeId);
      return result.isSuccess ? Result.success(true) : Result.failure(result.error!);
    }
  }

  /// Helper to get saved recipe IDs
  Future<Set<String>> _getSavedRecipeIds() async {
    if (userId == null) return {};

    try {
      final response = await client
          .from('saved_recipes')
          .select('recipe_id')
          .eq('user_id', userId!);

      return (response as List)
          .map((json) => json['recipe_id'] as String)
          .toSet();
    } catch (e) {
      return {};
    }
  }

  /// Helper to check if recipe is saved
  Future<bool> _isRecipeSaved(String recipeId) async {
    if (userId == null) return false;

    try {
      final response = await client
          .from('saved_recipes')
          .select('id')
          .eq('user_id', userId!)
          .eq('recipe_id', recipeId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // RATINGS
  // ============================================

  /// Rate a recipe
  Future<Result<void>> rateRecipe(String recipeId, int rating, {String? review}) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      if (rating < 1 || rating > 5) {
        return Result.failure(
            RepositoryException(message: 'Rating must be between 1 and 5'));
      }

      await client.from('recipe_ratings').upsert({
        'user_id': userId!,
        'recipe_id': recipeId,
        'rating': rating,
        'review': review,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update recipe's average rating
      await _updateRecipeAverageRating(recipeId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get user's rating for a recipe
  Future<Result<RecipeRatingModel?>> getUserRating(String recipeId) async {
    if (userId == null) return Result.success(null);

    try {
      final response = await client
          .from('recipe_ratings')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('user_id', userId!)
          .eq('recipe_id', recipeId)
          .maybeSingle();

      if (response == null) return Result.success(null);
      return Result.success(RecipeRatingModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get all ratings for a recipe
  Future<Result<List<RecipeRatingModel>>> getRecipeRatings(String recipeId) async {
    try {
      final response = await client
          .from('recipe_ratings')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false);

      final ratings = (response as List)
          .map((json) => RecipeRatingModel.fromJson(json))
          .toList();

      return Result.success(ratings);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Update recipe's average rating
  Future<void> _updateRecipeAverageRating(String recipeId) async {
    try {
      final response = await client
          .from('recipe_ratings')
          .select('rating')
          .eq('recipe_id', recipeId);

      final ratings = (response as List).map((r) => r['rating'] as int).toList();
      if (ratings.isEmpty) return;

      final average = ratings.reduce((a, b) => a + b) / ratings.length;

      await client.from('recipes').update({
        'average_rating': average,
        'ratings_count': ratings.length,
      }).eq('id', recipeId);
    } catch (e) {
      // Silently fail - rating was still saved
    }
  }

  // ============================================
  // CATEGORIES & MEAL TYPES
  // ============================================

  /// Get available dietary tags
  Future<Result<List<String>>> getDietaryTags() async {
    try {
      final response = await client
          .from('recipes')
          .select('dietary_tags');

      final allTags = <String>{};
      for (final row in response as List) {
        final tags = row['dietary_tags'] as List<dynamic>?;
        if (tags != null) {
          allTags.addAll(tags.cast<String>());
        }
      }

      final tagsList = allTags.toList()..sort();
      return Result.success(tagsList);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }
}
