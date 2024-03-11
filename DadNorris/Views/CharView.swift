import SwiftUI

private enum Const {
    static let range1 = CGFloat.random(in: -1000 ... (-400))
    static let range2 = CGFloat.random(in: 400...1000)
    static let delayCoefficient = 0.05
}

struct CharView: View {
    @State private var offset: CGSize
    private let char: String
    private let index: Int
    private let delay: Double
    
    init(char: String, index: Int) {
        self.char = char
        self.index = index
        
        _offset = State(wrappedValue: CGSize(width: Bool.random() ? Const.range1 : Const.range2, height: Bool.random() ? Const.range1 : Const.range2))
        delay = Double(index) * Const.delayCoefficient
    }
    
    var body: some View {
        Text(char)
            .font(.title2)
            .offset(offset)
            .onAppear {
                withAnimation(.easeOut(duration: 1).delay(delay)) {
                    offset = CGSize.zero
                }
            }
    }
}
