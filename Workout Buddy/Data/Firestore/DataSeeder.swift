import Foundation
import FirebaseFirestore

// Seeds all static program data to Firestore on first launch.
// Uses the exact same field names as the web dashboard (exercise, fat, etc.)
// so both apps share the same Firestore documents.
final class DataSeeder {

    private let db: Firestore
    private let uid: String

    init(uid: String) {
        self.db = Firestore.firestore()
        self.uid = uid
    }

    func seedIfNeeded() async {
        let flagPath = "users/\(uid)/meta/seeded_v3"
        if let snap = try? await db.document(flagPath).getDocument(), snap.exists { return }
        do {
            try await seedAll()
            try await db.document("users/\(uid)/meta/seeded_v3").setData(["seededAt": ISO8601DateFormatter().string(from: Date())])
            print("[DataSeeder] Seeded successfully.")
        } catch {
            print("[DataSeeder] Error: \(error.localizedDescription)")
        }
    }

    // MARK: - Seed everything
    private func seedAll() async throws {
        // Firestore batch has a 500-document limit; we're well under that
        let batch = db.batch()
        let u = uid

        // 1. Profile
        batch.setData(profileData, forDocument: db.document("users/\(u)/profile/main"))

        // 2. Workout plans (transformed to match WorkoutPlan model)
        for (day, data) in workoutDays {
            let rawExercises = (data["exercises"] as? [[String: Any]]) ?? []
            let exerciseNames: [String] = rawExercises.compactMap { ex in
                guard let name = ex["exercise"] as? String else { return nil }
                if let sets = ex["sets"] as? Int, let reps = ex["reps"] as? String {
                    return "\(name) \(sets)×\(reps)"
                }
                return name
            }
            let planData: [String: Any] = [
                "name":      data["name"]     ?? "",
                "type":      planType(for: day),
                "colorHex":  data["color"]    ?? "#636366",
                "duration":  data["duration"] ?? "",
                "intensity": data["intensity"] ?? "",
                "exercises": exerciseNames
            ]
            batch.setData(planData, forDocument: db.document("users/\(u)/workoutPlans/\(day)"))
        }

        // 3. Nutrition config
        batch.setData(nutritionTargets, forDocument: db.document("users/\(u)/nutritionConfig/targets"))
        batch.setData(["items": supplementsData], forDocument: db.document("users/\(u)/nutritionConfig/supplements"))
        batch.setData(nutritionMealsData, forDocument: db.document("users/\(u)/nutritionConfig/meals"))
        batch.setData(nutritionGuideData, forDocument: db.document("users/\(u)/nutritionConfig/guide"))

        // 4. Food database
        batch.setData(["foods": foodDatabase], forDocument: db.document("users/\(u)/foodDatabase/all"))

        // 5. Pull-up program
        batch.setData(pullupProgram, forDocument: db.document("users/\(u)/pullupProgram/main"))

        // 6. Goals & quotes
        batch.setData(["goals": sixMonthGoals], forDocument: db.document("users/\(u)/goals/sixMonth"))
        batch.setData(["quotes": quotes], forDocument: db.document("users/\(u)/goals/quotes"))

        try await batch.commit()
    }

    // MARK: - Profile
    private var profileData: [String: Any] {
        [
            "name": "Ulvi",
            "weight": 68,
            "job": "iOS Developer at Kapital Bank, Baku, Azerbaijan",
            "city": "Baku, Azerbaijan",
            "goals": [
                "primary": "Hybrid Athlete (equal strength + endurance)",
                "secondary": "Fix pelvic tilt, run 7:00/km, 20 pull-ups",
                "sixMonth": "Race-ready hybrid athlete by November 2026"
            ],
            "baselineMetrics": [
                "weight": 68.0, "rhr": 58, "hrv": 65, "vo2max": 41.1, "pullUpMax": 10
            ],
            "achievements": [
                "bakuMarathon2026": [
                    "date": "May 3, 2026",
                    "distance": 43.08,
                    "officialTime": "6:39:03",
                    "avgPace": "9:06",
                    "avgHR": 157,
                    "elevation": 333,
                    "calories": 2838
                ]
            ]
        ]
    }

