import SwiftUI

struct Card: Identifiable {
    var id: Int
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var firstSelectedCardIndex: Int? = nil
    @State private var numberOfPairs = 3 // Default number of pairs
    let pairOptions = [3, 6, 10]

    var body: some View {
        VStack {
            HStack {
                // Dropdown for selecting number of pairs
                Menu {
                    Picker("Number of Pairs", selection: $numberOfPairs) {
                        ForEach(pairOptions, id: \.self) {
                            Text("\($0) Pairs")
                        }
                    }
                } label: {
                    Text("Choose Size")
                }
                .padding()
                .foregroundColor(.white)
                .background(.orange)
                .cornerRadius(100)

                Spacer()

                // Reset button
                Button("Reset Game") {
                    resetGame()
                }
                .padding()
                .foregroundColor(.white)
                .background(.green)
                .cornerRadius(100)
            }
            .padding()

            // ScrollView to allow scrolling through cards
            ScrollView {
                // Grid of cards
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(cards) { card in
                        CardView(card: card)
                            .onTapGesture {
                                flipCard(card)
                            }
                    }
                }
                .padding()
            }
        }
        .onChange(of: numberOfPairs) { _ in resetGame() } // Reset the game when number of pairs changes
    }

    private func getIndex(of card: Card) -> Int {
        return cards.firstIndex(where: { $0.id == card.id }) ?? 0
    }

    private func flipCard(_ card: Card) {
        let cardIndex = getIndex(of: card)

        if let firstIndex = firstSelectedCardIndex {
            cards[cardIndex].isFaceUp = true
            if cards[firstIndex].content == cards[cardIndex].content {
                cards[firstIndex].isMatched = true
                cards[cardIndex].isMatched = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    cards[firstIndex].isFaceUp = false
                    cards[cardIndex].isFaceUp = false
                }
            }
            firstSelectedCardIndex = nil
        } else {
            firstSelectedCardIndex = cardIndex
            cards[cardIndex].isFaceUp = true
        }
    }

    private func resetGame() {
        cards = []
        for pairIndex in 0..<numberOfPairs {
            let content = ["🚀", "🌟", "🌍", "🌕", "🌈", "🔥", "🎉", "🎈", "🍎", "🚗"][pairIndex % 10]
            let card1 = Card(id: pairIndex * 2, content: content)
            let card2 = Card(id: pairIndex * 2 + 1, content: content)
            cards += [card1, card2]
        }
        cards.shuffle()
        firstSelectedCardIndex = nil
    }
}

struct CardView: View {
    let card: Card

    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                RoundedRectangle(cornerRadius: 10).fill().foregroundColor(.white)
                RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 3)
                Text(card.content).font(.largeTitle)
            } else {
                RoundedRectangle(cornerRadius: 10).fill().foregroundColor(.blue)
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
        .opacity(card.isMatched ? 0 : 1)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
