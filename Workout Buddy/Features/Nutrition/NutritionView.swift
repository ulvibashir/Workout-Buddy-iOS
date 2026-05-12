import SwiftUI

struct NutritionView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        _NutritionView(vm: NutritionViewModel(container: container))
    }
}

private struct _NutritionView: View {
    @StateObject var vm: NutritionViewModel
    @State private var showFoodPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    trainingToggle
                    macroRingsSection
                    waterSection
                    foodLogSection
                    supplementsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.large)
            .background(AppTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFoodPicker = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppTheme.accentGreen)
                    }
                }
            }
            .sheet(isPresented: $showFoodPicker) {
                FoodPickerView(foodDatabase: vm.foodDatabase) { food, servings in
                    vm.addFood(food, servings: servings)
                }
            }
        }
        .onAppear  { vm.start() }
        .onDisappear { vm.stop() }
    }

    // MARK: - Training day toggle
    private var trainingToggle: some View {
        HStack {
            Text("Day type:").font(.subheadline).foregroundColor(AppTheme.textMuted)
            Spacer()
            Picker("", selection: $vm.isTrainingDay) {
                Text("Training").tag(true)
                Text("Rest").tag(false)
            }
            .pickerStyle(.segmented)
            .frame(width: 180)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Macro rings
    private var macroRingsSection: some View {
        VStack(spacing: 12) {
            // Calories headline
            HStack {
                VStack(alignment: .leading) {
                    Text("Calories").font(.caption).foregroundColor(AppTheme.textMuted)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(vm.totalCalories))").font(.title).bold()
                        Text("/ \(vm.activeTargets.calories)").font(.subheadline).foregroundColor(AppTheme.textMuted)
                        Text("kcal").font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                }
                Spacer()
                CircularProgress(
                    progress: min(1, vm.totalCalories / Double(vm.activeTargets.calories)),
                    color: AppTheme.accentOrange, size: 52
                )
            }
            .padding(14)
            .background(AppTheme.cardBackground)
            .cornerRadius(12)

            // Macro breakdown
            HStack(spacing: 8) {
                MacroCell(label: "Protein",  value: vm.totalProtein, target: Double(vm.activeTargets.protein),  unit: "g", color: AppTheme.accent)
                MacroCell(label: "Carbs",    value: vm.totalCarbs,   target: Double(vm.activeTargets.carbs),    unit: "g", color: AppTheme.accentBlue)
                MacroCell(label: "Fats",     value: vm.totalFats,    target: Double(vm.activeTargets.fat),      unit: "g", color: AppTheme.accentOrange)
            }
        }
    }

    // MARK: - Water tracker
    private var waterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Water", systemImage: "drop.fill")
                    .font(.subheadline).bold()
                    .foregroundColor(AppTheme.accentBlue)
                Spacer()
                Text("\(vm.log.water) ml").font(.callout).foregroundColor(AppTheme.textMuted)
            }
            HStack(spacing: 8) {
                ForEach(0..<8, id: \.self) { i in
                    let filled = Double(vm.log.water) / 250 > Double(i)
                    Image(systemName: "drop.fill")
                        .foregroundColor(filled ? AppTheme.accentBlue : AppTheme.border)
                        .font(.title3)
                        .onTapGesture { vm.addWater(ml: 250) }
                }
                Spacer()
                Button { vm.removeWater(ml: 250) } label: {
                    Image(systemName: "minus.circle").foregroundColor(AppTheme.textMuted)
                }
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Food log
    private var foodLogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today's Food").font(.subheadline).bold()
                Spacer()
                Button {
                    showFoodPicker = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppTheme.accentGreen)
                }
            }
            if vm.log.foods.isEmpty {
                Text("No food logged yet")
                    .font(.caption).foregroundColor(AppTheme.textMuted)
                    .padding(.vertical, 8)
            } else {
                ForEach(vm.log.foods) { food in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(food.name).font(.callout).bold()
                            Text("\(Int(food.weight))g · P:\(Int(food.protein)) C:\(Int(food.carbs)) F:\(Int(food.fats))")
                                .font(.caption).foregroundColor(AppTheme.textMuted)
                        }
                        Spacer()
                        Text("\(Int(food.calories)) kcal").font(.callout).foregroundColor(AppTheme.accentOrange)
                    }
                    .padding(.vertical, 6)
                    Divider().background(AppTheme.border)
                }
                .onDelete(perform: vm.removeFood)
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Supplements
    private var supplementsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Supplements").font(.subheadline).bold()
            if vm.supplements.isEmpty {
                Text("Loading…").font(.caption).foregroundColor(AppTheme.textMuted)
            } else {
                ForEach(vm.supplements) { sup in
                    let taken = vm.log.supplements.contains(sup.name)
                    Button {
                        vm.toggleSupplement(sup.name)
                    } label: {
                        HStack {
                            Image(systemName: taken ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(taken ? AppTheme.accentGreen : AppTheme.border)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(sup.name).font(.callout)
                                Text("\(sup.dose) · \(sup.timing)").font(.caption).foregroundColor(AppTheme.textMuted)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    Divider().background(AppTheme.border)
                }
            }
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Macro cell
private struct MacroCell: View {
    let label: String; let value: Double; let target: Double; let unit: String; let color: Color

    var body: some View {
        VStack(spacing: 6) {
            CircularProgress(progress: min(1, target > 0 ? value / target : 0), color: color, size: 44)
            Text("\(Int(value))").font(.callout).bold()
            Text("/ \(Int(target))\(unit)").font(.caption2).foregroundColor(AppTheme.textMuted)
            Text(label).font(.caption2).foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Circular progress ring
struct CircularProgress: View {
    let progress: Double
    let color:    Color
    let size:     CGFloat

    var body: some View {
        ZStack {
            Circle().stroke(AppTheme.border, lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progress)
        }
        .frame(width: size, height: size)
    }
}