    // MARK: - Morning mobility
    private var morningMobility: [[String: Any]] {
        [
            ex("Cat-Cow", sets: 2, reps: "15", notes: "Slow and controlled. Breathe with movement."),
            ex("Hip Flexor Stretch (Kneeling)", sets: 1, notes: "KEY exercise for lordosis. Squeeze glute of back leg."),
            ex("Glute Bridge", sets: 3, reps: "20", notes: "Hold 2 sec at top. Directly fixes pelvic tilt."),
            ex("Dead Bug", sets: 3, reps: "10", notes: "Lower back FLAT on floor. Non-negotiable for lordosis."),
            ex("Thoracic Rotation", sets: 2, reps: "15", notes: "Undoes desk hunching."),
            ex("Hamstring Stretch", sets: 1, notes: "Tight hamstrings worsen lordosis."),
            ex("World's Greatest Stretch", sets: 1, reps: "5", notes: "Most complete stretch for runners and desk workers."),
        ]
    }

    // MARK: - Workout days
    private var workoutDays: [String: [String: Any]] {
        [
            "monday": [
                "name": "Upper Body", "color": "#fd7e14", "duration": "60-75 min", "intensity": "High",
                "warmup": [
                    ex("Arm Circles", notes: "Forward + backward"),
                    ex("Band Pull-Aparts", sets: 2, reps: "15", notes: "Shoulder health"),
                    ex("Slow Push Ups", sets: 1, reps: "10", notes: "Chest activation"),
                    ex("Glute Bridge Activation", sets: 1, reps: "20", notes: "Non-negotiable for lordosis"),
                ],
                "exercises": [
                    ex("Pull Ups", sets: 5, reps: "Max (currently 8)", notes: "Full hang. Chin over bar. 3-sec negative. PRIORITY exercise."),
                    ex("Bench Press / DB Press", sets: 4, reps: "8-10", notes: "Control descent. Elbows at 45 degrees."),
                    ex("Bent Over Row", sets: 4, reps: "10-12", notes: "Pull to hip not chest. Squeeze shoulder blade at top."),
                    ex("Overhead Press", sets: 3, reps: "10-12", notes: "Core tight. No arching back — worsens lordosis."),
                    ex("Lateral Raise", sets: 3, reps: "15", notes: "Lead with elbows. Shoulder health."),
                    ex("Face Pulls", sets: 3, reps: "15-20", notes: "ESSENTIAL for posture. External rotation at end."),
                    ex("Tricep Pushdown", sets: 3, reps: "12-15", notes: "Elbows close to body."),
                    ex("Bicep Curl", sets: 3, reps: "12", notes: "No swinging. Slow negative 2-3 sec."),
                    ex("Dead Bug", sets: 3, reps: "10 each side", notes: "ESSENTIAL for lordosis. Lower back flat."),
                    ex("Plank", sets: 3, reps: "45-60 sec", notes: "Straight line head to heel."),
                ],
                "cooldown": [
                    ex("Chest Doorway Stretch"), ex("Lat Stretch"),
                    ex("Hip Flexor Stretch", notes: "NON-NEGOTIABLE every session"), ex("Child's Pose"),
                ]
            ],
            "tuesday": [
                "name": "Run 8-10km (Zone 2)", "color": "#0077b6", "duration": "60-75 min", "intensity": "Moderate",
                "warmup": [], "cooldown": [],
                "exercises": [
                    ex("Warm Up Walk", notes: "HR < 120 BPM"),
                    ex("Zone 2 Run (Main)", notes: "9:00-10:30/km · HR 135-145 BPM"),
                    ex("Pull Ups (mid-run)", sets: 3, reps: "Max", notes: "Find a bar on route"),
                    ex("Cooldown Jog + Walk", notes: "HR 115-125 BPM"),
                    ex("Post-run Stretching", notes: "IT band, hip flexors, quads, calves"),
                ]
            ],
            "wednesday": [
                "name": "Lower Body (Glutes Priority)", "color": "#6f42c1", "duration": "60-75 min", "intensity": "High",
                "warmup": [], "cooldown": [
                    ex("Kneeling Hip Flexor Stretch", notes: "MOST IMPORTANT — fixes lordosis."),
                    ex("Pigeon Pose", notes: "Deep glute stretch after heavy hip work."),
                    ex("Hamstring Stretch"), ex("Figure-4 Glute Stretch"),
                ],
                "exercises": [
                    ex("Pull Ups", sets: 5, reps: "Max (currently 8)", notes: "Every training day. No exceptions."),
                    ex("Barbell Back Squat / Goblet Squat", sets: 4, reps: "8-10", notes: "Chest up. Knees track toes."),
                    ex("Romanian Deadlift (RDL)", sets: 4, reps: "10-12", notes: "BEST for glutes + hamstrings."),
                    ex("Bulgarian Split Squat", sets: 3, reps: "10 each leg", notes: "Back foot elevated."),
                    ex("Hip Thrust", sets: 4, reps: "15-20", notes: "KING of glute exercises. Squeeze 2 sec at top."),
                    ex("Leg Press (feet high)", sets: 3, reps: "15", notes: "High foot placement = more glutes."),
                    ex("Calf Raises", sets: 4, reps: "20", notes: "Full range. Running essential."),
                    ex("Nordic Curl / Leg Curl", sets: 3, reps: "10-12", notes: "Hamstring injury prevention."),
                    ex("Ab Wheel / Hanging Leg Raise", sets: 3, reps: "10-15", notes: "Core + hip flexor strength."),
                ]
            ],
            "thursday": [
                "name": "Swim (Active Recovery)", "color": "#20c997", "duration": "40-50 min", "intensity": "Low",
                "warmup": [], "cooldown": [],
                "exercises": [
                    ex("Warm Up Freestyle", notes: "200m · Very easy effort"),
                    ex("Technique Set", sets: 4, reps: "50m each", notes: "Focus: breathing, arm entry, kick. 20 sec rest"),
                    ex("Endurance Set", sets: 4, reps: "100m each", notes: "Moderate effort · HR 130-145 · 20 sec rest"),
                    ex("Pull Ups", sets: 3, reps: "Max", notes: "Pool bars or nearby park"),
                    ex("Backstroke Recovery", notes: "200m · Opens chest"),
                    ex("Cooldown Easy", notes: "100m · Any stroke"),
                ]
            ],
            "friday": [
                "name": "Full Body + Pull Ups Power", "color": "#e94560", "duration": "60-75 min", "intensity": "High",
                "warmup": [], "cooldown": [],
                "exercises": [
                    ex("Pull Ups (PRIORITY)", sets: 6, reps: "Max", notes: "MOST pull up volume of the week. Mix grips each set."),
                    ex("Deadlift (Conventional)", sets: 4, reps: "6-8", notes: "King of compounds. Bar close to body."),
                    ex("Push Up Variations (explosive)", sets: 4, reps: "15-20", notes: "Regular + wide + diamond."),
                    ex("Dumbbell Snatch / KB Swing", sets: 3, reps: "10 each arm", notes: "Explosive hip drive."),
                    ex("TRX Row / Inverted Row", sets: 3, reps: "15", notes: "Horizontal pull."),
                    ex("Farmer's Carry", sets: 3, reps: "40m", notes: "Grip + core + traps. Walk tall. Heavy DBs."),
                    ex("Box Jump / Broad Jump", sets: 3, reps: "8", notes: "Explosive power for running. Land softly."),
                    ex("Ab Circuit (Plank+Hollow+Dead Bug)", sets: 3, notes: "No rest within round."),
                    ex("Backward Treadmill Walk", notes: "10-15 min · 2.5-3.5 km/h · VMO activation."),
                ]
            ],
            "saturday": [
                "name": "Long Run", "color": "#dc3545", "duration": "90-120 min", "intensity": "Moderate",
                "warmup": [], "cooldown": [],
                "exercises": [
                    ex("Warm Up Walk", notes: "5-10 min"),
                    ex("Zone 2 Run/Walk (8+2)", notes: "60-90 min · 8 min run + 2 min walk. HR 135-148."),
                    ex("Gel Station", notes: "Every 7km. Walk 90 sec to absorb."),
                    ex("Progressive Finish", notes: "Last 2-3km · 8:00-9:00/km. Finish strong."),
                    ex("Cooldown Walk", notes: "5-10 min"),
                    ex("Post-run Stretching", notes: "15 min — IT band, hip flexors, quads, calves."),
                ]
            ],
            "sunday": [
                "name": "Full Rest & Recovery", "color": "#343a40", "duration": "30-40 min", "intensity": "Low",
                "warmup": [], "cooldown": [],
                "exercises": [
                    ex("IT Band (outer thigh)", notes: "2 min each leg. STOP on tight spots 20-30 sec."),
                    ex("Quads", notes: "90 sec each leg. Tight quads worsen pelvic tilt."),
                    ex("Glutes (with ball)", notes: "90 sec each side. Tennis ball."),
                    ex("Calves", notes: "90 sec each leg. Ankle to behind knee."),
                    ex("Thoracic Spine", notes: "2 min. Roller horizontal across upper back."),
                    ex("Hip Flexors (lacrosse ball)", notes: "90 sec each side. Most important for lordosis."),
                    ex("Lats", notes: "60 sec each side."),
                ]
            ],
        ]
    }

