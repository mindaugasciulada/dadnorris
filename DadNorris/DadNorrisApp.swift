import SwiftUI
import Swinject

@main
struct DadNorrisApp: App {
    let container = Container.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(container.resolve(JokesViewModel.self)!)
        }
    }
}
