//
//  ContentView.swift
//  ShapeDemo
//
//  Created by cenk on 2025-01-31.
//

import SwiftUI

struct ContentView: View {
    
    @State var isButtonPressed = false
    
    @State var dragY: CGFloat = .zero
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .font(.title3.weight(.bold))
                .scaleEffect(dragY)
                // .stroke(.purple, lineWidth: 10, antialiased: true)

            Text("Hello, world!")
                .font(.headline.weight(.bold))
                .opacity(isButtonPressed ? 1 : 0)
            Text("Drag: \(dragY.formatted())")
            
            Circle()
                .fill(Color.blue)
                .stroke(.purple, lineWidth: 10, antialiased: true)
                
                .highPriorityGesture(TapGesture()
                    .onEnded {
                        isButtonPressed.toggle()
                    })
                .gesture(DragGesture()
                    .onChanged({ value in
                        dragY = value.translation.height
                    })
                        .onEnded({ _ in
                            dragY = .zero
                        }))
                
               
                .padding(50)
                .border(Color.black)
                .border(Color.black)

            
            Button {
                isButtonPressed = true
            } label: {
                Circle()
                    .fill(Color.blue)
                    .stroke(.purple, lineWidth: 10, antialiased: true)
                    .overlay {
                        Image(systemName: "tray\(isButtonPressed ? ".full" : "")")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.mint)
                            .padding()
                            .padding()
                            
                    }
            }

        }
        .animation(.bouncy, value: isButtonPressed)
        .padding()
    }
}

struct ThreeCircle: View {
    var body: some View {
        Text("hello")
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
            var path = Path()
            
            // Start at top center
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            
            // Draw line to bottom right
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            
            // Draw line to bottom left
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            
            // Close the path (draws line back to start point)
            path.closeSubpath()
            
            return path
        }
}

#Preview {
    ContentView()
}

/* Example Protocol */

protocol Animal {
    var name: String { get }
    var age: Int { get }
    func eat()
}

protocol Pet {
    var isVicous: Bool { get }
}

struct Dog: Animal, Pet {
    let name: String
    var age: Int
    var isVicous: Bool = false
    
    func eat() {
        print("have a bone")
    }
}

struct Cat: Animal {
    let name: String
    var age: Int
    
    func eat() {
        print("have milk")
    }
}

class Model {
    let fido = Dog(name: "fido", age: 2)
    let garfield = Cat(name: "Garfield", age: 12)
    
    func feed(animal: (Animal & Pet)) {
        if animal.isVicous == false {
            animal.eat()
        }
    }
    
    func feedAnimals() {
        feed(animal: fido)
    }
}
