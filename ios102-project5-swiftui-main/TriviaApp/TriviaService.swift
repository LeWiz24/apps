//
//  TriviaService.swift
//  TriviaApp
//
//  Created by Mario Olivares on 3/12/24.
//

import Foundation

//Trivia service class
class TriviaService: ObservableObject {
    @Published var triviaQuestions: [TriviaQuestion] = []
    @Published var showingAlert = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Categories dictionary
    
    let categories: [String: Int] = [
        "Any Category" : 0,
        "General Knowledge": 9,
        "Entertainment: Books" : 10,
        "Entertainment: Film" : 11,
        "Entertainment: Music" : 12,
        "Entertainment: Musicals & Theatres": 13,
        "Entertainment: Television" : 14,
        "Entertainment: Video Games" : 15,
        "Entertainment: Board Games": 16,
        "Science & Nature" : 17,
        "Science: Computers" : 18,
        "Science: Mathematics" : 19,
        "Mythology" : 20,
        "Sports" : 21,
        "Geography" : 22,
        "History" : 23,
        "Politics" : 24,
        "Art" : 25,
        "Celebrities" : 26,
        "Animals" : 27,
        "Vehicles" : 28,
        "Entertainment: Comics" : 29,
        "Science: Gadgets" : 30,
        "Entertainment: Japanese Anime & Manga" : 31,
        "Entertainment: Cartoon & Animations" : 32
    ]
    
    
    func fetchTriviaQuestions(amount: Int, category: String, difficulty: String, type: String, completion: @escaping () -> Void) {
        
        isLoading = true
        showingAlert = false
        errorMessage = nil
        
        print("Selected ccategory: \(category)")
        print("Dictionary value for the category: \(categories[category])")

        
        var urlString = "https://opentdb.com/api.php?amount=\(amount)"
        
        if let categoryValue = categories[category] {
            urlString += "&category=\(categoryValue)"
            print("Hello world")
        }
        print("The chosen category is: \(categories[category]) and the url is \(urlString)")
        
        if difficulty != "Any Difficulty" {
            urlString += "&difficulty=\(difficulty.lowercased())"
        }
        print("The chosen difficulty is... url is \(urlString)")
        
        if type == "multiple" {
            urlString += "&type=multiple"
        } else if type == "boolean" {
            urlString += "&type=boolean"
        }
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.showingAlert = true
                self.errorMessage = "Invalid URL"
            }
            return
        }
        print("Fetching trivia questions from from URL: \(url.absoluteString)")
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.showingAlert = true
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                       print("HTTP Response Code: \(httpResponse.statusCode)")
                   }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                       //print("Raw JSON Response: \(dataString)")
                   }
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.showingAlert = true
                    self?.errorMessage = "No data received."
                }
                return
            }
            
            do {
                let triviaResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                DispatchQueue.main.async {
                    switch triviaResponse.responseCode {
                    case 0:
                        self?.triviaQuestions = triviaResponse.results
                        completion()

                    case 1:
                        self?.errorMessage = "No Results: The API doesn't have enough questions for your query."
                    case 2:
                        self?.errorMessage = "Invalid Parameter: Contains an invalid parameter."
                    case 3:
                        self?.errorMessage = "Token Not Found: Session Token does not exist."
                    case 4:
                        self?.errorMessage = "Token Empty: Session Token has returned all possible questions for the specified query."
                    case 5:
                        self?.errorMessage = "Rate Limit: Too many requests have occurred."
                    default:
                        self?.errorMessage = "Unknown error occurred."
                    }
                    self?.showingAlert = self?.errorMessage != nil
                }
            } catch {
                DispatchQueue.main.async {
                    self?.showingAlert = true
                    self?.errorMessage = "Failed to decode JSON: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
    }
    
}
