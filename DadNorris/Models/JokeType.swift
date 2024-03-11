import SwiftUI

enum JokeType: String, CaseIterable, Identifiable {
    var id: String {
        return self.rawValue
    }

    case dadJokes = "Dad Jokes"
    case chuckNorrisJokes = "Chuck Norris Jokes"
    
    var logo: Image {
        switch self {
        case .dadJokes:
            return Image(.dadJoke)
        case .chuckNorrisJokes:
            return Image(.chucknorris)
        }
    }
}
