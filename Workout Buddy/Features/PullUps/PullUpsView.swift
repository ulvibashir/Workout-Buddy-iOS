import SwiftUI
import FirebaseFirestore

// MARK: - SixMonthGoal model

struct SixMonthGoal: Codable {
    var metric:    String
    var start:     Double
    var month6:    Double
    var unit:      String
    var direction: String   // "increase" or "decrease"
}

// MARK: - ProgressTabViewModel

@MainActor
@Observable
final class ProgressTabViewModel {

    var userGoals:     [String]       = []
    var sixMonthGoals: [SixMonthGoal] = []
    var todayMetrics:  HealthMetrics? = nil
    var quote:         String         = ""
    var isLoading:     Bool           = false

    private let db  = Firestore.firestore()
    private let uid: String

    init(uid: String) { self.uid = uid }

    func loadData() async {
        isLoading = true
        await fetchAll()
        isLoading = false
    }

    func refresh() async { await fetchAll() }

    private func fetchAll() async {
        async let profileSnap = db.document("users/\(uid)/profile/main").getDocument(as: UserProfile.self)
        async let goalsSnap   = db.document("users/\(uid)/goals/sixMonth").getDocument()
        async let quotesSnap  = db.document("users/\(uid)/goals/quotes").getDocument()
        async let metricsSnap = db.document("users/\(uid)/healthMetrics/\(Date.today.dateKey)").getDocument(as: HealthMetrics.self)

        userGoals    = (try? await profileSnap)?.goals ?? []
        todayMetrics = try? await metricsSnap

        if let data = (try? await goalsSnap)?.data(),
           let arr  = data["goals"] as? [[String: Any]] {
            sixMonthGoals = arr.compactMap { d in
                guard let metric    = d["metric"]    as? String,
                      let start     = d["start"]     as? Double,
                      let month6    = d["month6"]    as? Double,
                      let unit      = d["unit"]      as? String,
                      let direction = d["direction"] as? String
                else { return nil }
                return SixMonthGoal(metric: metric, start: start, month6: month6, unit: unit, direction: direction)
            }
        }

        if let data = (try? await quotesSnap)?.data(),
           let arr  = data["quotes"] as? [String] {
            quote = arr.randomElement() ?? ""
        }
    }

    // MARK: - Helpers

    func currentValue(for goal: SixMonthGoal) -> Double? {
        guard let m = todayMetrics else { return nil }
        switch goal.metric {
        case "Body Weight": return m.weight
        case "Resting HR":  return m.rhr
        case "HRV":         return m.hrv
        case "VO2 Max":     return m.vo2max
        default:            return nil
        }
    }

    func progress(for goal: SixMonthGoal) -> Double {
        guard let current = currentValue(for: goal) else { return 0 }
        let range = abs(goal.month6 - goal.start)
        guard range > 0 else { return 0 }
        let done = goal.direction == "increase" ? current - goal.start : goal.start - current
        return min(1, max(0, done / range))
    }

    func goalInfo(_ id: String) -> (emoji: String, label: String) {
        switch id {
        case "hybrid_athlete": return ("🏋️", "Hybrid Athlete")
        case "hyrox":          return ("💪", "HYROX")
        case "ironman":        return ("🏊", "Ironman")
        case "marathon":       return ("🏃", "Marathon")
        default:               return ("🎯", id.replacingOccurrences(of: "_", with: " ").capitalized)
        }
    }
}

// MARK: - ProgressTabView

struct ProgressTabView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var vm: ProgressTabViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm, !vm.isLoading {
                    progressContent(vm: vm)
                } else {
                    progressSkeleton
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.appBackground.ignoresSafeArea())
        }
        .task {
            guard vm == nil, let uid = authViewModel.currentUID else { return }
            let m = ProgressTabViewModel(uid: uid)
            vm = m
            await m.loadData()
        }
    }

    // MARK: - Skeleton

    private var progressSkeleton: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                SkeletonView().frame(height: 20).frame(maxWidth: 100, alignment: .leading)
                HStack(spacing: Spacing.sm) {
                    SkeletonView().frame(width: 130, height: 38)
                    SkeletonView().frame(width: 100, height: 38)
                    SkeletonView().frame(width: 110, height: 38)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                SkeletonView().frame(height: 20).frame(maxWidth: 200, alignment: .leading)
                VStack(spacing: 0) {
                    ForEach(0..<6, id: \.self) { i in
                        SkeletonView().frame(height: 60).padding(Spacing.md)
                        if i < 5 { Divider() }
                    }
                }
                .background(Color.appSurface)
                .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                SkeletonView().frame(height: 60)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Content

    private func progressContent(vm: ProgressTabViewModel) -> some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                if !vm.userGoals.isEmpty {
                    goalsSection(vm: vm)
                }
                if !vm.sixMonthGoals.isEmpty {
                    sixMonthSection(vm: vm)
                }
                if !vm.quote.isEmpty {
                    quoteCard(vm.quote)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.xxxl)
        }
        .refreshable { await vm.refresh() }
    }

    // MARK: - Goals Badges

    private func goalsSection(vm: ProgressTabViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title: "My Goals")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(vm.userGoals, id: \.self) { id in
                        let info = vm.goalInfo(id)
                        HStack(spacing: Spacing.xs) {
                            Text(info.emoji)
                            Text(info.label)
                                .font(.appSubheadline)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.appPrimary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.lg)
                                .stroke(Color.appPrimary.opacity(0.35), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - 6-Month Goals

    private func sixMonthSection(vm: ProgressTabViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title: "6-Month Targets · Nov 2026")
            VStack(spacing: 0) {
                ForEach(vm.sixMonthGoals.indices, id: \.self) { i in
                    goalRow(goal: vm.sixMonthGoals[i], vm: vm)
                    if i < vm.sixMonthGoals.count - 1 {
                        Divider().padding(.horizontal, Spacing.md)
                    }
                }
            }
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        }
    }

    private func goalRow(goal: SixMonthGoal, vm: ProgressTabViewModel) -> some View {
        let prog    = vm.progress(for: goal)
        let current = vm.currentValue(for: goal)

        return VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(goal.metric)
                    .font(.appSubheadline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                if let cur = current {
                    Text(formatted(cur, unit: goal.unit))
                        .font(.appCaption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.appPrimary)
                }
            }
            HStack(spacing: Spacing.xs) {
                Text(formatted(goal.start, unit: goal.unit))
                    .font(.appCaption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(minWidth: 44, alignment: .leading)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.appSurfaceRaised)
                            .frame(height: 5)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(current != nil ? Color.appPrimary : Color.appSurfaceRaised)
                            .frame(width: geo.size.width * prog, height: 5)
                            .animation(.spring(duration: 0.6), value: prog)
                    }
                }
                .frame(height: 5)
                Text(formatted(goal.month6, unit: goal.unit))
                    .font(.appCaption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(minWidth: 44, alignment: .trailing)
            }
        }
        .padding(Spacing.md)
    }

    private func formatted(_ value: Double, unit: String) -> String {
        if unit == "min/km" {
            let secs = Int(value * 60)
            return "\(secs / 60):\(String(format: "%02d", secs % 60))"
        }
        return value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(value)) \(unit)"
            : String(format: "%.1f \(unit)", value)
    }

    // MARK: - Quote Card

    private func quoteCard(_ text: String) -> some View {
        HStack(spacing: Spacing.md) {
            Rectangle()
                .fill(Color.appPrimary)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2))
            Text(text)
                .font(.appSubheadline)
                .italic()
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }
}
