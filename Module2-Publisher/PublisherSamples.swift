import Combine
import Foundation

let publisher1 = [3, 5, 6, 7, 1].publisher

let publisher2 = (100..<110).publisher

let publisher3 = Just("hello")

let publisher4 = Timer.TimerPublisher(interval: 5, runLoop: .current, mode: .common)
    .autoconnect()

let publisher5 = URLSession.shared.dataTaskPublisher(for: URL(string: "https://gsmplaceholder.com")!)

let publisher6 = NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange, object: nil)

var publishedCount = 0

var latestNumber: Int?

let subscriber1 = publisher2
    .map {
        "Number is \($0)"
    }
    .min()
    .sink { value in
        publishedCount += 1
        print("\(publishedCount): \(value)")
    }

//let subscriber2 = publisher5
//    .sink { error in
//        print("Network call failed")
//    } receiveValue: { data, response in
//        print(data.count)
//    }
//
//let subscriber3 = publisher4
//    .sink {
//        print($0.formatted(date: .omitted, time: .complete))
//    }
//

