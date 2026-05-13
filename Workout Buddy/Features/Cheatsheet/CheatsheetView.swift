import SwiftUI

struct CheatsheetView: View {
    var body: some View { _CheatsheetView() }
}

private struct _CheatsheetView: View {
    @State private var selectedTab = 0

    private let tabs: [(String, String, Color)] = [
        ("Workout",     "figure.strengthtraining.traditional", AppTheme.accentBlue),
        ("Foods",       "fork.knife",                          AppTheme.accentGreen),
        ("Meals",       "calendar",                            AppTheme.accentOrange),
        ("Supps",       "pills",                               AppTheme.accentPurple),
        ("Rules",       "list.bullet.clipboard",               AppTheme.accent),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabBar
                ScrollView {
                    LazyVStack(spacing: 12) {
                        switch selectedTab {
                        case 0: WorkoutTab()
                        case 1: FoodsTab()
                        case 2: MealsTab()
                        case 3: SuppsTab()
                        default: RulesTab()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 34)
                }
            }
            .navigationTitle("Cheatsheet")
            .navigationBarTitleDisplayMode(.large)
            .background(AppTheme.background.ignoresSafeArea())
        }
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tabs.indices, id: \.self) { i in
                    let (label, icon, color) = tabs[i]
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) { selectedTab = i }
                    } label: {
                        Label(label, systemImage: icon)
                            .font(.subheadline).bold()
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(selectedTab == i ? color : AppTheme.cardBackground)
                            .foregroundColor(selectedTab == i ? .white : AppTheme.textMuted)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(AppTheme.cardBackground)
    }
}

// MARK: – Shared components

private struct ExpandCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @State private var open = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) { open.toggle() }
            } label: {
                HStack {
                    Label(title, systemImage: icon).font(.subheadline).bold().foregroundColor(color)
                    Spacer()
                    Image(systemName: open ? "chevron.up" : "chevron.down")
                        .font(.caption).foregroundColor(AppTheme.textMuted)
                }
                .padding(14)
            }
            if open {
                Divider().background(AppTheme.border)
                content().padding(14)
            }
        }
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }
}

private struct InfoPill: View {
    let text: String; let color: Color
    var body: some View {
        Text(text).font(.caption2).bold()
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(color.opacity(0.18))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

private struct SectionCard<Content: View>: View {
    let title: String; let color: Color
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline).bold().foregroundColor(color)
            content()
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }
}

// MARK: – Workout Tab

private struct WorkoutTab: View {
    var body: some View {
        Group {
            lordosisAlert
            weeklyScheduleCard
            principlesCard
            morningMobilityCard
            pullUpProgressionCard
            pullUpVariantsCard
        }
    }

