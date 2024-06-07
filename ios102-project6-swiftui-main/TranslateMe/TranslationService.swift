//
//  TranslationService.swift
//  TranslateMe
//
//  Created by Mario Olivares on 3/15/24.
//

import Foundation

class TranslationService {
    
    func fetchTranslation(for text: String, from sourceLang: String = "en", to targetLang: String = "es") async throws -> TranslationResponse {
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.replacingOccurrences(of: " ", with: "%20") ?? ""
        let urlString = "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=\(sourceLang)|\(targetLang)"
        print("This is the url being sent to the API!: \(urlString)")
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(TranslationResponse.self, from: data)
        return decodedResponse
    }
}
