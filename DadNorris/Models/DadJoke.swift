import Foundation

protocol Joke: Codable, Equatable {}

struct DadJoke: Joke {
    let id: String
    let joke: String
    let status: Int
}
