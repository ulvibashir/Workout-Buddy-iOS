import Foundation
import FirebaseFirestore

struct BodyMetric: Codable, Identifiable {
    @DocumentID var id: String?   // date key "yyyy-MM-dd"

    var weight: String
    var rhr:    String
    var hrv:    String
    var vo2max: String

    var weightValue: Double { Double(weight) ?? 0 }
    var rhrValue:    Double { Double(rhr) ?? 0 }
    var hrvValue:    Double { Double(hrv) ?? 0 }
    var vo2maxValue: Double { Double(vo2max) ?? 0 }
}
