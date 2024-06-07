//
//  ContentView.swift
//  TranslateMe
//
//  Created by Mario Olivares on 2/12/24.
//

import SwiftUI

//Translate response code
struct TranslationResponse: Codable {
    let responseData: ResponseData
    let responseStatus: Int
    let matches: [Match]
}

struct ResponseData: Codable {
    let translatedText: String
    let match: Double
}

struct Match: Codable {
    let segment: String
    let translation: String
    let quality: Int
    let match: Double
}

struct WordPair: Identifiable, Codable {
    let id: UUID = UUID()
    let original: String
    let translated: String
    let matchScore: Double
    var proficiency: ProficiencyLevel = .middleDeck
}

enum ProficiencyLevel: String, Codable {
    case needsPractice = "needsPractice"
    case middleDeck = "middleDeck"
    case excellent = "excellent"
}

struct CardView: View {
    var wordPair: WordPair
    
    
    @State private var isShowingTranslation = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        VStack {
            // Apply an opposite rotation to the text itself to correct the mirror effect
            Group {
                if !isShowingTranslation {
                    Text("English")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding(.trailing, 225)
                    Text(wordPair.original)
                        .font(.largeTitle)
                        .padding(.bottom, 100)
                } else {
                    Text("Spanish")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding(.trailing, 220)
                    Text(wordPair.translated)
                        .font(.largeTitle)
                        .padding(.bottom, 100)
                }
            }
            .rotation3DEffect(Angle(degrees: isShowingTranslation ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        }
        .padding()
        .frame(width: 350, height: 250)
        .background(isShowingTranslation ? Color.green : Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        // Apply the rotation to the card
        .rotation3DEffect(Angle(degrees: rotationAngle), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.linear(duration: 0.5)) {
                rotationAngle += 180
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isShowingTranslation.toggle()
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Needs Practice")
                    .frame(width: 100, height: 50)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(10)
                
                Spacer()
                
                Text("Know It")
                    .frame(width: 100, height: 50)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding(.top, 44)
            Spacer()
            CardView(wordPair: WordPair(original: "Hello", translated: "Hola", matchScore: 0.85))
            Spacer()
        }
    }
}



#Preview {
    CardView(wordPair: WordPair(original: "Hello", translated: "Hola", matchScore: 0.85))
}

#Preview {
    ContentView()
}
