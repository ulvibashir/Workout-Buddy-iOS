import SwiftUI

struct NutritionView: View {
    @State private var vm = NutritionViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.md) {
                    dayTypeHeader
                    macroTargetsCard
                    mealPlanSection
                    foodGuideSection
                    supplementsSection
                    cheatDayCard
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.xxxl)
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.appBackground.ignoresSafeArea())
        }
    }

    // MARK: - Day Type Header

    private var dayTypeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Plan")
                    .font(.appTitle3)
                    .foregroundStyle(Color.appTextPrimary)
                Label(
                    vm.isTrainingDay ? "Training Day 🔥" : "Rest Day 💤",
                    systemImage: vm.isTrainingDay ? "flame.fill" : "moon.fill"
                )
                .font(.appSubheadline)
                .foregroundStyle(vm.isTrainingDay ? Color.appPrimary : Color.appTextSecondary)
            }
            Spacer()
        }
    }

    // MARK: - Macro Targets Card

    private var macroTargetsCard: some View {
        let t = vm.todayTargets
        return VStack(spacing: Spacing.md) {
            HStack(spacing: 0) {
                macroColumn("Protein", "\(t.protein)g", .appInfo)
                Divider().frame(height: 50)
                macroColumn("Carbs", "\(t.carbs)g", .appPrimary)
                Divider().frame(height: 50)
                macroColumn("Fat", "\(t.fat)g", .appWarning)
            }
            Text("Calories: ~\(t.calories) kcal  |  Water: \(t.water, specifier: "%.1f")L")
                .font(.appCaption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    private func macroColumn(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: Spacing.xxs) {
            Text(value)
                .font(.appMetricSmall)
                .foregroundStyle(color)
            Text(label)
                .font(.appCaption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Meal Plan Section

    private var mealPlanSection: some View {
        VStack(spacing: Spacing.xs) {
            SectionHeader(title: "Daily Meal Plan")
            ForEach(vm.meals) { meal in
                MealCardView(meal: meal, isExpanded: vm.expandedMeal == meal.id) {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        vm.expandedMeal = vm.expandedMeal == meal.id ? nil : meal.id
                    }
                }
            }
        }
    }

    // MARK: - Food Guide Section

    private var foodGuideSection: some View {
        VStack(spacing: Spacing.xs) {
            SectionHeader(title: "Food Guide")
            ExpandableFoodSection(
                header: "✅ Eat Freely",
                color: .appSuccess,
                items: vm.eatFreelyFoods
            )
            ExpandableFoodSection(
                header: "⚠️ Eat in Moderation",
                color: .appWarning,
                items: vm.eatInModerationFoods
            )
            ExpandableFoodSection(
                header: "❌ Avoid",
                color: .appDanger,
                items: vm.avoidFoods
            )
        }
    }

    // MARK: - Supplements Section

    private var supplementsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title: "Daily Stack")
            ForEach(vm.supplements, id: \.1) { emoji, name, dose, timing in
                HStack(spacing: Spacing.md) {
                    Text(emoji).font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name)
                            .font(.appSubheadline)
                            .foregroundStyle(Color.appTextPrimary)
                        Text("\(dose) — \(timing)")
                            .font(.appCaption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Spacer()
                }
                .padding(.vertical, Spacing.xs)
                if name != vm.supplements.last?.1 {
                    Divider()
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    // MARK: - Cheat Day Card

    private var cheatDayCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("🎉 Cheat Day — Sunday").font(.appHeadline).foregroundStyle(Color.appTextPrimary)
            }
            Text("You've earned it. Here are the rules:")
                .font(.appSubheadline)
                .foregroundStyle(Color.appTextSecondary)
            let rules = [
                "Stay within reason — don't binge",
                "Avoid alcohol — hurts recovery",
                "Enjoy your meal, restart Monday",
                "Suggested: Plov, shawarma, dessert 🍖",
            ]
            ForEach(rules, id: \.self) { rule in
                HStack(alignment: .top, spacing: Spacing.xs) {
                    Text("•").foregroundStyle(Color.appPrimary)
                    Text(rule).font(.appSubheadline).foregroundStyle(Color.appTextPrimary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.lg)
                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Meal Card

private struct MealCardView: View {
    let meal: NutritionViewModel.MealPlan
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text(meal.emoji).font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(meal.name).font(.appHeadline).foregroundStyle(Color.appTextPrimary)
                        Text(meal.time).font(.appCaption).foregroundStyle(Color.appTextSecondary)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(Spacing.md)
            }

            if isExpanded {
                Divider().padding(.horizontal, Spacing.md)
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(meal.foods)
                        .font(.appSubheadline)
                        .foregroundStyle(Color.appTextPrimary)
                    HStack(spacing: Spacing.md) {
                        macroChip("P", "\(meal.protein)g", .appInfo)
                        macroChip("C", "\(meal.carbs)g", .appPrimary)
                        macroChip("F", "\(meal.fat)g", .appWarning)
                    }
                }
                .padding(Spacing.md)
            }
        }
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    private func macroChip(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 2) {
            Text(label).font(.appCaption).fontWeight(.semibold).foregroundStyle(color)
            Text(value).font(.appCaption).foregroundStyle(Color.appTextSecondary)
        }
    }
}

// MARK: - Expandable Food Section

private struct ExpandableFoodSection: View {
    let header: String
    let color: Color
    let items: [(String, String)]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Text(header).font(.appHeadline).foregroundStyle(color)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(Spacing.md)
            }

            if isExpanded {
                Divider().padding(.horizontal, Spacing.md)
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    ForEach(items, id: \.0) { name, stat in
                        HStack {
                            Text(name).font(.appSubheadline).foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Text(stat).font(.appCaption).foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(Spacing.md)
            }
        }
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }
}
