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
  var activeTimeSegment: TimeSegment? {
    didSet {
      persistenceManager.setActiveTimeSegment(activeTimeSegment)
    }
  }

  private var timer: Timer?
  var elapsedTime: TimeInterval = 0
  private var modelContext: ModelContext?
  var persistenceManager: PersistenceManager

  init(modelContext: ModelContext? = nil) {
    self.modelContext = modelContext
    persistenceManager = PersistenceManager(modelContext: modelContext)
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

  func findRunningTimeSegment() -> TimeSegment? {
    for clock in clocks {
      if let segment = clock.timeSegments.first(where: { $0.isRunning }),
         segment.id != activeTimeSegment?.id
      {
        return segment
      }
    }
    return nil
  }

  func startTimer(_ clock: Clock, segment: TimeSegment? = nil) {
    // Stop any running timer and set its end time
    if let activeTimeSegment, activeTimeSegment.id != segment?.id {
      activeTimeSegment.endTime = Date()
      activeTimeSegment.isRunning = false
    }
    stopTimer()

    let timeSegment: TimeSegment
    if let segment {
      // Continue with existing segment
      timeSegment = segment
      timeSegment.isRunning = true
    } else {
      // Create new segment
      timeSegment = TimeSegment(
        startTime: Date(),
        clock: clock
      )
      timeSegment.isRunning = true
      clock.timeSegments.append(timeSegment)
    }

    activeClock = clock
    activeTimeSegment = timeSegment

    // Start new timer for UI updates (every second)
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.updateTotalTime()
      }
    }

    persistenceManager.startPersistenceTimer()
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

    persistenceManager.stopPersistenceTimer()
  }

  func addClock(_ name: String, _ color: Color) {
    let clock = Clock(name: name, color: color)
    modelContext?.insert(clock)
    clocks.append(clock)
    persistenceManager.persistData()
  }

  func deleteClock(_ clock: Clock) {
    if activeClock?.id == clock.id {
      stopTimer()
    }
    modelContext?.delete(clock)
    if let index = clocks.firstIndex(where: { $0.id == clock.id }) {
      clocks.remove(at: index)
    }
    persistenceManager.persistData()
    updateTotalTime()
  }

  func deleteTimeSegment(_ segment: TimeSegment, from clock: Clock) {
    if activeTimeSegment?.id == segment.id {
      stopTimer()
    }
    if let index = clock.timeSegments.firstIndex(where: { $0.id == segment.id }) {
      clock.timeSegments.remove(at: index)
      modelContext?.delete(segment)
      persistenceManager.persistData()
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
    // The PersistenceManager will update the activeTimeSegment's endTime when persisting
    // This is just for UI updates between persistence intervals
    if let activeTimeSegment {
      activeTimeSegment.endTime = Date()
    }
  }

  func totalTimeForName(_ name: String) -> TimeInterval {
    clocks.first(where: { $0.name == name })?.elapsedTime() ?? 0
  }
}
