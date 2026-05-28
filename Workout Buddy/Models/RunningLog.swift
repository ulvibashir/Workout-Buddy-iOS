import Foundation
import FirebaseFirestore

struct RunningLog: Codable, Identifiable {
    @DocumentID var id: String?
    var date: String
    var distance: Double    // km
    var duration: Int       // seconds
    var avgPace: String
    var avgHeartRate: Int?
    var avgCadence: Int?
    var calories: Double?
    var elevationGain: Double?
    var source: String
    var createdAt: Timestamp?

    // Legacy fields kept for backward compat with existing Firestore data
    var time: String?
    var avgHR: Int?
    var notes: String?
    var runType: String?

    var formattedDistance: String {
        String(format: "%.1f km", distance)
    }

    var effectiveAvgHR: Int? { avgHeartRate ?? avgHR }

    var formattedDuration: String {
        let h = duration / 3600
        let m = (duration % 3600) / 60
        let s = duration % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }

    init(date: String, distance: Double, duration: Int = 0,
         avgPace: String = "", avgHeartRate: Int? = nil,
         avgCadence: Int? = nil, calories: Double? = nil,
         elevationGain: Double? = nil, source: String = "healthkit",
         time: String? = nil, avgHR: Int? = nil,
         notes: String? = nil, runType: String? = nil) {
        self.date = date; self.distance = distance; self.duration = duration
        self.avgPace = avgPace; self.avgHeartRate = avgHeartRate
        self.avgCadence = avgCadence; self.calories = calories
        self.elevationGain = elevationGain; self.source = source
        self.time = time; self.avgHR = avgHR
        self.notes = notes; self.runType = runType
        self.createdAt = Timestamp(date: Date())
    }
}