    // MARK: - Nutrition targets
    private var nutritionTargets: [String: Any] {
        [
            "trainingDays": ["calories": 2900, "protein": 136, "carbs": 325, "fat": 75, "water": 3.5],
            "restDays":     ["calories": 2300, "protein": 136, "carbs": 225, "fat": 70, "water": 3.0]
        ]
    }

    // MARK: - Nutrition meals
    private var nutritionMealsData: [String: Any] {
        let training: [[String: Any]] = [
            meal("breakfast",  "🌅", "07:00", "Breakfast",     "Oatmeal 80g + banana + 3 eggs + honey, black tea", p: 29, c: 88, f: 10),
            meal("snack1",     "🍎", "10:00", "Morning Snack", "Greek yogurt 200g + mixed nuts 30g",               p: 20, c: 18, f: 12),
            meal("lunch",      "🌞", "13:00", "Lunch",         "Chicken breast 200g + rice 100g + vegetables",     p: 45, c: 80, f:  8),
            meal("preworkout", "⚡", "17:30", "Pre-Workout",   "Banana + rice cake + coffee",                      p:  5, c: 45, f:  2),
            meal("postworkout","💪", "19:30", "Post-Workout",  "Protein shake + banana",                           p: 30, c: 35, f:  3),
            meal("dinner",     "🌙", "20:30", "Dinner",        "Salmon/beef 200g + sweet potato 150g + salad",     p: 45, c: 35, f: 20),
        ]
        let rest: [[String: Any]] = [
            meal("breakfast", "🌅", "08:00", "Breakfast", "3 eggs + whole grain toast + avocado, black tea", p: 24, c: 30, f: 18),
            meal("lunch",     "🌞", "13:00", "Lunch",     "Chicken breast 200g + quinoa 80g + vegetables",   p: 48, c: 65, f:  8),
            meal("snack",     "🍎", "16:00", "Snack",     "Cottage cheese 150g + fruit",                     p: 18, c: 20, f:  3),
            meal("dinner",    "🌙", "19:30", "Dinner",    "Fish 200g + roasted vegetables + salad",          p: 42, c: 25, f: 15),
        ]
        return ["training": training, "rest": rest]
    }

