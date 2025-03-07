//
//  ContentView.swift
//  Module2
//
//  Created by cenk on 2025-01-17.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var model = ViewModel()
    
    var body: some View {
        (model.isDay ? Color.yellow :  Color.blue)
            .ignoresSafeArea()
            .animation(.easeOut, value: model.isDay)
    }
}

class ViewModel: ObservableObject {
    @Published var isDay = true
    
    var subscribers: Set<AnyCancellable> = []
    
    init() {
        let publisher = Timer.publish(every: 4, on: .main, in: .common)
            .autoconnect()
        
        publisher
            .sink { date in
                print("isDay changed. \(date.formatted())")
                self.isDay.toggle()
            }
            .store(in: &subscribers)
    }
}

#Preview {
    ContentView()
}
