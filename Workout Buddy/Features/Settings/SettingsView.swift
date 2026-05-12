import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        _SettingsView(vm: SettingsViewModel(container: container))
    }
}

private struct _SettingsView: View {
    @StateObject var vm: SettingsViewModel
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        NavigationStack {
            Form {
                // Profile section
                Section("Profile") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Ulvi", text: $vm.profile.name)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("68", value: $vm.profile.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("23", value: $vm.profile.age, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    HStack {
                        Text("City")
                        Spacer()
                        TextField("Baku", text: $vm.profile.city)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(AppTheme.textMuted)
                    }
                    Button("Save Profile") {
                        vm.saveProfile()
                    }
                    .foregroundColor(AppTheme.accentGreen)
                }

                // HealthKit section
                Section("Apple Health") {
                    HStack {
                        Image(systemName: "heart.fill").foregroundColor(AppTheme.accent)
                        Text("HealthKit Status")
                        Spacer()
                        Text(container.healthKitService.isAuthorized ? "Connected" : "Not Connected")
                            .font(.caption)
                            .foregroundColor(container.healthKitService.isAuthorized ? AppTheme.accentGreen : AppTheme.textMuted)
                    }
                    Button {
                        vm.syncHealthKit()
                    } label: {
                        HStack {
                            if vm.isSyncing {
                                ProgressView().scaleEffect(0.8)
                            }
                            Text(vm.isSyncing ? "Syncing…" : "Sync Latest from Apple Health")
                        }
                    }
                    .foregroundColor(AppTheme.accentBlue)
                    .disabled(vm.isSyncing)
                }

                // App info
                Section("About") {
                    HStack {
                        Text("App")
                        Spacer()
                        Text("Workout Buddy").foregroundColor(AppTheme.textMuted)
                    }
                    HStack {
                        Text("Athlete")
                        Spacer()
                        Text(vm.profile.name).foregroundColor(AppTheme.textMuted)
                    }
                    HStack {
                        Text("Firebase Project")
                        Spacer()
                        Text("workout-buddy-a5d78").font(.caption).foregroundColor(AppTheme.textMuted)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear  { vm.start() }
        .onDisappear { vm.stop() }
        .alert("Sync Complete", isPresented: .constant(vm.syncMessage != nil)) {
            Button("OK") { vm.syncMessage = nil }
        } message: {
            Text(vm.syncMessage ?? "")
        }
    }
}
