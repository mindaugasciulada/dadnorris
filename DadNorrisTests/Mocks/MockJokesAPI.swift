import Foundation
@testable import DadNorris

class MockJokesAPI: JokesAPIProtocol {
    @Published var fetchDadJokesCalled = false
    @Published var fetchChuckJokesCalled = false
    var chuckJokes: [ChuckJoke] = chuckJokesSampleData
    var dadJokes: [DadJoke] = dadJokesSampleData
    var shouldThrowError = false
    
    deinit {
        print("### deinit")
    }
    
    func fetchJokes<T: Joke>(type: T.Type, batchSize: Int) async throws -> [T] {
        if shouldThrowError {
            throw URLError(.badURL)
        }
        
        if type == DadJoke.self {
            fetchDadJokesCalled = true
            
            return dadJokes as! [T]
        } else if type == ChuckJoke.self {
            fetchChuckJokesCalled = true
            
            return chuckJokes as! [T]
        } else {
            return []
        }
    }
}

extension MockJokesAPI {
    static let dadJokesSampleData: [DadJoke] = [
        DadJoke(id: "234234", joke: "Every morning when I go out, I get hit by bicycle. Every morning! It's a vicious cycle.", status: 190),
        DadJoke(id: "1234", joke: "Do I enjoy making courthouse puns? Guilty. Every morning! It's a vicious cycle.", status: 12311),
        DadJoke(id: "123", joke: "Did you hear about the runner who was criticized? He just took it in stride", status: 69),
        DadJoke(id: "1234", joke: "Do I enjoy making courthouse puns? Guilty", status: 11)
    ]
    
    static let chuckJokesSampleData: [ChuckJoke] = [
        ChuckJoke(iconURL: "https://assets.chucknorris.host/img/avatar/chuck-norris.png", id: "bqWRFK5wQmmaGgnaCrV9lg", url: "1112", value: "Chuck Norris once gave his grandma a ball of steal wool and she knitted him a bmx.."),
        ChuckJoke(iconURL: "https://assets.chucknorris.host/img/avatar/chuck-norris.png", id: "Afdse5wQmmaGgnaCrV9lg", url: "3123", value: "Chuck Norris once gave his restaurant always serves him armadillo on the half him a bmx.."),
        ChuckJoke(iconURL: "https://assets.chucknorris.host/img/avatar/chuck-norris.png", id: "bqWasdDSWmmaGgnaCrV9lg", url: "45232", value: "Chuck Norris' favorite seafood restaurant always serves him armadillo on the half shell."),
        ChuckJoke(iconURL: "https://assets.chucknorris.host/img/avatar/chuck-norris.png", id: "Afdse5wQmmaGgnaCrV9lg", url: "3123", value: "Chuck Norris once gave his grandma a ball of steal wool and she knitted him a bmx..")
    ]
}
