//
//  Clock.swift
//  WorkPulse
//
//  Created by Andreas Maerki on 04.05.2025.
//


import Foundation
import SwiftUICore

class Clock: Identifiable, Equatable {
  static func == (lhs: Clock, rhs: Clock) -> Bool {
    true
  }

  let id: UUID
  var name: String
  var color: Color
  var timeSegments: [TimeSegment] = []

  init(id: UUID = UUID(), name: String, color: Color) {
    self.id = id
    self.name = name
    self.color = color
  }

  func elapsedTime() -> TimeInterval {
    timeSegments.reduce(0) { result, timeSegment in
      result + timeSegment.elapsedTime(refTime: Date())
    }
  }
}

