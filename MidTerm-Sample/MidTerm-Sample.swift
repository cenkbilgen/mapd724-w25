/*
 Here's a sample solution to the midterm using NavigationStack.
 */

import Foundation
import SwiftUI

@main
struct TriviaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct Question: Identifiable, Decodable, Hashable {
    let id: String
    let category: Category
    let question: QuestionData
    let correctAnswer: String
    var incorrectAnswers: [String]
    
    enum Category: String, Decodable, Identifiable, Hashable, CaseIterable {
        case music
        case sport_and_leisure
        case film_and_tv
        case arts_and_literature
        case history
        case society_and_culture
        case science
        case geography
        case food_and_drink
        case general_knowledge
        var id: String { rawValue }
    }
    
    struct QuestionData: Decodable, Hashable {
        let text: String
    }
    
    var prompt: String {
        question.text
    }
    
    enum Difficulty: String, Decodable, Identifiable, CaseIterable {
        case easy, medium, hard
        var id: String { rawValue }
    }
}

// MARK: - Fetching Trivia from API

class GameState: ObservableObject {
    @Published var path: [Question] = [] // the navigation path of questions
    @Published var questions: [Question] = [] // the set of questions when the game starts
    var isDone: Bool {
        questions.isEmpty && !path.isEmpty // all questions have been put on the nav path, and it's not empty
    }
    @Published var correctCount = 0
    
    func fetchQuestions(count: Int) async throws -> [Question] {
        let urlString = "https://the-trivia-api.com/v2/questions?limit=\(count)"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        // request.setValue("API_KEY", forHTTPHeaderField: "x-api-key")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        let statusCode = httpResponse.statusCode
        guard statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([Question].self, from: data)
    }
    
    @MainActor
    func reset() { // should take you back to the main menu
        self.path = []
        self.questions = []
    }
    
    func startGame(difficulty: Question.Difficulty, count: Int) async throws {
        await MainActor.run {
            self.reset()
        }
        let questions = try await fetchQuestions(count: count)
        await MainActor.run {
            self.questions = questions
        }
        await nextQuestion()
    }
    
    @MainActor
    func nextQuestion() {
        if let question = self.questions.popLast() {
            path.append(question)
        }
    }
}

// MARK: - Main ContentView (NavigationStack with Menu)
struct ContentView: View {
    @StateObject private var state = GameState()
    @State private var difficulty: Question.Difficulty = .easy
    private let questionCount = 5
    
    var body: some View {
        NavigationStack(path: $state.path) {
            VStack {
                Button("Play Game") {
                    Task {
                        do {
                            try await state.startGame(difficulty: difficulty, count: questionCount)
                        } catch {
                            print(error)
                        }
                    }
                }
                
                Picker(selection: $difficulty) {
                    ForEach(Question.Difficulty.allCases) { difficulty in
                        Text(difficulty.rawValue)
                    }
                } label: {
                    Text("Difficulty")
                }
                .pickerStyle(.inline)
            }
            .navigationTitle("Trivia Main Menu")
            .navigationDestination(for: Question.self) { question in
                QuestionView(question: question) { isCorrect in
                    print(isCorrect ? "Correct" : "Wrong")
                    if isCorrect {
                        state.correctCount += 1
                    }
                    state.nextQuestion()
                }
                .navigationTitle("Question \(state.path.count + 1)")
                .navigationBarBackButtonHidden()
            }
            .sheet(isPresented: .constant(state.isDone)) {
                VStack {
                    Text("Final Score")
                    Text("\(state.correctCount) / \(state.path.count)")
                    Button("Back to Main Menu") {
                        state.reset()
                    }
                }
            }
        }
    }
}
    
struct QuestionView: View {
    let question: Question
    let onAnswered: (Bool) -> Void // isCorrect: Bool
    @State private var answers: [String] = []
    @State private var selectedAnswer: String?
    @State private var timeLeft: TimeInterval = 10
    
    enum AnswerState {
        case correct, incorrect, timeout
    }
    private var answerState: AnswerState? {
        if let selectedAnswer {
            if selectedAnswer == question.correctAnswer {
                return .correct
            } else {
                return .incorrect
            }
        } else if timeLeft.isLessThanOrEqualTo(.zero) {
            return .timeout
        } else {
            return nil
        }
    }
    
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Text(question.category.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.caption.weight(.heavy))
            
            Divider()
            
            Text(question.prompt)
                .font(.title2)
                .padding()
                .multilineTextAlignment(.center)
        
            ProgressView(value: timeLeft, total: 10)
                .padding()
                .tint(.blue)
                .opacity(answerState == nil ? 1 : 0)
            
            ForEach(answers.indices, id: \.self) { index in
                Button {
                    selectedAnswer = answers[index]
                } label: {
                    Text(answers[index])
                        .foregroundColor(.primary)
                }
                .disabled(selectedAnswer != nil || timeLeft.isLess(than: .zero))
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.5))
                .opacity(answers[index] == question.correctAnswer || answerState == nil ? 1 : 0.2)
                .cornerRadius(8)
            }
        }
        .padding()
        .task {
            answers = (question.incorrectAnswers + [question.correctAnswer]).shuffled()
        }
        .onChange(of: answerState) { oldValue, newValue in
            Task {
                if oldValue == nil {
                    try? await Task.sleep(for: .seconds(2))
                    onAnswered(answerState == .correct)
                }
            }
        }
        .onChange(of: question.prompt, initial: true) { _, _ in
            selectedAnswer = nil
            timeLeft = 10
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if answerState == nil {
                    timeLeft -= 1
                }
            }
        }
    }
}
