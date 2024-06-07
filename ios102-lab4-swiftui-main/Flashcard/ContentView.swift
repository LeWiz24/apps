//
//  ContentView.swift
//  Flashcard
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @State private var cards: [Card] = Card.mockedCards
    @State private var cardsToPractice: [Card] = []
    @State private var cardsMemorized: [Card] = []

    @State private var offset: CGSize = .zero
    @State private var deckId: Int = 0

    @State private var createCardViewPresented = false

    var body: some View {
        
        // Card deck
        ZStack {

            // Reset buttons
            VStack {
                Button("Reset") {
                    cards = cardsToPractice + cardsMemorized
                    cardsToPractice = []
                    cardsMemorized = []
                    deckId += 1
                }
                .disabled(cardsToPractice.isEmpty && cardsMemorized.isEmpty)

                Button("More Practice") {
                    cards = cardsToPractice
                    cardsToPractice = []
                    deckId += 1
                }
                .disabled(cardsToPractice.isEmpty)
            }

            // Cards
            ForEach(0..<cards.count, id: \.self) { index in
                CardView(card: cards[index], onSwipedLeft: {
                    let removedCard = cards.removeLast()
                    cardsToPractice.append(removedCard)
                }, onSwipedRight: {
                    let removedCard = cards.removeLast()
                    cardsMemorized.append(removedCard)
                })
                .rotationEffect(.degrees(Double(cards.count - 1 - index) * -5))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topTrailing) {
            Button("Add Flashcard", systemImage: "plus") {
                createCardViewPresented.toggle()
            }
            .padding()
        }
        .animation(.bouncy, value: cards)
        .id(deckId)
        .sheet(isPresented: $createCardViewPresented, content: {
            CreateFlashcardView { card in
                cards.append(card)
            }
        })
    }
}

#Preview {
    ContentView()
}
