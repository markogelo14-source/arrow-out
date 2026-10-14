import SwiftUI

@main
struct ArrowlyApp: App {
    @State private var progress = PlayerProgress()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(progress)
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @State private var path: [GameMode] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: GameMode.self) { mode in
                    GameView(mode: mode)
                }
        }
        .tint(Theme.indigo)
    }
}
