import SwiftUI

extension View {
    // Adds a modifier to apply a shadow with a specified radius and color
    func customShadow(radius: CGFloat = 5, color: Color = .black.opacity(0.2)) -> some View {
        self.shadow(color: color, radius: radius)
    }

    // Adds a modifier to apply rounded corners with a specified radius
    func roundedCorners(radius: CGFloat) -> some View {
        self.cornerRadius(radius)
    }

    // Adds a modifier to apply padding with a specified value
    func customPadding(_ value: CGFloat) -> some View {
        self.padding(value)
    }

    // Adds a modifier to apply a border with a specified color and width
    func customBorder(color: Color, width: CGFloat) -> some View {
        self.border(color, width: width)
    }
}