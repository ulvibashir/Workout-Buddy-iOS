import Foundation

// MARK: - App Enums
// This file was PullUpLog.swift — repurposed for app-wide enums and types.

enum WorkoutStatus: String, Codable, CaseIterable {
    case pending   = "pending"
    case completed = "completed"
    case postponed = "postponed"
    case missed    = "missed"
}

enum ReadinessStatus {
    case ready, caution, rest

    var label: String {
        switch self {
        case .ready:   return "Ready to train 🔥"
        case .caution: return "Train with caution ⚠️"
        case .rest:    return "Rest today 😴"
        }
    }
}

enum AuthState: Equatable {
    case loading
    case unauthenticated
    case authenticated(uid: String)

    var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }

    var uid: String? {
        if case .authenticated(let uid) = self { return uid }
        return nil
    }

    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.unauthenticated, .unauthenticated): return true
        case (.authenticated(let l), .authenticated(let r)): return l == r
        default: return false
        }
    }
}

enum WorkoutType: String, Codable {
    case upperBody  = "upper_body"
    case lowerBody  = "lower_body"
    case fullBody   = "full_body"
    case run        = "run"
    case swim       = "swim"
    case longRun    = "long_run"
    case rest       = "rest"
    case strength   = "strength"
    case cardio     = "cardio"
}

enum Trend {
    case up, down, neutral

    var symbol: String {
        switch self { case .up: return "↑"; case .down: return "↓"; case .neutral: return "→" }
    }

    var color: String {
        switch self { case .up: return "appSuccess"; case .down: return "appDanger"; case .neutral: return "appTextSecondary" }
    }
}
