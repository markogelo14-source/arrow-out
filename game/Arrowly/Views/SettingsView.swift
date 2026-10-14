import SwiftUI

struct SettingsView: View {
    @Environment(PlayerProgress.self) private var progress
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false

    var body: some View {
        @Bindable var progress = progress

        NavigationStack {
            Form {
                Section {
                    Toggle("Haptics", isOn: $progress.hapticsEnabled)
                }

                Section("How to play") {
                    Text("Tap an arrow to slide it off the board in the direction it points. If another arrow is in the way, it bounces back and you lose a heart. Clear every arrow to win. You have 3 hearts and 3 hints per board.")
                        .font(.callout)
                }

                Section("Privacy") {
                    Text("Arrowly does not collect any data. Your progress is stored only on this device.")
                        .font(.callout)
                    Link("Privacy Policy", destination: AppLinks.privacyPolicy)
                    Link("Terms of Use", destination: AppLinks.terms)
                    Link("Support", destination: AppLinks.support)
                }

                Section {
                    Button("Reset progress", role: .destructive) {
                        confirmReset = true
                    }
                } footer: {
                    Text("Arrowly \(appVersion)")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Reset all progress?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset progress", role: .destructive) { progress.reset() }
            } message: {
                Text("You will start again from level 1 and your daily streak will be cleared.")
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