    private var lordosisAlert: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(AppTheme.accentOrange).font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text("LORDOSIS & PELVIC TILT PRIORITY").font(.caption).bold().foregroundColor(AppTheme.accentOrange)
                Text("Every gym session begins with glute activation (bridges + clamshells — 2 min). Every session ends with hip flexor stretching (2 min). Non-negotiable. Weak glutes + tight hip flexors = your current posture issue.")
                    .font(.caption).foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(14)
        .background(AppTheme.accentOrange.opacity(0.08))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppTheme.accentOrange.opacity(0.3), lineWidth: 1))
    }

    private var weeklyScheduleCard: some View {
        SectionCard(title: "Weekly Training Schedule", color: AppTheme.accentBlue) {
            ForEach(CheatsheetData.weeklySchedule) { day in
                HStack(alignment: .top, spacing: 10) {
                    Text(day.day)
                        .font(.caption).bold().frame(width: 34)
                        .foregroundColor(day.intensity == "Zero" ? AppTheme.textMuted : AppTheme.accentBlue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.session).font(.callout).bold()
                        Text("\(day.focus) · \(day.duration)").font(.caption).foregroundColor(AppTheme.textMuted)
                        Text(day.postureWork).font(.caption2).foregroundColor(AppTheme.accentGreen)
                    }
                    Spacer()
                    InfoPill(text: day.intensity, color: intensityColor(day.intensity))
                }
                .padding(.vertical, 4)
                Divider().background(AppTheme.border)
            }
        }
    }

    private func intensityColor(_ i: String) -> Color {
        switch i {
        case "High":     return AppTheme.accent
        case "Moderate": return AppTheme.accentOrange
        case "Low":      return AppTheme.accentGreen
        default:         return AppTheme.textMuted
        }
    }

    private var principlesCard: some View {
        ExpandCard(title: "Key Training Principles", icon: "brain.head.profile", color: AppTheme.accentPurple) {
            VStack(spacing: 8) {
                ForEach(CheatsheetData.principles, id: \.title) { p in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(p.title).font(.callout).bold()
                        Text(p.rule).font(.caption).foregroundColor(AppTheme.textPrimary)
                        Text(p.why).font(.caption).foregroundColor(AppTheme.textMuted).italic()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                    Divider().background(AppTheme.border)
                }
            }
        }
    }

    private var morningMobilityCard: some View {
        ExpandCard(title: "Morning Mobility — 15 min daily", icon: "sun.rise.fill", color: AppTheme.accentGreen) {
            VStack(spacing: 0) {
                Text("Do this EVERY morning before checking your phone.\nFixes pelvic tilt and lordosis. No exceptions.")
                    .font(.caption).foregroundColor(AppTheme.textMuted).padding(.bottom, 8)
                ForEach(CheatsheetData.morningMobility) { ex in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(ex.name).font(.callout).bold()
                            Spacer()
                            Text(ex.setsReps).font(.caption).foregroundColor(AppTheme.accentGreen)
                        }
                        Text("Targets: \(ex.targets)").font(.caption).foregroundColor(AppTheme.textMuted)
                        Text(ex.howTo).font(.caption2).foregroundColor(AppTheme.textMuted).italic()
                    }
                    .padding(.vertical, 6)
                    Divider().background(AppTheme.border)
                }
            }
        }
    }

    private var pullUpProgressionCard: some View {
        ExpandCard(title: "Pull-up Progression Program", icon: "figure.strengthtraining.traditional", color: AppTheme.accentBlue) {
            VStack(spacing: 0) {
                Text("Do pull-ups EVERY training day. Start wherever you are and add 1 rep per set per week. Consistency builds this faster than anything.")
                    .font(.caption).foregroundColor(AppTheme.textMuted).padding(.bottom, 8)
                ForEach(CheatsheetData.pullUpProgression) { w in
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(w.period).font(.caption).bold().foregroundColor(AppTheme.accentBlue)
                            Text("\(w.sets) sets × \(w.repsPerSet)").font(.caption)
                            Text("Rest \(w.rest) · Total \(w.totalReps)").font(.caption2).foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                        Text(w.notes).font(.caption2).foregroundColor(AppTheme.textMuted).multilineTextAlignment(.trailing).frame(maxWidth: 150)
                    }
                    .padding(.vertical, 5)
                    Divider().background(AppTheme.border)
                }
            }
        }
    }

    private var pullUpVariantsCard: some View {
        ExpandCard(title: "Pull-up Variations to Master", icon: "arrow.up.and.down.circle", color: AppTheme.accentPurple) {
            VStack(spacing: 0) {
                ForEach(CheatsheetData.pullUpVariants) { v in
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(v.name).font(.callout).bold()
                            Text(v.grip).font(.caption).foregroundColor(AppTheme.textMuted)
                            Text(v.primaryMuscle).font(.caption2).foregroundColor(AppTheme.accentBlue)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            InfoPill(text: v.difficulty, color: difficultyColor(v.difficulty))
                            Text(v.whenToAdd).font(.caption2).foregroundColor(AppTheme.textMuted)
                        }
                    }
                    .padding(.vertical, 6)
                    Divider().background(AppTheme.border)
                }
            }
        }
    }

    private func difficultyColor(_ d: String) -> Color {
        switch d {
        case "Easier":    return AppTheme.accentGreen
        case "Medium":    return AppTheme.accentBlue
        case "Hard":      return AppTheme.accentOrange
        case "Very Hard": return AppTheme.accent
        default:          return AppTheme.accentPurple
        }
    }
}

