//
//  ContentView.swift
//  A2-solve
//
//  Created by cenk on 2025-02-18.
//

import SwiftUI

// MARK: Data Types --------------

struct User: Codable, Identifiable, Hashable {
    let id: Int
    let username: String
    let email: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

// MARK: APIModel --------------

class APIModel: ObservableObject {
    @Published var users: Set<User> = [] // user collection elements has no order
    @Published var posts: [Post] = []
    
    // get a user for a given post
    func user(post: Post) throws -> User {
        let user = users.first { user in
            user.id == post.userId
        }
        guard let user else {
            throw ModelError.unknownUser
        }
        return user
    }
    
    // MARK: Network
    let baseURL = URL(string: "https://jsonplaceholder.typicode.com/")!
    
    private func fetch<R: Decodable>(path: String) async throws -> R {
        let url = baseURL.appending(path: path)
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        let code = httpResponse.statusCode
        guard code == 200 else {
            throw ModelError.httpError(code)
        }
        let result = try JSONDecoder().decode(R.self, from: data)
        return result
    }
    
    func updateUsers() async throws {
        let users: Set<User> = try await fetch(path: "users")
        await MainActor.run {
            self.users = users
        }
    }
    
    func updatePosts() async throws {
        let posts: [Post] = try await fetch(path: "posts")
        await MainActor.run {
            self.posts = posts
        }
    }
}

// MARK: UserViewModel --------------

class UserViewModel: ObservableObject {
    // MARK: User Symbols
    
    @Published var userSymbol: [User: String] = [:]
    
    func assignUserSymbols(users: Set<User>) {
        var symbols = [
            "heart.fill",
            "star.fill",
            "circle.fill",
            "diamond.fill",
            "triangle.fill",
            "bolt.fill",
            "moon.fill",
            "pencil",
            "paperplane.fill",
            "house.fill"
        ] // need 10 for the 10 possible users
        
        for user in users {
            userSymbol[user] = symbols.popLast()
        }
        
    }
    
    // MARK: User Colors
    
    @Published var userColor: [User: (Double, Double, Double)] = [:]
    
    func assignUserColors(users: Set<User>) {
        var colors: [(Double, Double, Double)] = (0..<users.count).map { _ in
            (Double.random(in: 0.1..<0.9),
             Double.random(in: 0.1..<0.9),
             Double.random(in: 0.1..<0.9)
            )
        }
        
        for user in users {
            userColor[user] = colors.popLast()
        }
    }
}

// MARK: Custom Errors --------------

enum ModelError: Error {
    case httpError(Int) // statusCode
    case unknownUser
}

// MARK: View --------------

struct ContentView: View {
    @StateObject var api = APIModel()
    @StateObject var userViewModel = UserViewModel()
    
    @State var userSymbols: [User: String] = [:]
    @State var error: Error?

    var body: some View {
        if let error {
            Text("An error occurred. \(error.localizedDescription)")
                .padding()
                .background(.red.opacity(0.5))
                .onTapGesture {
                    withAnimation(.easeOut) {
                        self.error = nil // dismiss
                    }
                }
        }
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(api.posts) { post in
                    PostView(post: post,
                             user: try? api.user(post: post))
                    .environmentObject(userViewModel)
                    .padding()
                    Divider()
                }
            }
        }
        .task {
            do {
                try await api.updateUsers()
                try await api.updatePosts()
                userViewModel.assignUserSymbols(users: api.users)
                userViewModel.assignUserColors(users: api.users)
            } catch {
                self.error = error
            }
        }
    }
}

struct PostView: View {
    let post: Post
    let user: User?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let user {
                UserView(user: user)
            } else {
                Text("Unknown User")
            }
            PostContentView(post: post)
        }
    }
    
    struct PostContentView: View {
        let post: Post
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.title2.weight(.bold))
                Text(post.body)
            }
        }
    }
}

struct UserView: View {
    @EnvironmentObject var model: UserViewModel
    let user: User
    
    private var color: Color {
        let (r, g, b) = model.userColor[user, default: (0.5, 0.5, 0.5)]
        return Color(red: r, green: g, blue: b)
    }
    
    var body: some View {
        HStack {
            Image(systemName: model.userSymbol[user, default: "square.fill"])
                .aspectRatio(contentMode: .fill)
            VStack(alignment: .leading) {
                Text(verbatim: user.username)
                    .font(.body.weight(.semibold))
                    .layoutPriority(1)
                Text(verbatim: user.email)
                    .font(.caption)
                    .layoutPriority(1)
            }
        }
        .foregroundStyle(color)
    }
}

#Preview {
    ContentView()
}
