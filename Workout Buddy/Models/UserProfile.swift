import Foundation
import FirebaseFirestore

struct UserProfile: Codable {
    @DocumentID var id: String?
    var name: String
    var weight: Double
    var weightUnit: String
    var birthYear: Int?
    var goals: [String]
    var createdAt: Timestamp?
    var updatedAt: Timestamp?

    init(name: String = "Ulvi",
         weight: Double = 68.0,
         weightUnit: String = "kg",
         birthYear: Int? = nil,
         goals: [String] = ["hybrid_athlete", "hyrox", "ironman"]) {
        self.name = name
        self.weight = weight
        self.weightUnit = weightUnit
        self.birthYear = birthYear
        self.goals = goals
        self.createdAt = Timestamp(date: Date())
        self.updatedAt = Timestamp(date: Date())
    }
}
