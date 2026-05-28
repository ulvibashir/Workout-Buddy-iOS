import Foundation

@MainActor
@Observable
final class NutritionViewModel {

    var isLoading: Bool = false
    var expandedMeal: String? = nil

    var isTrainingDay: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday != 1 // Sunday = 1
    }

    var todayTargets: MacroTarget {
        isTrainingDay ? MacroTarget.training : MacroTarget.rest
    }

    // MARK: - Static nutrition data (from spec)

    struct MacroTarget {
        let calories: Int
        let protein: Int
        let carbs: Int
        let fat: Int
        let water: Double

        static let training = MacroTarget(calories: 2900, protein: 136, carbs: 325, fat: 75, water: 3.5)
        static let rest      = MacroTarget(calories: 2300, protein: 136, carbs: 225, fat: 70, water: 3.0)
    }

    struct MealPlan: Identifiable {
        let id: String
        let emoji: String
        let time: String
        let name: String
        let foods: String
        let protein: Int
        let carbs: Int
        let fat: Int
    }

    var meals: [MealPlan] {
        if isTrainingDay {
            return [
                MealPlan(id: "breakfast", emoji: "🌅", time: "07:00", name: "Breakfast",
                         foods: "Oatmeal 80g + banana + 3 eggs + honey, black tea",
                         protein: 29, carbs: 88, fat: 10),
                MealPlan(id: "snack1", emoji: "🍎", time: "10:00", name: "Morning Snack",
                         foods: "Greek yogurt 200g + mixed nuts 30g",
                         protein: 20, carbs: 18, fat: 12),
                MealPlan(id: "lunch", emoji: "🌞", time: "13:00", name: "Lunch",
                         foods: "Chicken breast 200g + rice 100g + vegetables",
                         protein: 45, carbs: 80, fat: 8),
                MealPlan(id: "preworkout", emoji: "⚡", time: "17:30", name: "Pre-Workout",
                         foods: "Banana + rice cake + coffee",
                         protein: 5, carbs: 45, fat: 2),
                MealPlan(id: "postworkout", emoji: "💪", time: "19:30", name: "Post-Workout",
                         foods: "Protein shake + banana",
                         protein: 30, carbs: 35, fat: 3),
                MealPlan(id: "dinner", emoji: "🌙", time: "20:30", name: "Dinner",
                         foods: "Salmon/beef 200g + sweet potato 150g + salad",
                         protein: 45, carbs: 35, fat: 20),
            ]
        } else {
            return [
                MealPlan(id: "breakfast", emoji: "🌅", time: "08:00", name: "Breakfast",
                         foods: "3 eggs + whole grain toast + avocado, black tea",
                         protein: 24, carbs: 30, fat: 18),
                MealPlan(id: "lunch", emoji: "🌞", time: "13:00", name: "Lunch",
                         foods: "Chicken breast 200g + quinoa 80g + vegetables",
                         protein: 48, carbs: 65, fat: 8),
                MealPlan(id: "snack", emoji: "🍎", time: "16:00", name: "Snack",
                         foods: "Cottage cheese 150g + fruit",
                         protein: 18, carbs: 20, fat: 3),
                MealPlan(id: "dinner", emoji: "🌙", time: "19:30", name: "Dinner",
                         foods: "Fish 200g + roasted vegetables + salad",
                         protein: 42, carbs: 25, fat: 15),
            ]
        }
    }

    var eatFreelyFoods: [(String, String)] = [
        ("Chicken breast", "48g protein/200g"),
        ("Oats", "54g carbs/80g"),
        ("Eggs", "6g protein each"),
        ("Greek yogurt", "10g protein/100g"),
        ("Sweet potato", "27g carbs/150g"),
        ("Rice", "45g carbs/100g"),
        ("Salmon", "40g protein/200g"),
        ("Tuna (canned)", "30g protein/130g"),
    ]

    var eatInModerationFoods: [(String, String)] = [
        ("Avocado", "Healthy fats, 9g/100g"),
        ("Nuts (mixed)", "15g fat/30g"),
        ("Olive oil", "14g fat/tbsp"),
        ("Dark chocolate 85%+", "Limited — antioxidants"),
        ("Cheese", "Calcium, moderate portion"),
    ]

    var avoidFoods: [(String, String)] = [
        ("Alcohol", "Destroys recovery"),
        ("Processed meat", "High sodium/preservatives"),
        ("Sugary drinks", "Empty calories"),
        ("White bread (excess)", "Insulin spikes"),
        ("Fried food", "Trans fats"),
    ]

    var supplements: [(String, String, String, String)] = [
        ("💊", "Creatine Monohydrate", "5g", "Anytime"),
        ("☀️", "Vitamin D3 + K2", "3000 IU", "Morning"),
        ("🌙", "Magnesium Glycinate", "300mg", "Before bed"),
        ("🐟", "Omega 3", "2-3g", "With meal"),
        ("🅱️", "Vitamin B Complex", "1 tablet", "Morning"),
    ]
}
