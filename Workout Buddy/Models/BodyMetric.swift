import Foundation
import FirebaseFirestore

// MARK: - Health Metrics
// This file was BodyMetric.swift — repurposed for the new Firebase health schema.

struct HealthMetrics: Codable, Identifiable {
    @DocumentID var id: String?
    var date: String
    var hrv: Double?
    var rhr: Double?
    var vo2max: Double?
    var sleepHours: Double?
    var sleepQuality: String?
    var deepSleepHours: Double?
    var remSleepHours: Double?
    var steps: Int?
    var activeCalories: Double?
    var restingCalories: Double?
    var weight: Double?
    var lastSyncedAt: Timestamp?
    var syncSource: String?

    var readinessScore: Int {
        var score = 0
        if let hrv = hrv { score += min(40, Int(hrv / 80.0 * 40)) }
        if let rhr = rhr { score += max(0, min(40, Int((1 - (rhr - 40) / 40) * 40))) }
        if let sleep = sleepHours { score += min(20, Int(sleep / 8.0 * 20)) }
        return min(100, max(0, score))
    }

    var readinessStatus: ReadinessStatus {
        switch readinessScore {
        case 67...: return .ready
        case 34..<67: return .caution
        default: return .rest
        }
    }

    var hrvTrend: Trend? { nil }   // computed by comparing with previous day
    var rhrTrend: Trend? { nil }
}

// MARK: - Swimming Log

struct SwimmingLog: Codable, Identifiable {
    @DocumentID var id: String?
    var date: String
    var distance: Double    // meters
    var duration: Int       // seconds
    var avgPace: String?    // per 100m
    var strokes: [String]
    var laps: Int?
    var calories: Double?
    var source: String
    var createdAt: Timestamp?

    var formattedDistance: String {
        distance >= 1000
            ? String(format: "%.1f km", distance / 1000)
            : "\(Int(distance)) m"
    }

    var formattedDuration: String {
        let m = duration / 60; let s = duration % 60
        return String(format: "%d:%02d", m, s)
    }
}
