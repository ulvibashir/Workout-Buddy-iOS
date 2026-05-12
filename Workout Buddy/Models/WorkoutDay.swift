import Foundation

struct WorkoutDay: Codable {
    var name:      String
    var color:     String
    var duration:  String
    var intensity: String
    var exercises: [Exercise]
    var warmup:    [Exercise]
    var cooldown:  [Exercise]
    var activation: [Exercise]

    init(name: String, color: String, duration: String, intensity: String,
         exercises: [Exercise] = [], warmup: [Exercise] = [],
         cooldown: [Exercise] = [], activation: [Exercise] = []) {
        self.name       = name;  self.color      = color
        self.duration   = duration; self.intensity  = intensity
        self.exercises  = exercises; self.warmup     = warmup
        self.cooldown   = cooldown;  self.activation = activation
    }
}

struct Exercise: Codable {
    var name:   String
    var sets:   Int?
    var reps:   String?
    var notes:  String?
    var weight: String?

    // Firestore (seeded by web dashboard) uses "exercise" not "name"
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
        // reps can be Int or String in Firestore
        if let s = try? c.decodeIfPresent(String.self, forKey: .reps) {
            reps = s
        } else if let n = try? c.decodeIfPresent(Int.self, forKey: .reps) {
            reps = String(n)
        } else {
            reps = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encodeIfPresent(sets, forKey: .sets)
        try c.encodeIfPresent(reps, forKey: .reps)
        try c.encodeIfPresent(notes, forKey: .notes)
        try c.encodeIfPresent(weight, forKey: .weight)
    }

    // Direct initializer for seeder / in-memory use
    init(name: String, sets: Int? = nil, reps: String? = nil,
         notes: String? = nil, weight: String? = nil) {
        self.name = name; self.sets = sets; self.reps = reps
        self.notes = notes; self.weight = weight
    }
}

extension Exercise: Identifiable {
    var id: String { name }
}

// Logged set during a workout session (UI-only, not persisted)
struct LoggedSet: Identifiable {
    let id = UUID()
    var reps:      Int    = 0
    var weight:    Double = 0
    var completed: Bool   = false
}
