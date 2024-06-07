//
//  ContentView.swift
//  TranslateMe
//
//  Created by Mario Olivares on 2/12/24.
//

import SwiftUI

// Data models to store info in database



//Translate response code
struct TranslationResponse: Codable {
    let responseData: ResponseData
    let responseStatus: Int
    let matches: [Match]
}

// Response data will have a translated text that needs to become my response
struct ResponseData: Codable {
    let translatedText: String
    let match: Double
}


struct Match: Codable {
    let segment: String
    let translation: String
    let quality: Quality
    let match: Double
    
    enum Quality: Codable {
        case string(String)
        case number(Int)
        
        var intValue: Int {
            switch self {
            case .string(let stringValue):
                return Int(stringValue) ?? 0
            case .number(let intValue):
                return intValue
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let intValue = try? container.decode(Int.self) {
                self = .number(intValue)
            } else if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            } else {
                throw DecodingError.typeMismatch(Quality.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected to decode String or Int"))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let stringValue):
                try container.encode(stringValue)
            case .number(let intValue):
                try container.encode(intValue)
            }
        }
    }
}

// View of home page
struct TranslationView: View {
    @State private var inputText: String = ""
    @State private var translatedText: String = ""
    @State private var isTranslating: Bool = false
    
    // Service objects 
    private var translationService = TranslationService()
    
    // Define a gradient background
    private var backgroundGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.3), Color.blue.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter text", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    Task {
                        await translateText()
                        print("This button is being pressed.")
                        
                    }
                }) {
                    Text("Translate Me")
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(inputText.isEmpty || isTranslating)
                
                Text(translatedText)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, alignment: .leading)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                NavigationLink(destination: SavedTranslationsView()) {
                            Text("View Saved Translations")
                        }
                        .padding()
                    }
                    .navigationTitle("Translate Me")
            }
            .navigationTitle("Translate Me")
            .background(backgroundGradient) // Apply the gradient background
            .edgesIgnoringSafeArea(.all) // Extend the background to the edges
        }
    
    
    private func translateText() async {
        guard !inputText.isEmpty else { return }
        isTranslating = true
        let firestoreService = FirestoreService() // Instantiate FirestoreService
        do {
            let response = try await translationService.fetchTranslation(for: inputText)
            let translatedTextResponse = response.responseData.translatedText.removingPercentEncoding ?? "Decoding failed"
            
            // Prepare the translation object
            let translation = Translation(originalText: inputText, translatedText: translatedTextResponse)
            
            // Store the translation in Firestore
            firestoreService.addTranslation(translation)
            
            // Update the UI
            translatedText = translatedTextResponse
            print(translatedText)
        } catch {
            print("Error during translation: \(error.localizedDescription)")
            translatedText = "Translation Failed"
        }
        isTranslating = false
    }

}


struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView()
    }
}

extension String {
    var decodingHTMLEntities: String {
        var result = self
        let entities = [
            ("&quot;", "\""),
            ("&apos;", "'"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&amp;", "&"),
            ("&#039;", "'"),
            ("&ndash;", "–"),
            ("&mdash;", "—"),
            ("&hellip;", "…"),
            ("&euro;", "€"),
            ("&pound;", "£"),
            ("&copy;", "©"),
            ("&reg;", "®"),
            ("&prime;", "′"),
            ("&Prime;", "″"),
            ("&sup2;", "²")
            // Add more entities as needed
        ]
        for (encodedEntity, decodedEntity) in entities {
            result = result.replacingOccurrences(of: encodedEntity, with: decodedEntity)
        }
        return result
    }
}


#Preview {
    TranslationView()
}