// MARK: – Foods Tab

private struct FoodsTab: View {
    var body: some View {
        Group {
            macroTargetCard
            proteinCard
            carbsCard
            fatsCard
            fruitsCard
            veggiesCard
            avoidCard
        }
    }

    private var macroTargetCard: some View {
        SectionCard(title: "Daily Macro Targets", color: AppTheme.textPrimary) {
            HStack(spacing: 0) {
                macroCol(label: "Training Day", cal: "2800-3000", p: "136g", c: "300-350g", f: "70-80g", color: AppTheme.accentBlue)
                Divider().frame(height: 80).background(AppTheme.border)
                macroCol(label: "Rest Day", cal: "2200-2400", p: "136g", c: "200-250g", f: "70-80g", color: AppTheme.accentGreen)
            }
            Text("Protein NEVER drops — 136g every day. Water 3-3.5L every day regardless of training.")
                .font(.caption).foregroundColor(AppTheme.textMuted).padding(.top, 4)
        }
    }

    private func macroCol(label: String, cal: String, p: String, c: String, f: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label).font(.caption2).bold().foregroundColor(color)
            Text(cal).font(.callout).bold()
            Text("kcal").font(.caption2).foregroundColor(AppTheme.textMuted)
            Text("P:\(p) · C:\(c) · F:\(f)").font(.caption2).foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var proteinCard: some View {
        ExpandCard(title: "Eat Freely — Protein Sources", icon: "flame.fill", color: AppTheme.accentGreen) {
            foodList(items: CheatsheetData.proteins, stat1Color: AppTheme.accentGreen)
        }
    }

    private var carbsCard: some View {
        ExpandCard(title: "Eat Freely — Complex Carbohydrates", icon: "bolt.fill", color: AppTheme.accentBlue) {
            foodList(items: CheatsheetData.carbs, stat1Color: AppTheme.accentBlue)
        }
    }

    private var fatsCard: some View {
        ExpandCard(title: "Eat in Moderation — Healthy Fats", icon: "drop.fill", color: AppTheme.accentOrange) {
            foodList(items: CheatsheetData.fats, stat1Color: AppTheme.accentOrange)
        }
    }

    private var fruitsCard: some View {
        ExpandCard(title: "Best Fruits for Hybrid Athlete", icon: "leaf.fill", color: AppTheme.accentGreen) {
            VStack(spacing: 0) {
                ForEach(CheatsheetData.fruits) { f in
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(f.name).font(.callout).bold()
                            Text(f.benefit).font(.caption).foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("C:\(f.carbs) F:\(f.fiber)").font(.caption2).foregroundColor(AppTheme.accentBlue)
                            Text(f.timing).font(.caption2).foregroundColor(AppTheme.accentGreen)
                        }
                    }
                    .padding(.vertical, 5)
                    Divider().background(AppTheme.border)
                }
            }
        }
    }

    private var veggiesCard: some View {
        ExpandCard(title: "Best Vegetables for Hybrid Athlete", icon: "carrot.fill", color: AppTheme.accentGreen) {
            VStack(spacing: 0) {
                ForEach(CheatsheetData.vegetables) { v in
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(v.name).font(.callout).bold()
                            Text(v.benefit).font(.caption).foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(v.fiber).font(.caption2).foregroundColor(AppTheme.accentBlue)
                            Text(v.notes).font(.caption2).foregroundColor(AppTheme.textMuted)
                        }
                    }
                    .padding(.vertical, 5)
                    Divider().background(AppTheme.border)
                }
            }
        }
    }

    private var avoidCard: some View {
        ExpandCard(title: "AVOID — These Hurt Performance", icon: "xmark.shield.fill", color: AppTheme.accent) {
            VStack(spacing: 0) {
                ForEach(CheatsheetData.avoidFoods) { item in
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name).font(.callout).bold()
                            Text(item.reason).font(.caption).foregroundColor(AppTheme.textMuted)
                            Text("Alt: \(item.alternative)").font(.caption2).foregroundColor(AppTheme.accentGreen)
                        }
                        Spacer()
                        InfoPill(text: item.severity, color: item.severityColor)
                    }
                    .padding(.vertical, 6)
                    Divider().background(AppTheme.border)
                }
            }
        }
    }

    private func foodList(items: [CSSFoodRow], stat1Color: Color) -> some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(item.name).font(.callout).bold()
                            Text(item.portion).font(.caption2).foregroundColor(AppTheme.textMuted)
                        }
                        Text(item.notes).font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(item.stat1).font(.caption2).bold().foregroundColor(stat1Color)
                        if !item.stat2.isEmpty {
                            Text(item.stat2).font(.caption2).foregroundColor(AppTheme.textMuted)
                        }
                    }
                }
                .padding(.vertical, 5)
                Divider().background(AppTheme.border)
            }
        }
    }
}

