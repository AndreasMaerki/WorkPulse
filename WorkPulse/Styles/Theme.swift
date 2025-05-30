import SwiftUI

enum Theme {
  enum Colors {
    static let background = Color.gray.opacity(0.1)
    static let separator = Color.gray.opacity(0.2)
    static let overlay = Color.black.opacity(0.6)
    static let secondaryBackground = Color.gray.opacity(0.05)
    static let textSecondary = Color.secondary
  }

  enum CornerRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
  }
}

// MARK: - Custom View Styles

struct CardBackgroundStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .background(Theme.Colors.background)
      .cornerRadius(Theme.CornerRadius.medium)
  }
}

struct SecondaryCardBackgroundStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .background(Theme.Colors.secondaryBackground)
      .cornerRadius(Theme.CornerRadius.medium)
  }
}

struct OverlayStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .background(Theme.Colors.overlay)
      .cornerRadius(Theme.CornerRadius.small)
  }
}

// MARK: - View Extensions

extension View {
  func cardBackground() -> some View {
    modifier(CardBackgroundStyle())
  }

  func secondaryCardBackground() -> some View {
    modifier(SecondaryCardBackgroundStyle())
  }

  func overlayStyle() -> some View {
    modifier(OverlayStyle())
  }
}
