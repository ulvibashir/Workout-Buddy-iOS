import Foundation

extension Date {
    var shortFormatted: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: self)
    }

    var dayOfWeek: String {
        let days = ["sunday","monday","tuesday","wednesday","thursday","friday","saturday"]
        let index = Calendar.current.component(.weekday, from: self) - 1
        return days[index]
    }

    static func from(yyyyMMdd: String) -> Date? {
        DateFormatter.yyyyMMdd.date(from: yyyyMMdd)
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

extension TimeInterval {
    var hhMMss: String {
        let h = Int(self) / 3600
        let m = Int(self) % 3600 / 60
        let s = Int(self) % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }
}
