import Foundation

struct ChuckJoke: Joke {
    let iconURL: String
    let id: String
    let url: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case iconURL = "icon_url"
        case id, url, value
    }
}
