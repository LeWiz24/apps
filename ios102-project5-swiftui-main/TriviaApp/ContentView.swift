//
//  ContentView.swift
//  TriviaApp
//
//  Created by Mario Olivares on 11/1/23.
//

import SwiftUI

// Trivia response structs and enum
struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestion]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}
   
// TriviaQuestion data model
struct TriviaQuestion: Identifiable, Codable {
    var id: String {question}
    let category: String
    let type: QuestionType
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    enum CodingKeys: String, CodingKey {
        case category
        case type
        case difficulty
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    var allAnswers: [String] {
        return [correctAnswer] + incorrectAnswers.shuffled()
    }
}

enum QuestionType: String, Codable {
    case multiple
    case boolean
}

// Starting page for user to select categories, length, etc. Reflect user input, we'll need to set up states that bind to SwiftUI views

struct OptionSelectionView: View {
    @StateObject private var triviaService = TriviaService()
    @State private var numberOfQuestions = "10"
    @State private var selectedCategory = "Any Category"
    @State private var difficultyValue = 0.5
    @State private var selectedType = "Any Type"
    @State private var isTriviaGameActive = false
    
    @State private var selectedTimerDuration = 30 // Default selection
    let timerDurations = [30, 60, 120, 300, 3600] // Available options
  
    
    var difficultyString: String {
        if difficultyValue < 0.33 {
            return "Easy"
        } else if difficultyValue < 0.66 {
            return "Medium"
        } else {
            return "Hard"
        }
    }
    
    var body: some View {
        // UI components
        
        
        NavigationStack{
            ZStack{
                // Modify the gradient colors here to match Codepath colors or your preferred blue-ish theme
                let gradient = Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.9)])
                let radialGradient = RadialGradient(gradient: gradient, center: .center, startRadius: 2, endRadius: 650)

