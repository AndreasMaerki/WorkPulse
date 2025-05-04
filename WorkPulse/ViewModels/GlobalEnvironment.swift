//
//  GlobalEnvironment.swift
//  WorkPulse
//
//  Created by Andreas Maerki on 04.05.2025.
//

import Observation
import Foundation
import SwiftUICore


@Observable
class GlobalEnvironment: ObservableObject {
  var clocks: [Clock] = [
    .init(name: "Work", color: .blue),
    .init(name: "Personal", color: .red),
    .init(name: "Travel", color: .green),
  ]

  var activeClock: Clock? = nil
  var publicTimer = Timer()
  var publicDate = Date()

  func activateClock(_ clock: Clock) {
    let newTimeSegment = TimeSegment(
      startTime: Date(), assignedClock: clock.id
    )
    clock.timeSegments.append(newTimeSegment)

    if let index = clocks.firstIndex(where: { $0.id == clock.id }) {
      self.clocks[index] = clock
    }

    activeClock = clock
  }

  func inactiveClock(clock: Clock) {
    if let index = clocks.firstIndex(where: { $0.id == clock.id }) {
      clocks[index].timeSegments.last!.endTime = Date()
    }

    activeClock = nil
  }

  func addClock(_ name: String, _ color: Color) {
    let clock = Clock(name: name, color: color)
    clocks.append(clock)
  }
}
