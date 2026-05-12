import Foundation

enum AppConstants {
    static let userID = "ulvi"

    enum Firestore {
        static let userRoot = "users/\(AppConstants.userID)"

        static func path(_ collection: String, _ docID: String? = nil) -> String {
            if let docID { return "\(userRoot)/\(collection)/\(docID)" }
            return "\(userRoot)/\(collection)"
        }

        enum Collections {
            static let bodyMetrics    = "bodyMetrics"
            static let nutritionLogs  = "nutritionLogs"
            static let pullUpLogs     = "pullUpLogs"
            static let runningLogs    = "runningLogs"
            static let workoutLogs    = "workoutLogs"
            static let workoutDays    = "workoutDays"
            static let nutritionConfig = "nutritionConfig"
            static let foodDatabase   = "foodDatabase"
            static let pullupProgram  = "pullupProgram"
            static let goals          = "goals"
            static let profile        = "profile"
            static let meta           = "meta"
        }

        enum Documents {
            static let profileMain   = "main"
            static let completed     = "completed"
            static let targets       = "targets"
            static let supplements   = "supplements"
            static let foodAll       = "all"
            static let programMain   = "main"
            static let sixMonth      = "sixMonth"
            static let quotes        = "quotes"
            static let seeded        = "seeded"
            static let morningMobility = "morningMobility"
        }

        enum WeekDays {
            static let all = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]
        }
    }

    enum HealthKit {
        static let minSyncInterval: TimeInterval = 3600 // 1 hour
    }
}

extension Date {
    static var todayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
