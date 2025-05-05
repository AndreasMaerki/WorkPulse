//
//  GlobalEnvironment.swift
//  WorkPulse
//
//  Created by Andreas Maerki on 04.05.2025.
//

import Observation
import Foundation
import SwiftUICore
import SwiftData
import _SwiftData_SwiftUI

@Observable
class GlobalEnvironment {
  var clocks: [Clock] = []
  var activeClock: Clock? = nil
  private var timer: Timer?
  var elapsedTime: TimeInterval = 0
  private var modelContext: ModelContext?

  init(modelContext: ModelContext? = nil) {
    self.modelContext = modelContext
    loadClocks()
  }

  private func loadClocks() {
    guard let modelContext = modelContext else { return }
    
    do {
      let descriptor = FetchDescriptor<Clock>()
      clocks = try modelContext.fetch(descriptor)
      updateTotalTime() // Initialize total time
    } catch {
      print("Error fetching clocks: \(error)")
    }
  }

  func startTimer(_ clock: Clock) {
    stopTimer()
    
    let newTimeSegment = TimeSegment(
      startTime: Date(),
      clock: clock
    )
    clock.timeSegments.append(newTimeSegment)
    modelContext?.insert(newTimeSegment)
    activeClock = clock
    
    // Start new timer
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.updateTotalTime()
    }
  }

  func stopTimer() {
    if let activeClock {
      activeClock.updateLastSegmentEndTime()
    }
    activeClock = nil
    timer?.invalidate()
    timer = nil
    try? modelContext?.save()
    updateTotalTime() // Update total time after stopping
  }

  func addClock(_ name: String, _ color: Color) {
    let clock = Clock(name: name, color: color)
    modelContext?.insert(clock)
    clocks.append(clock)
  }

  func deleteClock(_ clock: Clock) {
    if activeClock?.id == clock.id {
      stopTimer()
    }
    modelContext?.delete(clock)
    if let index = clocks.firstIndex(where: { $0.id == clock.id }) {
      clocks.remove(at: index)
    }
    try? modelContext?.save()
    updateTotalTime()
  }

  func updateTotalTime() {
    updateTime()
    elapsedTime = clocks.reduce(0) { result, clock in
      result + clock.elapsedTime()
    }
  }

  private func updateTime() {
    if let activeClock {
      activeClock.updateLastSegmentEndTime()
    }
  }

  func totalTimeForName(_ name: String) -> TimeInterval {
    return clocks.first(where: { $0.name == name })?.elapsedTime() ?? 0
  }

  deinit {
    stopTimer()
  }
}
