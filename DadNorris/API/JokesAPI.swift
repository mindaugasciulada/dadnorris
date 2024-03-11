import Foundation

protocol JokesAPIProtocol {
    func fetchJokes<T: Joke>(type: T.Type, batchSize: Int) async throws -> [T]
}

private enum Endpoint {
    static let dadJokes = "https://icanhazdadjoke.com/"
    static let chuchNorris = "https://api.chucknorris.io/jokes/random/"
}

class JokesAPI: JokesAPIProtocol {
    func fetchJoke<T: Joke>(type: T.Type, endpoint: String) async throws -> T {
        let headers = ["Accept" : "application/json"]
        
        return try await Networking.request(from: endpoint, type: T.self, headers: headers)
    }
    
    func fetchJokes<T: Joke>(type: T.Type, batchSize: Int) async throws -> [T] {
        let urlString = T.self == DadJoke.self ? Endpoint.dadJokes : Endpoint.chuchNorris
        
        return try await withThrowingTaskGroup(of: T.self) { group in
            var jokes: [T] = []
            
            for _ in 0 ..< batchSize {
                group.addTask {
                    try await self.fetchJoke(type: type, endpoint: urlString)
                }
            }
            
            for try await joke in group {
                jokes.append(joke)
            }
            
            return jokes
        }
    }
}
