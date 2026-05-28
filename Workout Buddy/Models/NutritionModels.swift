import Foundation
import FirebaseFirestore

// MARK: - Daily nutrition log
struct NutritionLog: Codable {
    var foods:       [LoggedFood]
    var water:       Int          // ml
    var supplements: [String]
}

struct LoggedFood: Codable, Identifiable {
    var id:       String
    var name:     String
    var weight:   Double   // grams or units consumed
    var protein:  Double
    var carbs:    Double
    var fats:     Double
    var calories: Double
}

// MARK: - Food database entry (matches web dashboard Firestore structure)
struct FoodItem: Codable, Identifiable {
    var id:         String
    var name:       String
    var unit:       String    // "100g", "egg", "tbsp", "banana", etc.
    var unitAmount: Double    // default serving size in that unit
    var protein:    Double    // macros per 1 unitAmount serving
    var carbs:      Double
    var fat:        Double    // web uses "fat" not "fats"
    var calories:   Double

    /// Scale macros by a multiplier (how many servings)
    func loggedFood(servings: Double) -> LoggedFood {
        LoggedFood(
            id:       UUID().uuidString,
            name:     name,
            weight:   unitAmount * servings,
            protein:  (protein  * servings * 10).rounded() / 10,
            carbs:    (carbs    * servings * 10).rounded() / 10,
            fats:     (fat      * servings * 10).rounded() / 10,
            calories: (calories * servings).rounded()
        )
    }

    /// Convenience: per-gram macros (useful for 100g-unit foods)
    var perGram: (protein: Double, carbs: Double, fat: Double, calories: Double) {
        let base = unitAmount > 0 ? unitAmount : 1
        return (protein/base, carbs/base, fat/base, calories/base)
    }
}

// MARK: - Macro targets
struct NutritionTargets: Codable {
    var trainingDays: MacroTarget
    var restDays:     MacroTarget

    struct MacroTarget: Codable {
        var calories: Int
        var protein:  Int
        var carbs:    Int
        var fat:      Int
        var water:    Double = 3.0
    }
}


// MARK: - Meal plan
struct NutritionMeal: Codable, Identifiable {
    var id:      String
    var emoji:   String
    var time:    String
    var name:    String
    var foods:   String
    var protein: Int
    var carbs:   Int
    var fat:     Int
}

struct NutritionMealsDoc: Codable {
    var training: [NutritionMeal]
    var rest:     [NutritionMeal]
}

// MARK: - Food guide
struct GuideFoodItem: Codable {
    var name: String
    var stat: String
}

struct NutritionGuideDoc: Codable {
    var eatFreely:      [GuideFoodItem]
    var eatModeration:  [GuideFoodItem]
    var avoid:          [GuideFoodItem]
    var cheatDayRules:  [String]
}

// MARK: - Supplement
struct Supplement: Codable, Identifiable {
    var id:     String
    var emoji:  String = "💊"
    var name:   String
    var dose:   String
    var timing: String
}

struct SupplementsDoc: Codable {
    var items: [Supplement]
}