    // MARK: - Nutrition guide
    private var nutritionGuideData: [String: Any] {
        [
            "eatFreely": [
                guide("Chicken breast",   "48g protein/200g"),
                guide("Oats",             "54g carbs/80g"),
                guide("Eggs",             "6g protein each"),
                guide("Greek yogurt",     "10g protein/100g"),
                guide("Sweet potato",     "27g carbs/150g"),
                guide("Rice",             "45g carbs/100g"),
                guide("Salmon",           "40g protein/200g"),
                guide("Tuna (canned)",    "30g protein/130g"),
            ],
            "eatModeration": [
                guide("Avocado",             "Healthy fats, 9g/100g"),
                guide("Nuts (mixed)",         "15g fat/30g"),
                guide("Olive oil",            "14g fat/tbsp"),
                guide("Dark chocolate 85%+",  "Limited — antioxidants"),
                guide("Cheese",               "Calcium, moderate portion"),
            ],
            "avoid": [
                guide("Alcohol",            "Destroys recovery"),
                guide("Processed meat",     "High sodium/preservatives"),
                guide("Sugary drinks",      "Empty calories"),
                guide("White bread (excess)","Insulin spikes"),
                guide("Fried food",         "Trans fats"),
            ],
            "cheatDayRules": [
                "Stay within reason — don't binge",
                "Avoid alcohol — hurts recovery",
                "Enjoy your meal, restart Monday",
                "Suggested: Plov, shawarma, dessert 🍖",
            ]
        ]
    }

