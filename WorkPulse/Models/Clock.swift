import AppKit
import Foundation
import SwiftData
import SwiftUICore

@Model
final class ColorComponents {
  var red: Double
  var green: Double
  var blue: Double
  var opacity: Double

  init(red: Double, green: Double, blue: Double, opacity: Double) {
    self.red = red
    self.green = green
    self.blue = blue
    self.opacity = opacity
  }
}

@Model
final class Clock {
  var id: UUID
  var name: String
  @Relationship var colorComponents: ColorComponents
  @Relationship(deleteRule: .cascade, inverse: \TimeSegment.clock) var timeSegments: [TimeSegment] = []

  var color: Color {
    get {
      Color(
        .sRGB,
        red: colorComponents.red,
        green: colorComponents.green,
        blue: colorComponents.blue,
        opacity: colorComponents.opacity
      )
    }
    set {
      if let components = newValue.components {
        colorComponents.red = components.red
        colorComponents.green = components.green
        colorComponents.blue = components.blue
        colorComponents.opacity = components.opacity
      }
    }
  }

  var sortedTimeSegments: [TimeSegment] {
    timeSegments.sorted { $0.startTime < $1.startTime }
  }

  init(id: UUID = UUID(), name: String, color: Color) {
    self.id = id
    self.name = name
    if let components = color.components {
      colorComponents = ColorComponents(
        red: components.red,
        green: components.green,
        blue: components.blue,
        opacity: components.opacity
      )
    } else {
      colorComponents = ColorComponents(red: 1, green: 1, blue: 1, opacity: 1)
    }
  }

  func elapsedTime() -> TimeInterval {
    timeSegments.reduce(0) { result, timeSegment in
      result + timeSegment.elapsedTime(refTime: Date())
    }
  }

  func updateLastSegmentEndTime() {
    guard !timeSegments.isEmpty else { return }
    sortedTimeSegments.last!.endTime = Date()
  }
}
