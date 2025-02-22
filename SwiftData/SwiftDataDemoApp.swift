//
//  SwiftDataDemoApp.swift
//  SwiftDataDemo
//
//  Created by cenk on 2025-02-21.
//

import SwiftUI
import SwiftData

// MARK: Record Schema

@Model
class Animal {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    // instead of making a new Animal with initial values, it's sometimes clearer
    // to make a factor function like this
    
    static func random() -> Animal {
        return Animal(name: randomName(), age: Int.random(in: 1..<100))
    }
    
    private static func randomName() -> String {
        let letters = "abcdefghijk"
        var name = ""
        for _ in 0..<Int.random(in: 4..<7) {
            name.append(letters.randomElement()!)
        }
        return name
    }
}

/**----------------------------------------------------------**/
// MARK: App

@main
struct SwiftDataDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Animal.self])
    }
}

/**----------------------------------------------------------**/

// MARK: View

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    
    @State var showOldOnly = false
   
    var body: some View {
        VStack {
            Button("Add Animal") {
                let animal = Animal.random()
                modelContext.insert(animal)
                do {
                    try modelContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            AnimalList(showOldOnly: showOldOnly)
            
            Toggle("Old only", isOn: $showOldOnly)
                .padding()
            
            Button("Delete All") {
                do {
                    try modelContext.delete(model: Animal.self, where: Predicate<Animal>.true)
                    // this predicate matches all animals
                    // - note here we give give the record type (Animal.self) and a matching predicate (here always returning true means every record is a match)
                    // - compare to the swipe on action on deleting one model record, by just passing that record
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct AnimalList: View {
    @Environment(\.modelContext) var modelContext
    
    @Query(filter: #Predicate {
        $0.age > 50
    }, sort: \Animal.age) var oldAnimals: [Animal]
    
    // If no filter is given, fill fetch all animals
    @Query var animals: [Animal]
    
    let showOldOnly: Bool
    
    var body: some View {
        List(showOldOnly ? oldAnimals : animals) { animal in
            HStack {
                Text(verbatim: animal.name)
                Spacer()
                Text(animal.age.formatted())
            }
            .swipeActions(edge: .trailing) {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    modelContext.delete(animal)
                }
            }
        }
        .animation(.spring, value: showOldOnly)
    }
}
