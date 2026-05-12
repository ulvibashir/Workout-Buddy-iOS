import Foundation
import FirebaseFirestore

struct PullUpLog: Codable, Identifiable {
    @DocumentID var id: String?  // date key "yyyy-MM-dd"

    var sets:      [Int]
    var maxReps:   Int
    var totalReps: Int
}

struct PullUpProgram: Codable {
    var currentMax:       Int
    var currentTraining:  Int
    var grips:            [String]
    var weeklyProgression: [WeekPlan]

    struct WeekPlan: Codable {
        var week: Int
        var sets: Int
        var reps: Int
    }
}
