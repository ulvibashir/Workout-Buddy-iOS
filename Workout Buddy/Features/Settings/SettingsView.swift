import SwiftUI
import Combine

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(SyncEngine.self) private var syncEngine
    @State private var vm: SettingsViewModel?
    @State private var showEditProfile = false
    @AppStorage("colorSchemePreference") private var colorSchemeRaw: String = "System"

    var body: some View {
        NavigationStack {
            if let vm {
                List {
                    profileSection(vm: vm)
                    healthSection(vm: vm)
                    appearanceSection(vm: vm)
                    accountSection(vm: vm)
                    aboutSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.appBackground.ignoresSafeArea())
                .tint(Color.appPrimary)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $showEditProfile) {
                    EditProfileSheet(profile: vm.profile) { updated in
                        Task { await vm.saveProfile(updated) }
                    }
                }
                .alert("Sign Out?", isPresented: Binding(
                    get: { vm.showSignOutAlert },
                    set: { vm.showSignOutAlert = $0 }
                )) {
                    Button("Sign Out", role: .destructive) { authViewModel.signOut() }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("You will need to sign in again to access your data.")
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.appBackground)
            }
        }
        .onAppear {
            if let uid = authViewModel.currentUID, vm == nil {
                vm = SettingsViewModel(uid: uid)
                Task { await vm?.loadProfile() }
            }
        }
    }

    // MARK: - Profile Section

    @ViewBuilder
    private func profileSection(vm: SettingsViewModel) -> some View {
        Section("Profile") {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary)
                        .frame(width: 48, height: 48)
                    Text(String(vm.profile.name.prefix(1)))
                        .font(.appTitle3)
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.profile.name)
                        .font(.appHeadline)
                        .foregroundStyle(Color.appTextPrimary)
                    if let w = vm.healthWeight {
                        Text(String(format: "%.1f kg · from Health", w))
                            .font(.appCaption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            Button {
                showEditProfile = true
            } label: {
                Text("Edit Profile")
                    .foregroundStyle(Color.appPrimary)
            }
        }
    }

    // MARK: - Health Section

    @ViewBuilder
    private func healthSection(vm: SettingsViewModel) -> some View {
        Section("Health") {
            HStack {
                Label("HealthKit Status", systemImage: "heart.fill")
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.appSuccess)
                        .frame(width: 8, height: 8)
                    Text("Connected")
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            HStack {
                Text("Last synced")
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                if let lastSync = vm.lastSyncDate {
                    Text(lastSync.formatted(.relative(presentation: .named)))
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                } else {
                    Text("Never")
                        .font(.appCaption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Button {
                Task { await vm.syncNow(syncEngine: syncEngine) }
            } label: {
                HStack(spacing: Spacing.xs) {
                    if vm.isSyncing {
                        ProgressView().scaleEffect(0.8).tint(Color.appPrimary)
                    }
                    Text(vm.isSyncing ? "Syncing…" : "Sync Now")
                        .foregroundStyle(Color.appPrimary)
                }
            }
            .disabled(vm.isSyncing)
        }
    }

    // MARK: - Appearance Section

    @ViewBuilder
    private func appearanceSection(vm: SettingsViewModel) -> some View {
        Section("Appearance") {
            Picker("Color Scheme", selection: $colorSchemeRaw) {
                Text("System").tag("System")
                Text("Light").tag("Light")
                Text("Dark").tag("Dark")
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Account Section

    @ViewBuilder
    private func accountSection(vm: SettingsViewModel) -> some View {
        Section("Account") {
            HStack {
                Label("Firebase", systemImage: "icloud.fill")
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                HStack(spacing: 4) {
                    Circle().fill(Color.appSuccess).frame(width: 8, height: 8)
                    Text("Connected").font(.appCaption).foregroundStyle(Color.appTextSecondary)
                }
            }

            Button("Sign Out") {
                vm.showSignOutAlert = true
            }
            .foregroundStyle(Color.appDanger)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("App Version")
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(Color.appTextSecondary)
            }
            HStack {
                Text("Bundle ID")
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("com.ulvi.workoutbuddy")
                    .font(.appCaption)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    let profile: UserProfile
    let onSave: (UserProfile) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name: String

    init(profile: UserProfile, onSave: @escaping (UserProfile) -> Void) {
        self.profile = profile
        self.onSave = onSave
        _name = State(initialValue: profile.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Name", text: $name)
                }
                Section {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                        Text("Weight is read automatically from Apple Health")
                            .font(.appCaption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = profile
                        updated.name = name.isEmpty ? profile.name : name
                        onSave(updated)
                        dismiss()
                    }
                }
            }
        }
    }
}