// MARK: – Meals Tab

private struct MealsTab: View {
    @State private var selectedDay = 0

    var body: some View {
        VStack(spacing: 12) {
            dayPicker
            let plan = CheatsheetData.mealPlans[selectedDay]
            dayTotalsCard(plan: plan)
            ForEach(plan.meals) { meal in
                mealCard(meal: meal, color: plan.color)
            }
        }
    }

    private var dayPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CheatsheetData.mealPlans.indices, id: \.self) { i in
                    let plan = CheatsheetData.mealPlans[i]
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) { selectedDay = i }
                    } label: {
                        Text(String(plan.day.prefix(3)))
                            .font(.subheadline).bold()
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(selectedDay == i ? plan.color : AppTheme.cardBackground)
                            .foregroundColor(selectedDay == i ? .white : AppTheme.textMuted)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func dayTotalsCard(plan: CSSDayPlan) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(plan.day).font(.title3).bold()
            Text(plan.subtitle).font(.caption).foregroundColor(AppTheme.textMuted)
            HStack(spacing: 0) {
                totalCol("Calories", plan.totalCal, AppTheme.accentOrange)
                totalCol("Protein",  plan.totalP,   AppTheme.accentGreen)
                totalCol("Carbs",    plan.totalC,   AppTheme.accentBlue)
                totalCol("Fat",      plan.totalF,   AppTheme.accentOrange)
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
        .overlay(HStack { RoundedRectangle(cornerRadius: 4).frame(width: 4).foregroundColor(plan.color); Spacer() })
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func totalCol(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.callout).bold().foregroundColor(color)
            Text(label).font(.caption2).foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private func mealCard(meal: CSSMealRow, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .center, spacing: 1) {
                Text(meal.time).font(.caption2).bold().foregroundColor(color)
                Rectangle().frame(width: 1).foregroundColor(color.opacity(0.3))
            }
            .frame(width: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.label).font(.caption2).bold().foregroundColor(AppTheme.textMuted)
                Text(meal.food).font(.callout)
                Text(meal.portions).font(.caption).foregroundColor(AppTheme.textMuted)
                HStack(spacing: 10) {
                    macroTag("P", meal.protein + "g", AppTheme.accentGreen)
                    macroTag("C", meal.carbs + "g",   AppTheme.accentBlue)
                    macroTag("F", meal.fat + "g",     AppTheme.accentOrange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }

    private func macroTag(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 2) {
            Text(label).font(.caption2).bold().foregroundColor(color)
            Text(value).font(.caption2).foregroundColor(AppTheme.textMuted)
        }
    }
}

// MARK: – Supplements Tab

private struct SuppsTab: View {
    var body: some View {
        Group {
            supplementsCard
            hydrationCard
        }
    }

    private var supplementsCard: some View {
        SectionCard(title: "Supplement Stack — Hybrid Athlete", color: AppTheme.accentPurple) {
            ForEach(CheatsheetData.supplements) { s in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(s.name).font(.callout).bold()
                        Spacer()
                        InfoPill(text: s.priority, color: s.priorityColor)
                    }
                    HStack(spacing: 6) {
                        Text(s.dose).font(.caption).bold().foregroundColor(AppTheme.textPrimary)
                        Text("·").foregroundColor(AppTheme.textMuted)
                        Text(s.timing).font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                    Text(s.why).font(.caption).foregroundColor(AppTheme.textMuted)
                }
                .padding(.vertical, 6)
                Divider().background(AppTheme.border)
            }
        }
    }

    private var hydrationCard: some View {
        SectionCard(title: "Hydration Protocol — 3-3.5L Daily", color: AppTheme.accentBlue) {
            VStack(spacing: 0) {
                ForEach(CheatsheetData.hydration, id: \.timing) { row in
                    HStack(alignment: .top, spacing: 10) {
                        Text(row.timing).font(.caption2).bold().foregroundColor(AppTheme.accentBlue).frame(width: 90, alignment: .leading)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(row.amount).font(.caption).bold()
                            Text(row.note).font(.caption2).foregroundColor(AppTheme.textMuted)
                        }
                    }
                    .padding(.vertical, 5)
                    Divider().background(AppTheme.border)
                }
            }
        }
    }
}