    // MARK: - Supplements
    private var supplementsData: [[String: Any]] {
        [
            ["id": "creatine",   "emoji": "💊", "name": "Creatine Monohydrate", "dose": "5g",                   "timing": "Any time — consistency matters"],
            ["id": "vit_d3",     "emoji": "☀️", "name": "Vitamin D3 + K2",      "dose": "3000 IU D3+100mcg K2", "timing": "Morning with fat source"],
            ["id": "magnesium",  "emoji": "🌙", "name": "Magnesium Glycinate",   "dose": "300-400mg",             "timing": "Before bed"],
            ["id": "omega3",     "emoji": "🐟", "name": "Omega 3 Fish Oil",      "dose": "2-3g EPA+DHA",          "timing": "With any meal"],
            ["id": "vit_b",      "emoji": "🅱️", "name": "Vitamin B Complex",     "dose": "1 tablet",              "timing": "Morning with food"],
            ["id": "iron",       "emoji": "💊", "name": "Iron Bisglycinate",     "dose": "As prescribed",         "timing": "Away from omeprazole"],
            ["id": "omeprazole", "emoji": "💊", "name": "Omeprazole",            "dose": "As prescribed",         "timing": "30 min before meal"],
        ]
    }

    // MARK: - Food database
    private var foodDatabase: [[String: Any]] {
        [
            fd("chicken_breast",  "Chicken Breast (raw)",  unit: "100g", p: 23,   c: 0,   f: 2,   cal: 110),
            fd("boiled_egg",      "Boiled Egg",            unit: "egg",  p: 6,    c: 0,   f: 5,   cal: 70),
            fd("salmon",          "Salmon (raw)",          unit: "100g", p: 22,   c: 0,   f: 13,  cal: 208),
            fd("greek_yogurt",    "Greek Yogurt",          unit: "100g", p: 10,   c: 4,   f: 2,   cal: 73),
            fd("cottage_cheese",  "Cottage Cheese",        unit: "100g", p: 12,   c: 3,   f: 2,   cal: 72),
            fd("tuna",            "Tuna (canned)",         unit: "100g", p: 22,   c: 0,   f: 2,   cal: 108),
            fd("beef_lean",       "Beef (lean raw)",       unit: "100g", p: 26,   c: 0,   f: 8,   cal: 175),
            fd("white_rice",      "White Rice (raw)",      unit: "100g", p: 7,    c: 78,  f: 1,   cal: 360),
            fd("bulgur",          "Bulgur (raw)",          unit: "100g", p: 12,   c: 72,  f: 1,   cal: 342),
            fd("buckwheat",       "Buckwheat/Qarabasaq",   unit: "100g", p: 13,   c: 72,  f: 3,   cal: 343),
            fd("oats",            "Oats/Musli (raw)",      unit: "100g", p: 12,   c: 56,  f: 4,   cal: 373),
            fd("sweet_potato",    "Sweet Potato (raw)",    unit: "100g", p: 2,    c: 20,  f: 0,   cal: 86),
            fd("potato_boiled",   "Potato boiled",         unit: "100g", p: 2,    c: 17,  f: 0,   cal: 77),
            fd("pasta",           "Pasta (raw)",           unit: "100g", p: 13,   c: 75,  f: 2,   cal: 371),
            fd("whole_grain_bread","Whole Grain Bread",    unit: "slice",p: 3.5,  c: 19,  f: 1,   cal: 80),
            fd("banana",          "Banana",                unit: "banana",p: 1,   c: 27,  f: 0,   cal: 105),
            fd("honey",           "Honey",                 unit: "tbsp", p: 0,    c: 17,  f: 0,   cal: 64),
            fd("dates",           "Dates",                 unit: "date", p: 0.2,  c: 7,   f: 0,   cal: 20),
            fd("avocado",         "Avocado",               unit: "half", p: 1,    c: 6,   f: 15,  cal: 160),
            fd("olive_oil",       "Olive Oil",             unit: "tbsp", p: 0,    c: 0,   f: 14,  cal: 119),
            fd("almonds",         "Almonds",               unit: "30g",  p: 6,    c: 6,   f: 15,  cal: 173),
            fd("peanut_butter",   "Peanut Butter",         unit: "tbsp", p: 4,    c: 3,   f: 8,   cal: 94),
            fd("ayran",           "Ayran",                 unit: "200ml",p: 4,    c: 4,   f: 2,   cal: 52),
            fd("black_tea",       "Black Tea",             unit: "200ml",p: 0,    c: 0,   f: 0,   cal: 2),
            fd("coffee",          "Coffee (black)",        unit: "200ml",p: 0,    c: 0,   f: 0,   cal: 5),
        ]
    }

