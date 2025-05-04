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
  private var timer: Timer?

  var elapsedTime: TimeInterval = 0

  func startTimer(_ clock: Clock) {
    // Stop any existing timer first
    stopTimer()
    
    let newTimeSegment = TimeSegment(
      startTime: Date(), assignedClock: clock.id
    )
    clock.timeSegments.append(newTimeSegment)
    activeClock = clock
    
    // Start new timer
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.updateTotalTime()
    }
  }

  func stopTimer() {
    if let activeClock, let index = clocks.firstIndex(where: { $0.id == activeClock.id }) {
      activeClock.timeSegments.last?.endTime = Date()
      clocks[index] = activeClock
    }
    activeClock = nil
    
    // Invalidate and cleanup timer
    timer?.invalidate()
    timer = nil
  }

  func addClock(_ name: String, _ color: Color) {
    let clock = Clock(name: name, color: color)
    clocks.append(clock)
  }

  func updateTotalTime() {
    elapsedTime = clocks.reduce(0) { result, clock in
      result + clock.elapsedTime()
    }
  }

  func totalTimeForName(_ name: String) -> TimeInterval {
    return clocks.first(where: { $0.name == name })?.elapsedTime() ?? 0
  }

  func currentTimeForClock(_ clock: Clock) -> TimeInterval {
    if clock.id == activeClock?.id {
      // For active clock, include the current running segment
      return clock.elapsedTime()
    } else {
      // For inactive clocks, just return the total elapsed time
      return clock.elapsedTime()
    }
  }

  deinit {
    stopTimer()
  }
}
