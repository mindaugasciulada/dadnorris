import Foundation

class JokesViewModel: ObservableObject {
    private enum Const {
        static let minimumAvailableJokesCount = 2
        static let jokesFetchBatchCount = 5
    }
    
    enum FetchState: Equatable {
        case idle
        case fetching
        case failure(String)
    }
    
    @Published private(set) var dadJokesFetchState: FetchState = .idle
    @Published private(set) var chuckJokesFetchState: FetchState = .idle
    
    @Published var currentDadJoke: DadJoke?
    @Published var currentChuckJoke: ChuckJoke?
    
    var dadJokes: [DadJoke] = []
    var chuckJokes: [ChuckJoke] = []
    var selectedSection: JokeType?
    let jokeAPI: JokesAPIProtocol
    
    init(jokeAPI: JokesAPIProtocol) {
        self.jokeAPI = jokeAPI
    }
    
    @MainActor
    func fetchDadJokes() async {
        guard dadJokesFetchState != .fetching else { return }
        
        dadJokesFetchState = .fetching
        
        do {
            let dadJokes = try await jokeAPI.fetchJokes(type: DadJoke.self, batchSize: Const.jokesFetchBatchCount)
            
            self.dadJokes.append(contentsOf: dadJokes)
            if self.currentDadJoke == nil {
                currentDadJoke = dadJokes.randomElement()
            }
            
            dadJokesFetchState = .idle
        } catch {
            dadJokesFetchState = .failure(error.localizedDescription)
            print("Unable to fetch dadJokes \(error.localizedDescription)")
        }
    }
    
    func showAnotherJoke() {
        switch selectedSection {
        case .dadJokes:
            removeSeenJoke(oldJoke: currentDadJoke)
            currentDadJoke = dadJokes.randomElement()
        case .chuckNorrisJokes:
            removeSeenJoke(oldJoke: currentChuckJoke)
            currentChuckJoke = chuckJokes.randomElement()
        case nil:
            break
        }
        
        fetchMoreJokesIfNeeded()
    }
    
    @MainActor
    func fetchChuckJokes() async {
        guard chuckJokesFetchState != .fetching else { return }

        chuckJokesFetchState = .fetching

        do {
            let chuckJokes = try await jokeAPI.fetchJokes(type: ChuckJoke.self, batchSize: Const.jokesFetchBatchCount)
            
            self.chuckJokes.append(contentsOf: chuckJokes)
            if self.currentChuckJoke == nil {
                currentChuckJoke = chuckJokes.randomElement()
            }
            chuckJokesFetchState = .idle
        } catch {
            chuckJokesFetchState = .failure(error.localizedDescription)
            print("Unable to fetch Chuck Jokes \(error.localizedDescription)")
        }
    }
    
    private func removeSeenJoke(oldJoke: DadJoke?) {
        if let oldJoke, let index = dadJokes.firstIndex(of: oldJoke) {
            dadJokes.remove(at: index)
        }
    }
    
    private func removeSeenJoke(oldJoke: ChuckJoke?) {
        if let oldJoke, let index = chuckJokes.firstIndex(of: oldJoke) {
            chuckJokes.remove(at: index)
        }
    }
    
    private func fetchMoreJokesIfNeeded() {
        if dadJokes.count <= Const.minimumAvailableJokesCount {
            Task {
                await fetchDadJokes()
            }
        }
        
        if chuckJokes.count <= Const.minimumAvailableJokesCount {
            Task {
                await fetchChuckJokes()
            }
        }
    }
}
