struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        // many ways to create a path
        // "Path" is a SwiftUI path
        // "CGPath" is a CoreGraphics path
        // can easily convert one to other, so how to make the path is your choice
        // but must return a SwiftUI "Path"
        
        let startPoint = CGPoint(x: rect.midX, y: rect.minY) // top of triangle
        
        // 1. Convert at end
        let cgPath = CGMutablePath() // mutable version
        cgPath.move(to: startPoint)
        cgPath.addLines(between: [
            startPoint,
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.maxY),
            startPoint
        ])
        return Path(cgPath)
        
        // 2. SwiftUI only
//      return Path { path in
//            path.move(to: startPoint)
//            path.addLines([
//                startPoint,
//                CGPoint(x: rect.maxX, y: rect.maxY),
//                CGPoint(x: rect.minX, y: rect.maxY),
//                startPoint
//            ])
//        }
    }
}
