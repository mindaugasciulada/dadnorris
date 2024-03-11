import SwiftUI
import Combine

private enum Const {
    static let portraitLineLength = 30
    static let landscapeLineLength = 60
}

struct JokeView: View {
    @EnvironmentObject var model: JokesViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var text = ""
    let type: JokeType
    
    var body: some View {
        VStack {
            Text(type.rawValue)
                .font(.title)
            
            Spacer()
            
            jokeText
            
            Spacer()
            
            anotherJokeButton
        }
        .task {
            model.selectedSection = type
            
            switch type {
            case .dadJokes:
                await model.fetchDadJokes()
            case .chuckNorrisJokes:
                await model.fetchChuckJokes()
            }
        }
        .onReceive(model.$currentChuckJoke.combineLatest(model.$currentDadJoke)) { chuckJoke, dadJoke in
            if type == .chuckNorrisJokes, let text = chuckJoke?.value {
                self.text = text
            } else if let text = dadJoke?.joke {
                self.text = text
            }
        }
    }

    private var jokeText: some View {
        ForEach(text.splitIntoChunks(preferredLength: horizontalSizeClass == .compact ? Const.portraitLineLength : Const.landscapeLineLength), id: \.self) { subString in
            HStack(spacing: 0) {
                ForEach(Array(subString.enumerated()), id: \.offset) { index, char in
                    CharView(char: String(char), index: index)
                }
            }
        }
    }
    
    private var anotherJokeButton: some View {
        Button {
            withAnimation {
                model.showAnotherJoke()
            }
        } label: {
            Text("Another one!")
                .foregroundStyle(.white)
                .frame(width: 300, height: 50)
                .background(.blue)
                .cornerRadius(16)
        }
        .padding(.bottom, 50)
    }
}
