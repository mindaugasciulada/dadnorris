import Foundation
import Swinject
import SwiftUI

extension Container {
    static let shared = Container() { container in
        container.register(JokesAPIProtocol.self) { _ in JokesAPI() }
        container.register(JokesViewModel.self) { r in
            JokesViewModel(jokeAPI: r.resolve(JokesAPIProtocol.self)!)
        }
    }
}

private struct SwinjectContainerKey: EnvironmentKey {
    static let defaultValue: Container = .shared
}

extension EnvironmentValues {
    var container: Container {
        get { self[SwinjectContainerKey.self] }
        set { self[SwinjectContainerKey.self] = newValue }
    }
}