                // Set background
                radialGradient
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    // Set title
                    Text("Trivia Game")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .shadow(radius: 10)
                    Form {
                        TextField("Number of Questions", text: $numberOfQuestions)
                            .keyboardType(.numberPad)
                        Picker("Select Category", selection: $selectedCategory){
                            ForEach(triviaService.categories.keys.sorted(), id: \.self) { category in
                                Text(category).tag(category)}
                        }
                        HStack{
                            Text("Difficulty: \(difficultyString)")
                            Slider(value: $difficultyValue, in: 0...1)
                        }
                        Picker("Select Type", selection: $selectedType) {
                            Text("Any Type").tag("Any Type")
                            Text("Multiple Choice").tag("Multiple Choice")
                            Text("True or False").tag("True or False")
                        }
                        Picker("Timer Duration", selection: $selectedTimerDuration) {
                            ForEach(timerDurations, id: \.self) { duration in
                                Text(duration == 3600 ? "1 hour" : "\(duration) seconds").tag(duration)
                            }
                        }
                    }
                    Button("Start Trivia") {
                        startTrivia()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(25)
                    .padding(.horizontal)
                    .shadow(color: .gray, radius: 5, x: 0, y: 5)
                    .disabled(triviaService.isLoading)
                    .opacity(triviaService.isLoading ? 0.5 : 1)
                    
                    NavigationLink(destination: TriviaGameView(triviaService: triviaService, timerDuration: selectedTimerDuration), isActive: $isTriviaGameActive) { EmptyView() }
                }
                .alert(isPresented: $triviaService.showingAlert) {
                    Alert(title: Text("Error"), message: Text(triviaService.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    func startTrivia() {
        let selectedAmount = Int(numberOfQuestions) ?? 10
        let selectedDifficulty = difficultyString.lowercased()
        let selectedTypeKey = selectedType == "Any Type" ? "" : (selectedType == "Multiple Choice" ? "multiple" : "boolean")
        
        // Pass `selectedCategory` directly without converting it
        triviaService.fetchTriviaQuestions(amount: selectedAmount, category: selectedCategory, difficulty: selectedDifficulty, type: selectedTypeKey) {
            self.isTriviaGameActive = true
        }
    }
}

// New view that will present questions to users

struct TriviaGameView: View {
    
    @ObservedObject var triviaService = TriviaService()
    @State private var userAnswers: [String: String] = [:]
    @State private var showingAlert = false
    @State private var score = 0
    
    //  Timer variables
    var timerDuration: Int
    @State private var timeRemaining: Int
    
    // Define timer variables
    @State private var selectedTimerDuration = 60 // Default selection
    let timerDurations = [30, 60, 120, 300, 3600] // Available options
    
    // Update your initializer to accept the timerDuration
       init(triviaService: TriviaService, timerDuration: Int) {
           self.triviaService = triviaService
           self.timerDuration = timerDuration
           _timeRemaining = State(initialValue: timerDuration) // Initialize timeRemaining
       }
    
    
    var body: some View {
        
        VStack {
            // Display timer
            Text("Time remaining: \(timeRemaining)s")
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    if self.timeRemaining > 0 {
                        self.timeRemaining -= 1
                    } else {
                        self.endGame()
                    }
                }
            if triviaService.triviaQuestions.isEmpty {
                ProgressView("Loading...")
            } else {
                List(triviaService.triviaQuestions) {question in
                    TriviaQuestionView(question:question, userAnswer: $userAnswers[question.id])
                }
                Button("Submit"){
                    calculateScore()
                    showingAlert = true
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                .background(Color.green)
                .foregroundColor(.white)
                .font(.headline)
                .cornerRadius(25)
                .padding(.horizontal)
                .shadow(color: .gray, radius: 5, x: 0, y: 5)
                .disabled(triviaService.isLoading)
                .opacity(triviaService.isLoading ? 0.5 : 1)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Score"), message: Text("You scored \(score) out of \(triviaService.triviaQuestions.count)"), dismissButton: .default(Text("OK")))
                }
            }
        }
        .onAppear(){
            // Reset the timer each time this view appears
            selectedTimerDuration
        }
        .font(.title)
        .padding()
        .background(Color(red: 0.85, green: 0.95, blue: 0.85))
    }
        
    func endGame() {
        calculateScore()
        showingAlert = true
    }
    
    func calculateScore() {
        score = userAnswers.reduce(0) { (score, answer) -> Int in
            let questionId = answer.key
            let userAnswer = answer.value
            
            if let question = triviaService.triviaQuestions.first(where: { $0.id == questionId }), question.correctAnswer == userAnswer {
                return score + 1
            }
            return score
        }
    }
    
    
    
    struct TriviaQuestionView: View {
        var question: TriviaQuestion
        @Binding var userAnswer: String?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(question.question.decodingHTMLEntities)
                    .font(.headline)
                
                ForEach(Array(question.allAnswers.enumerated()), id: \.offset) {index, answer in
                    ChoiceView(selectedAnswer: $userAnswer, answer: answer, index: index)
                }
            }
            .padding()
        }
    }
    
    struct ChoiceView: View {
        @Binding var selectedAnswer: String?
        let answer: String
        let index: Int
        
        func indexToLetter(_ index: Int) -> String {
            let letters = ["A", "B", "C", "D", "E"]
            return letters[safe: index] ?? "?"
        }
        
        var body: some View {
            Button(action: {
                selectedAnswer = answer
            }) {
                HStack {
                    Text("\(indexToLetter(index)). \(answer.decodingHTMLEntities)")
                        .lineLimit(nil) // Allows text to wrap to a new line
                        .minimumScaleFactor(0.5) // Adjusts font size to fit
                    Spacer()
                    if selectedAnswer == answer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity) // Ensures the button uses the full width
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    
    struct ToggleView: View {
        var choices: [String]
        
        var body: some View {
            HStack {
                ForEach(choices, id: \.self) { choice in
                    Toggle(isOn: .constant(true), label: {
                        Text(choice)
                    })
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
            }
        }
    }
    
    struct MultipleChoiceView: View {
        @State private var selectedAnswer: String?
        var choices: [String]
        
        var body: some View {
            ForEach(choices, id: \.self) { choice in
                Text(choice)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    
    //The cell created
    
    struct TriviaViewList: View {
        var questions: [TriviaQuestion]
        
        var body: some View {
            List(questions, id: \.id) {question in
                VStack(alignment: .leading) {
                    Text(question.question)
                        .font(.headline)
                    ForEach(question.allAnswers, id: \.self) {answer in
                        Button(action: {
                            // Handle answer selection
                        }) {
                            Text(answer)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .padding(.top, 5)
                    }
                }
                .padding(.bottom)
            }
        }
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

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


    #Preview {
        OptionSelectionView()
    }

