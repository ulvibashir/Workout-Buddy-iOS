import SwiftUI

struct NutritionView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var vm: NutritionViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm {
                    loadedContent(vm: vm)
                } else {
                    nutritionSkeleton
                }
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.large)
            .background(Color.appBackground.ignoresSafeArea())
        }
        .task {
            guard vm == nil, let uid = authViewModel.currentUID else { return }
            let m = NutritionViewModel(uid: uid)
            vm = m
            await m.loadData()
        }
    }

    // MARK: - Skeleton

    private var nutritionSkeleton: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                SkeletonView().frame(height: 40)
                SkeletonView().frame(height: 100)
                SkeletonView().frame(height: 60)
                SkeletonView().frame(height: 60)
                SkeletonView().frame(height: 60)
                SkeletonView().frame(height: 120)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Loaded content

    @ViewBuilder
    private func loadedContent(vm: NutritionViewModel) -> some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                dayTypeHeader(vm: vm)
                macroTargetsCard(vm: vm)
                mealPlanSection(vm: vm)
                foodGuideSection(vm: vm)
                supplementsSection(vm: vm)
                cheatDayCard(vm: vm)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.xxxl)
        }
    }

    // MARK: - Day Type Header

    private func dayTypeHeader(vm: NutritionViewModel) -> some View {
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

    private func macroTargetsCard(vm: NutritionViewModel) -> some View {
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

    private func mealPlanSection(vm: NutritionViewModel) -> some View {
        VStack(spacing: Spacing.xs) {
            SectionHeader(title: "Daily Meal Plan")
            ForEach(vm.todayMeals) { meal in
                MealCardView(meal: meal, isExpanded: vm.expandedMeal == meal.id) {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        vm.expandedMeal = vm.expandedMeal == meal.id ? nil : meal.id
                    }
                }
            }
        }
    }

    // MARK: - Food Guide Section

    private func foodGuideSection(vm: NutritionViewModel) -> some View {
        VStack(spacing: Spacing.xs) {
            SectionHeader(title: "Food Guide")
            ExpandableFoodSection(header: "✅ Eat Freely",        color: .appSuccess, items: vm.eatFreelyFoods)
            ExpandableFoodSection(header: "⚠️ Eat in Moderation", color: .appWarning, items: vm.eatInModerationFoods)
            ExpandableFoodSection(header: "❌ Avoid",             color: .appDanger,  items: vm.avoidFoods)
        }
    }

    // MARK: - Supplements Section

    private func supplementsSection(vm: NutritionViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title: "Daily Stack")
            ForEach(vm.supplements) { supplement in
                HStack(spacing: Spacing.md) {
                    Text(supplement.emoji).font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(supplement.name)
                            .font(.appSubheadline)
                            .foregroundStyle(Color.appTextPrimary)
                        Text("\(supplement.dose) — \(supplement.timing)")
                            .font(.appCaption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Spacer()
                }
                .padding(.vertical, Spacing.xs)
                if supplement.id != vm.supplements.last?.id {
                    Divider()
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg))
    }

    // MARK: - Cheat Day Card

    private func cheatDayCard(vm: NutritionViewModel) -> some View {
        let rules = vm.cheatDayRules.isEmpty ? [
            "Stay within reason — don't binge",
            "Avoid alcohol — hurts recovery",
            "Enjoy your meal, restart Monday",
            "Suggested: Plov, shawarma, dessert 🍖",
        ] : vm.cheatDayRules

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("🎉 Cheat Day — Sunday")
                .font(.appHeadline)
                .foregroundStyle(Color.appTextPrimary)
            Text("You've earned it. Here are the rules:")
                .font(.appSubheadline)
                .foregroundStyle(Color.appTextSecondary)
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
    let meal: NutritionMeal
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
    let items: [GuideFoodItem]
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
                    ForEach(items, id: \.name) { item in
                        HStack {
                            Text(item.name).font(.appSubheadline).foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Text(item.stat).font(.appCaption).foregroundStyle(Color.appTextSecondary)
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
