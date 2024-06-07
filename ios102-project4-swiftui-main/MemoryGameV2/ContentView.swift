//
//  ContentView.swift
//  MemoryGameV2
//
//  Created by Mario Olivares on 10/18/23.
//

import SwiftUI

// MARK: Content view struct that displays UI
struct ContentView: View {
    @State private var game: MemoryGame
    @State private var flipBack: Bool = false

    
    init(game: MemoryGame){
        self._game = State(initialValue: game)
    }
    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
            ForEach(game.cards) { card in
                CardView(emoji: card.content, isFaceUp: card.isFaceUp)
                    .onTapGesture {
                        let result = game.choose(card)
                        if case .flipDown = result.operation {
                            flipBack = true
                            // Delay logic to flip back or use result.flipIndices for precise control
                        }
                    }
                    .animation(flipBack ? Animation.default.delay(1) : .default)
            }
            }
        }
    }

// MARK: Struct that defines our card view
struct CardView: View {
    var emoji: String
    var isFaceUp: Bool
    
    var body: some View {
        ZStack{
            let shape = RoundedRectangle(cornerRadius: 25)
            if isFaceUp {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: 3)
                Text(emoji).font(.largeTitle)
            } else {
                shape.fill().foregroundColor(.green)
            }
            }
        .frame(width: 100, height: 140)
        }
    }

// MARK: Card model struct
struct Card: Identifiable{
    
    var id = UUID()
    var isFaceUp = false
    var isMatched = false
    var content: String // This string holds emoji
    
}

// MARK: Memory game logic
struct MemoryGame {
    var cards: [Card]
    
    init(emojiList: [String] = ["😀", "😂", "🥲", "😎", "🤩"]) {
        // Initialize cards array using emojiList
        cards = Array<Card>()
        for emoji in emojiList {
            let card1 = Card(content: emoji)
            let card2 = Card(content: emoji)
            cards.append(contentsOf: [card1, card2])
        }
        cards.shuffle()
    }

    
    //Track flipped cards here
    var indexOfOneAndOnlyFaceUpCard: Int? = nil
    
    // Function to choose a card
    mutating func choose(_ card: Card) -> (operation: CardOperation, flipIndices: [Int]) {
        var flipIndices: [Int] = []
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched
        {
            cards[chosenIndex].isFaceUp.toggle()
            
            let faceUpIndices = cards.indices.filter { cards[$0].isFaceUp && !cards[$0].isMatched }
            
            if faceUpIndices.count == 3 {
                var uniqueEmojis: Set<String> = []
                for index in faceUpIndices {
                    uniqueEmojis.insert(cards[index].content)
                }

                let hasPair = uniqueEmojis.count == 2
                
                // Assign indices to flip back
                flipIndices = faceUpIndices
                
                for index in faceUpIndices {
                    if hasPair && cards[index].content == uniqueEmojis.first {
                        cards[index].isMatched = true
                    } else {
                        cards[index].isFaceUp = false
                    }
                }
                
                return (.flipDown, flipIndices)
            }
        }
        return (.flipUp, flipIndices)
    }



}

enum CardOperation {
    case flipUp
    case flipDown
}

#Preview {
    ContentView(game: MemoryGame())
}
