//
//  ContentView.swift
//  T1
//
//  Created by cenk on 2025-02-10.
//

import SwiftUI

class GridState: ObservableObject {
    let images = ["a", "b", "c", "d", "e", "f", "g", "h"]
    let size: Int
    
    @Published var grid: [String]
    
    @Published var selected: Set<String> = []
    
    init(size: Int) {
        self.size = size
        self.grid = Array(repeating: "", count: size)
        for index in 0..<size {
            self.grid[index] = images[index]
        }
    }
    
    func replaceImage(_ image: String) {
        guard let index = grid.firstIndex(of: image) else {
            return
        }
        while true {
            if let newImage = images.randomElement(),
               !grid.contains(newImage) {
                grid[index] = newImage
                break
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var gridState = GridState(size: 4)
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    ImageView(image: gridState.grid[0], color: .blue)
                    ImageView(image: gridState.grid[1], color: .green)
                }
                VStack(spacing: 0) {
                    ImageView(image: gridState.grid[2], color: .red)
                    ImageView(image: gridState.grid[3], color: .yellow)
                }
            }
            Button("Shuffle") {
                for selectedImage in gridState.selected {
                    gridState.replaceImage(selectedImage)
                }
                gridState.selected.removeAll() // reset selections
            }
        }
        .environmentObject(gridState)
    }
}

struct ImageView: View {
    @EnvironmentObject var gridState: GridState
    let image: String
    let color: Color
    let checkmarkLineWidth: CGFloat = 22
    let checkmarkSizeRatio: CGFloat = 0.5
    
    var isSelected: Bool {
        gridState.selected.contains(image)
    }
    
    var body: some View {
        ZStack {
            color
            Image(systemName: "\(image).circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
        }
        .overlay {
            Checkmark()
                .stroke(Color.secondary, lineWidth: checkmarkLineWidth/checkmarkSizeRatio)
                .scaleEffect(checkmarkSizeRatio)
                .opacity(isSelected ? 1 : 0)
            
        }
        .onTapGesture {
            if isSelected {
                gridState.selected.remove(image)
            } else {
                gridState.selected.insert(image)
            }
        }
    }
}

struct Checkmark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addLines([
            CGPoint(x: rect.minX, y: rect.midY),
            CGPoint(x: rect.midX, y: rect.maxY),
            CGPoint(x: rect.maxX, y: rect.minY)
        ])
        return path
    }
}

#Preview {
    ContentView()
}