// MARK: – Rules Tab

private struct RulesTab: View {
    var body: some View {
        Group {
            goldenRulesCard
            workoutTimingCard
            carbsRuleCard
        }
    }

    private var goldenRulesCard: some View {
        SectionCard(title: "10 Golden Nutrition Rules", color: AppTheme.accent) {
            ForEach(CheatsheetData.goldenRules) { rule in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(rule.number)")
                        .font(.caption2).bold().frame(width: 22, height: 22)
                        .background(AppTheme.accent.opacity(0.2))
                        .foregroundColor(AppTheme.accent)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(rule.rule).font(.callout).bold()
                        Text(rule.why).font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                }
                .padding(.vertical, 5)
                Divider().background(AppTheme.border)
            }
        }
    }

    private var workoutTimingCard: some View {
        SectionCard(title: "Pre / During / Post Workout Nutrition", color: AppTheme.accentOrange) {
            ForEach(CheatsheetData.workoutTiming) { row in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(row.phase).font(.callout).bold()
                        Spacer()
                        Text(row.timing).font(.caption2).foregroundColor(AppTheme.textMuted)
                    }
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "checkmark.circle.fill").font(.caption2).foregroundColor(AppTheme.accentGreen)
                        Text(row.eat).font(.caption).foregroundColor(AppTheme.textPrimary)
                    }
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "xmark.circle.fill").font(.caption2).foregroundColor(AppTheme.accent)
                        Text(row.avoid).font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                    Text(row.why).font(.caption2).foregroundColor(AppTheme.textMuted).italic()
                }
                .padding(.vertical, 6)
                Divider().background(AppTheme.border)
            }
        }
    }

    private var carbsRuleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Carbs Key Rule").font(.subheadline).bold().foregroundColor(AppTheme.accentBlue)
            carbRuleRow("Simple (fast) carbs", "White rice, banana, honey, dates, sports gel", "Pre/during/post workout, race day", AppTheme.accentBlue)
            carbRuleRow("Complex (slow) carbs", "Oats, sweet potato, whole grain bread, pasta", "Main meals, several hours before training", AppTheme.accentGreen)
            carbRuleRow("Fiber", "Vegetables, oats, apples, beans, chia seeds", "Daily with meals — NOT before training (causes bloating)", AppTheme.accentOrange)
            Text("KEY: Before training/race = SIMPLE carbs. During day = COMPLEX carbs. Separate high-fiber meals from training by 2+ hours.")
                .font(.caption).foregroundColor(AppTheme.textMuted)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(14)
    }

    private func carbRuleRow(_ type: String, _ examples: String, _ timing: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: 2).frame(width: 3).foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(type).font(.caption).bold().foregroundColor(color)
                Text(examples).font(.caption2).foregroundColor(AppTheme.textMuted)
                Text(timing).font(.caption2).foregroundColor(AppTheme.textPrimary)
            }
        }
    }
}
