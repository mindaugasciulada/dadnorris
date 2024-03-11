import SwiftUI
import CoreData
import Swinject

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var model: JokesViewModel
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    Text("Choose joke type!")
                        .font(.title)
                    
                    jokeTypes
                }
            }
            
            errorInfo
        }
        .preferredColorScheme(.dark)
        .onReceive(model.$chuckJokesFetchState.combineLatest(model.$dadJokesFetchState)) { chuckFetchState, dadFetchState in
            if case .failure(let error) = dadFetchState {
                errorMessage = error
            }
            
            if case .failure(let error) = chuckFetchState {
                errorMessage = error
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                errorMessage = nil
            }
        }
    }
    
    private var jokeTypes: some View {
        ForEach(JokeType.allCases) { jokeType in
            NavigationLink {
                JokeView(type: jokeType)
            } label: {
                navigationLinkLabel(for: jokeType)
            }
        }
    }
    
    private var errorInfo: some View {
        VStack {
            if let errorMessage {
                Text(errorMessage)
                    .padding()
                    .background(.red)
                    .cornerRadius(16)
                    .frame(width: 350, height: 200, alignment: .top)
                    .transition(.move(edge: .top))
                    .padding(.top, 50)
                    .onTapGesture {
                        self.errorMessage = nil
                    }
            }
            
            Spacer()
        }
        .animation(Animation.spring, value: errorMessage)
    }
    
    private func navigationLinkLabel(for type: JokeType) -> some View {
        HStack {
            type.logo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .background(.white)
                .clipShape(Circle())
                .padding(.trailing, 10)
            
            Text(type.rawValue)
                .font(.title)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
                .frame(alignment: .leading)
            
            Spacer()
        }
        .padding()
        .background(
            Capsule()
                .strokeBorder(lineWidth: 2)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        )
        .clipShape(Capsule())
        .padding()
        .frame(maxWidth: 400)
    }
}
