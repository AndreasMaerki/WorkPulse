//
//  Classes.swift
//  WorkPulse
//
//  Created by Andreas Maerki on 04.05.2025.
//

import Foundation
import SwiftUICore

class TimeSegment: Identifiable {
  let id: UUID
  var startTime: Date
  var endTime: Date? = nil
  var assignedClock: UUID

  init(id: UUID = UUID(), startTime: Date, endTime: Date? = nil, assignedClock: UUID) {
    self.id = id
    self.startTime = startTime
    self.endTime = endTime
    self.assignedClock = assignedClock
  }

  func elapsedTime(refTime: Date) -> TimeInterval {
    (endTime ?? refTime).timeIntervalSince(startTime)
  }
}
