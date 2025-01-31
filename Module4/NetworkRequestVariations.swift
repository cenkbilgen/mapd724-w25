import Foundation
import PlaygroundSupport

let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
let request = URLRequest(url: url)

func report(response: URLResponse, data: Data) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    print("Status Code: \(httpResponse.statusCode)")
    print("Data Recieved: \(data.count.formatted(.byteCount(style: .file)))")
}

/**===============================**/

// METHOD 1. Callback

//let taskWithCompletion = URLSession.shared.dataTask(with: request) { data, response, error in
//    // data is type Data?
//    // response is type URLResponse?
//    // error is type Error?
//    
//    // Need to handle all the potential optional values
//    if let error {
//        print(error.localizedDescription)
//    } else if let response,
//        let data {
//        try? report(response: response, data: data)
//    } else {
//        print("Unexpected closure arguments")
//    }
//}
//taskWithCompletion.resume() // this kicks it off

/**===============================**/

// METHOD 2. Session Delegate

//final class Delegate: NSObject, URLSessionDataDelegate {
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
//        print(error?.localizedDescription ?? "no error")
//        print((task.response as? HTTPURLResponse)?.statusCode ?? -1)
//    }
//}
//
//let session = URLSession(configuration: .default, delegate: Delegate(), delegateQueue: nil)
//
//let taskWithDelegate = session.dataTask(with: request)
//taskWithDelegate.resume()

/**===============================**/

// METHOD 3. Combine Publisher

import Combine

let task = URLSession.shared.dataTaskPublisher(for: url)
    .sink { completion in
        switch completion {
        case .failure(let error): print(error.localizedDescription)
        case .finished: print("Finished")
        }
    } receiveValue: { data, response in
        // data is type Data
        // response is type URLResponse
        // no optionals to handle, if any errors the publisher will send it as Failure, see above
        do {
            try report(response: response, data: data)
        } catch {
            print(error.localizedDescription)
        }
    }

/**===============================**/

// METHOD 4. Swift
Task {
    do {
        let (data, response) = try await URLSession.shared.data(for: request)
        try report(response: response, data: data)
    } catch {
        print(error.localizedDescription)
    }
}
