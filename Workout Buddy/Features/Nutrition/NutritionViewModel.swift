import Foundation
import FirebaseFirestore

@MainActor
@Observable
final class NutritionViewModel {

    var isLoading: Bool = false
    var expandedMeal: String? = nil
    var targets: NutritionTargets = .default
    var trainingMeals: [NutritionMeal] = []
    var restMeals: [NutritionMeal] = []
    var eatFreelyFoods: [GuideFoodItem] = []
    var eatInModerationFoods: [GuideFoodItem] = []
    var avoidFoods: [GuideFoodItem] = []
    var cheatDayRules: [String] = []
    var supplements: [Supplement] = []

    var isTrainingDay: Bool {
        Calendar.current.component(.weekday, from: Date()) != 1
    }

    var todayTargets: NutritionTargets.MacroTarget {
        isTrainingDay ? targets.trainingDays : targets.restDays
    }

    var todayMeals: [NutritionMeal] {
        isTrainingDay ? trainingMeals : restMeals
    }

    private let db = Firestore.firestore()
    private let uid: String

    init(uid: String) {
        self.uid = uid
    }

    func loadData() async {
        isLoading = true
        async let targetsSnap     = db.document("users/\(uid)/nutritionConfig/targets").getDocument(as: NutritionTargets.self)
        async let mealsSnap       = db.document("users/\(uid)/nutritionConfig/meals").getDocument(as: NutritionMealsDoc.self)
        async let guideSnap       = db.document("users/\(uid)/nutritionConfig/guide").getDocument(as: NutritionGuideDoc.self)
        async let supplementsSnap = db.document("users/\(uid)/nutritionConfig/supplements").getDocument(as: SupplementsDoc.self)

        targets = (try? await targetsSnap) ?? .default
        if let mealsDoc = try? await mealsSnap {
            trainingMeals = mealsDoc.training
            restMeals     = mealsDoc.rest
        }
        if let guide = try? await guideSnap {
            eatFreelyFoods       = guide.eatFreely
            eatInModerationFoods = guide.eatModeration
            avoidFoods           = guide.avoid
            cheatDayRules        = guide.cheatDayRules
        }
        supplements = (try? await supplementsSnap)?.items ?? []
        isLoading = false
    }
}
