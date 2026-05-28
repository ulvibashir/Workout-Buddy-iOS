import Foundation
import FirebaseFirestore

// MARK: - Workout Plan (from Firebase workoutPlans collection)

struct WorkoutPlan: Codable, Identifiable {
    @DocumentID var id: String?   // day key: "monday", "tuesday", etc.
    var name: String
    var type: String              // "strength", "cardio", "rest"
    var colorHex: String
    var duration: String
    var intensity: String
    var exercises: [String]
    var targetDistance: String?
    var targetHR: String?

    var dayColor: String { colorHex }

    static let dayOrder = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]

    var workoutType: WorkoutType {
        WorkoutType(rawValue: type) ?? .strength
    }

    var isRestDay: Bool { type == "rest" }
    var isRunDay: Bool  { type == "cardio" && (exercises.first?.contains("Run") == true) }
    var isSwimDay: Bool { exercises.first?.contains("Swim") == true || exercises.contains("Zone 2 Swim") }
}

// MARK: - Workout Log (persisted per-day status)

struct WorkoutLog: Codable, Identifiable {
    @DocumentID var id: String?   // date key: "yyyy-MM-dd"
    var date: String
    var workoutType: String
    var workoutName: String
    var status: WorkoutStatus
    var isAutoMissed: Bool
    var completedAt: Timestamp?
    var postponedAt: Timestamp?
    var statusChangedAt: Timestamp
    var exercises: [String]
    var notes: String?

    init(date: String, workoutType: String, workoutName: String,
         status: WorkoutStatus, isAutoMissed: Bool = false,
         completedAt: Timestamp? = nil, postponedAt: Timestamp? = nil,
         exercises: [String] = [], notes: String? = nil) {
        self.date = date
        self.workoutType = workoutType
        self.workoutName = workoutName
        self.status = status
        self.isAutoMissed = isAutoMissed
        self.completedAt = completedAt
        self.postponedAt = postponedAt
        self.statusChangedAt = Timestamp(date: Date())
        self.exercises = exercises
        self.notes = notes
    }
}

// MARK: - Exercise (kept for backward compat with existing Firestore data)

struct Exercise: Codable, Identifiable {
    var id: String { name }
    var name: String
    var sets: Int?
    var reps: String?
    var notes: String?
    var weight: String?

    enum CodingKeys: String, CodingKey {
        case name = "exercise"
        case sets, notes, weight, reps
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name   = try c.decode(String.self, forKey: .name)
        sets   = try c.decodeIfPresent(Int.self, forKey: .sets)
        notes  = try c.decodeIfPresent(String.self, forKey: .notes)
        weight = try c.decodeIfPresent(String.self, forKey: .weight)
        if let s = try? c.decodeIfPresent(String.self, forKey: .reps) {
            reps = s
        } else if let n = try? c.decodeIfPresent(Int.self, forKey: .reps) {
            reps = String(n)
        } else { reps = nil }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encodeIfPresent(sets, forKey: .sets)
        try c.encodeIfPresent(reps, forKey: .reps)
        try c.encodeIfPresent(notes, forKey: .notes)
        try c.encodeIfPresent(weight, forKey: .weight)
    }

    init(name: String, sets: Int? = nil, reps: String? = nil,
         notes: String? = nil, weight: String? = nil) {
        self.name = name; self.sets = sets; self.reps = reps
        self.notes = notes; self.weight = weight
    }
}
