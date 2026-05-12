import Foundation

enum AppError: LocalizedError {
    case firestoreRead(String)
    case firestoreWrite(String)
    case healthKitUnauthorized
    case healthKitUnavailable
    case decodingFailed(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .firestoreRead(let path):    return "Failed to read data at \(path)"
        case .firestoreWrite(let path):   return "Failed to write data at \(path)"
        case .healthKitUnauthorized:      return "HealthKit access denied. Grant permission in Settings → Privacy → Health."
        case .healthKitUnavailable:       return "HealthKit is not available on this device."
        case .decodingFailed(let detail): return "Data parsing error: \(detail)"
        case .unknown(let err):           return err.localizedDescription
        }
    }
}
