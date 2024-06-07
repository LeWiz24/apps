//
//  TranslationView.swift
//  TranslateMe
//
//  Created by Mario Olivares on 3/24/24.
//

import SwiftUI

struct Translation: Identifiable, Codable {
    var id: String = UUID().uuidString
    var originalText: String
    var translatedText: String
    var timestamp: Date = Date()
}

struct SavedTranslationsView: View {
    @State private var translations: [Translation] = []
    private let firestoreService = FirestoreService()

    var body: some View {
        List(translations) { translation in
            Text(translation.translatedText)
        }
        .onAppear {
            firestoreService.fetchTranslations { fetchedTranslations in
                self.translations = fetchedTranslations
            }
        }
        Button("Clear All Translations") {
                       firestoreService.clearAllTranslations()
                       // Optionally refresh the list after clearing
                       translations.removeAll()
                   }
                   .padding()
                   .background(Color.red)
                   .foregroundColor(.white)
                   .cornerRadius(10)
               }
    }

#Preview {
    SavedTranslationsView()
}