    // MARK: - Pull-up program
    private var pullupProgram: [String: Any] {
        [
            "currentMax": 10,
            "currentTraining": ["sets": 5, "reps": 8],
            "grips": ["Standard", "Chin Up", "Wide Grip", "Neutral", "Slow Negative"],
            "weeklyProgression": [
                ["week": 1, "sets": 5, "reps": 8,  "notes": "Establish baseline. 3-sec negative every rep."],
                ["week": 2, "sets": 5, "reps": 8,  "notes": "Establish baseline."],
                ["week": 3, "sets": 5, "reps": 9,  "notes": "Add wide grip variation."],
                ["week": 4, "sets": 5, "reps": 9,  "notes": "Add wide grip variation."],
                ["week": 5, "sets": 5, "reps": 10, "notes": "Mix grips each set."],
                ["week": 6, "sets": 5, "reps": 10, "notes": "Mix grips each set."],
                ["week": 7, "sets": 6, "reps": 10, "notes": "Add 5kg vest if getting easy."],
                ["week": 8, "sets": 6, "reps": 10, "notes": "Add 5kg vest if getting easy."],
            ]
        ]
    }

    // MARK: - Six-month goals
    private var sixMonthGoals: [[String: Any]] {
        [
            ["metric": "Body Weight",          "start": 68.0,  "month6": 73.0,  "unit": "kg",        "direction": "increase"],
            ["metric": "Pull-up Max",           "start": 10.0,  "month6": 20.0,  "unit": "reps",      "direction": "increase"],
            ["metric": "10km Pace (min/km)",    "start": 9.1,   "month6": 7.0,   "unit": "min/km",    "direction": "decrease"],
            ["metric": "Resting HR",            "start": 60.0,  "month6": 52.0,  "unit": "bpm",       "direction": "decrease"],
            ["metric": "HRV",                   "start": 60.0,  "month6": 75.0,  "unit": "ms",        "direction": "increase"],
            ["metric": "VO2 Max",               "start": 41.1,  "month6": 48.0,  "unit": "ml/kg/min", "direction": "increase"],
            ["metric": "Long Run Distance",     "start": 12.0,  "month6": 25.0,  "unit": "km",        "direction": "increase"],
            ["metric": "Swim Distance",         "start": 600.0, "month6": 1500.0,"unit": "m",         "direction": "increase"],
        ]
    }

    // MARK: - Quotes
    private var quotes: [String] {
        [
            "Every day is day one. — Arda Saatci",
            "You ran 43km on May 3rd. Your body knows how to suffer. Now make it stronger.",
            "You vs You. Nobody else.",
            "The pull up bar doesn't care about your excuses.",
            "Zone 2 today. Sub-7 pace tomorrow.",
            "Arda does 1000 pull ups. You do 8. Both started at 0.",
            "Desk job by day. Hybrid athlete by night.",
            "Your IT band recovered. Your discipline shouldn't need to.",
            "6:39 at your first marathon. What's next?",
            "Strong enough to run. Fast enough to lift. Smart enough to recover.",
        ]
    }

    // MARK: - Helpers

    private func planType(for day: String) -> String {
        switch day {
        case "tuesday", "saturday": return "cardio"
        case "thursday":            return "swim"
        case "sunday":              return "rest"
        default:                    return "strength"
        }
    }

    private func ex(_ name: String, sets: Int? = nil, reps: String? = nil, notes: String? = nil) -> [String: Any] {
        var d: [String: Any] = ["exercise": name]
        if let s = sets  { d["sets"]  = s }
        if let r = reps  { d["reps"]  = r }
        if let n = notes { d["notes"] = n }
        return d
    }

    private func fd(_ id: String, _ name: String, unit: String, p: Double, c: Double, f: Double, cal: Double) -> [String: Any] {
        ["id": id, "name": name, "unit": unit, "unitAmount": 1.0, "protein": p, "carbs": c, "fat": f, "calories": cal]
    }

    private func meal(_ id: String, _ emoji: String, _ time: String, _ name: String, _ foods: String, p: Int, c: Int, f: Int) -> [String: Any] {
        ["id": id, "emoji": emoji, "time": time, "name": name, "foods": foods, "protein": p, "carbs": c, "fat": f]
    }

    private func guide(_ name: String, _ stat: String) -> [String: Any] {
        ["name": name, "stat": stat]
    }
}
