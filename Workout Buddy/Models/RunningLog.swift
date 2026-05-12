import Foundation
import FirebaseFirestore

struct RunningLog: Codable, Identifiable {
    @DocumentID var id: String?

    var date:     String
    var distance: Double   // km
    var time:     String   // "H:MM:SS"
    var avgPace:  String   // "M:SS"
    var avgHR:    Int
    var notes:    String
    var runType:  String   // "Easy", "Tempo", "Long", "Marathon", etc.
}

struct SixMonthGoal: Codable, Identifiable {
    var metric:    String
    var start:     Double
    var month6:    Double
    var unit:      String
    var direction: String  // "increase" | "decrease"

    var id: String { metric }
}
