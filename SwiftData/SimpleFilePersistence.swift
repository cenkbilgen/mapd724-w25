class APIModel: ObservableObject {
    
    @Published var posts: [Post]
    
    init() {
        self.posts = []
        do {
            self.posts = try readPosts(url: savedPostsURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Read/Write Posts from a local file
    
    private let savedPostsURL = URL.cachesDirectory.appending(path: "posts.json")
    
    func writePosts(url: URL) async throws {
        print("Writing FILE: \(url.absoluteString)")
        let data = try JSONEncoder().encode(posts)
        try data.write(to: url)
    }
    
    func readPosts(url: URL) throws -> [Post] {
        print("Reading FILE: \(url.absoluteString)")
        let data = try Data(contentsOf: url)
        print("Read \(data.count) bytes")
        return try JSONDecoder().decode([Post].self, from: data)
    }
    
    // Fetch posts from Network
    
    let baseURL = URL(string: "https://jsonplaceholder.typicode.com/")!
    
    func fetchPosts() async throws -> [Post] {
        let url = baseURL.appending(path: "posts")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse) // better woudl be to make a custom error that has the actual status code
        }
        let posts = try JSONDecoder().decode([Post].self, from: data)
        return posts
    }

}
