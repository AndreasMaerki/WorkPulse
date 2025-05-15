import _SwiftData_SwiftUI
import Foundation
import Observation
import SwiftData
import SwiftUICore

@Observable
@MainActor
class GlobalEnvironment {
  var clocks: [Clock] = []
  var activeClock: Clock?
  var activeTimeSegment: TimeSegment?
  private var timer: Timer?
  var elapsedTime: TimeInterval = 0
  private var modelContext: ModelContext?

  init(modelContext: ModelContext? = nil) {
    self.modelContext = modelContext
    loadClocks()
  }

  private func loadClocks() {
    guard let modelContext else { return }

    do {
      let descriptor = FetchDescriptor<Clock>()
      clocks = try modelContext.fetch(descriptor)
      updateTotalTime() // Initialize total time
    } catch {
      print("Error fetching clocks: \(error)")
    }
  }

  func startTimer(_ clock: Clock) {
    // Stop any running timer and set its end time
    if let activeTimeSegment {
      activeTimeSegment.endTime = Date()
      activeTimeSegment.isRunning = false
    }
    stopTimer()

    let newTimeSegment = TimeSegment(
      startTime: Date(),
      clock: clock
    )
    newTimeSegment.isRunning = true
    clock.timeSegments.append(newTimeSegment)
    activeClock = clock
    activeTimeSegment = newTimeSegment

    // Start new timer
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.updateTotalTime()
      }
    }
  }

  func stopTimer() {
    updateTotalTime() // Update total time after stopping
    if let activeTimeSegment {
      activeTimeSegment.isRunning = false
    }
    activeTimeSegment = nil
    activeClock = nil
    timer?.invalidate()
    timer = nil
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

  func deleteTimeSegment(_ segment: TimeSegment, from clock: Clock) {
    if activeTimeSegment?.id == segment.id {
      stopTimer()
    }
    if let index = clock.timeSegments.firstIndex(where: { $0.id == segment.id }) {
      clock.timeSegments.remove(at: index)
      modelContext?.delete(segment)
      try? modelContext?.save()
      updateTotalTime()
    }
  }

  func updateTotalTime() {
    updateTime()
    elapsedTime = clocks.reduce(0) { result, clock in
      result + clock.elapsedTime()
    }
  }

  private func updateTime() {
    if let activeTimeSegment {
      activeTimeSegment.endTime = Date()
    }
  }

  func totalTimeForName(_ name: String) -> TimeInterval {
    clocks.first(where: { $0.name == name })?.elapsedTime() ?? 0
  }

//  deinit {
//    stopTimer()
//  }
}
