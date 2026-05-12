import Foundation

struct UserProfile: Codable {
    var name:    String = "Ulvi"
    var age:     Int    = 23
    var weight:  Double = 68
    var height:  Int    = 175
    var job:     String = "iOS Developer at Kapital Bank, Baku, Azerbaijan"
    var city:    String = "Baku, Azerbaijan"
    var goals:            Goals            = Goals()
    var baselineMetrics:  BaselineMetrics  = BaselineMetrics()
    var achievements:     Achievements     = Achievements()

    struct Goals: Codable {
        var primary:   String = "Hybrid Athlete (equal strength + endurance)"
        var secondary: String = "Fix pelvic tilt, run 7:00/km, 20 pull-ups"
        var sixMonth:  String = "Race-ready hybrid athlete by November 2026"
    }

    struct BaselineMetrics: Codable {
        var weight:    Double = 68.0
        var rhr:       Int    = 58
        var hrv:       Int    = 65
        var vo2max:    Double = 41.1
        var pullUpMax: Int    = 10
    }

    struct Achievements: Codable {
        var bakuMarathon2026: Marathon = Marathon()

        struct Marathon: Codable {
            var date:         String = "May 3, 2026"
            var distance:     Double = 43.08
            var officialTime: String = "6:39:03"
            var avgPace:      String = "9:06"
            var avgHR:        Int    = 157
            var elevation:    Int    = 333
            var calories:     Int    = 2838
        }
    }
}
