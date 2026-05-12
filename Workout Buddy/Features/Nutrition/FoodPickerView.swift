import SwiftUI

struct FoodPickerView: View {
    let foodDatabase: [FoodItem]
    let onAdd: (FoodItem, Double) -> Void   // (food, servings)

    @Environment(\.dismiss) private var dismiss
    @State private var searchText    = ""
    @State private var selectedFood: FoodItem?
    @State private var servings:     Double = 1.0

    private var filtered: [FoodItem] {
        searchText.isEmpty
            ? foodDatabase
            : foodDatabase.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let food = selectedFood {
                    portionView(food)
                } else {
                    searchList
                }
            }
            .navigationTitle(selectedFood == nil ? "Add Food" : selectedFood!.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(selectedFood == nil ? "Cancel" : "Back") {
                        if selectedFood != nil { selectedFood = nil } else { dismiss() }
                    }
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    // MARK: - Search list
    private var searchList: some View {
        List(filtered) { food in
            Button {
                servings     = 1.0
                selectedFood = food
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(food.name)
                            .font(.callout).foregroundColor(AppTheme.textPrimary)
                        Text("Per \(food.unit): \(Int(food.calories)) kcal · P:\(Int(food.protein))g")
                            .font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                    Spacer()
                    Text(food.unit)
                        .font(.caption).foregroundColor(AppTheme.textMuted)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search food…")
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .listStyle(.insetGrouped)
    }

    // MARK: - Portion selector
    private func portionView(_ food: FoodItem) -> some View {
        let preview = food.loggedFood(servings: servings)
        return ScrollView {
            VStack(spacing: 16) {
                // Serving adjuster
                VStack(spacing: 8) {
                    HStack {
                        Text("Servings (\(food.unit))").font(.subheadline).foregroundColor(AppTheme.textMuted)
                        Spacer()
                        Text(String(format: "%.1f", servings)).font(.title3).bold()
                    }
                    Slider(value: $servings, in: 0.25...10, step: 0.25).tint(AppTheme.accentGreen)
                    HStack {
                        Button("-½") { servings = max(0.25, servings - 0.5) }
                        Spacer()
                        Button("+½") { servings = min(10, servings + 0.5) }
                    }
                    .font(.caption).foregroundColor(AppTheme.accentGreen)
                }
                .padding(14)
                .background(AppTheme.cardBackground)
                .cornerRadius(12)

                // Macro preview
                VStack(spacing: 8) {
                    Text("Nutritional Preview").font(.subheadline).bold()
                    HStack(spacing: 0) {
                        MacroPreview(label: "Calories", value: "\(Int(preview.calories))", unit: "kcal", color: AppTheme.accentOrange)
                        Divider().frame(height: 40)
                        MacroPreview(label: "Protein",  value: "\(Int(preview.protein))",  unit: "g",    color: AppTheme.accent)
                        Divider().frame(height: 40)
                        MacroPreview(label: "Carbs",    value: "\(Int(preview.carbs))",    unit: "g",    color: AppTheme.accentBlue)
                        Divider().frame(height: 40)
                        MacroPreview(label: "Fats",     value: "\(Int(preview.fats))",     unit: "g",    color: AppTheme.accentOrange)
                    }
                }
                .padding(14)
                .background(AppTheme.cardBackground)
                .cornerRadius(12)

                Button {
                    onAdd(food, servings)
                    dismiss()
                } label: {
                    Text("Add \(food.name)")
                        .font(.subheadline).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accentGreen)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}

private struct MacroPreview: View {
    let label: String; let value: String; let unit: String; let color: Color
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.title3).bold().foregroundColor(color)
            Text(unit).font(.caption2).foregroundColor(AppTheme.textMuted)
            Text(label).font(.caption2).foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}
