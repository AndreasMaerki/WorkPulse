import _SwiftData_SwiftUI
import Foundation
import Observation
import SwiftData
import SwiftUI

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

  private var uiTimer: Timer?
  var elapsedTime: TimeInterval = 0
  private var modelContext: ModelContext?
  private var persistenceManager: PersistenceManager

  var minimumTimeSegmentDuration: TimeInterval {
    get {
      UserDefaults.standard.double(forKey: "minimumTimeSegmentDuration")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "minimumTimeSegmentDuration")
    }
  }

  init(modelContext: ModelContext? = nil) {
    self.modelContext = modelContext
    persistenceManager = PersistenceManager(modelContext: modelContext)
    // Set default minimum duration if not already set
    if UserDefaults.standard.double(forKey: "minimumTimeSegmentDuration") == 0 {
      minimumTimeSegmentDuration = 30 // 30 seconds default
    }
    loadClocks()
  }

  private func loadClocks() {
    guard let modelContext else { return }

    do {
      let descriptor = FetchDescriptor<Clock>()
      clocks = try modelContext.fetch(descriptor)
      updateTime()
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

    uiTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.updateTime()
      }
    }

    persistenceManager.startPersistenceTimer()
  }

  func stopTimer() {
    updateTime()
    checkMinimumDuration()
    activeTimeSegment = nil
    activeClock = nil
    uiTimer?.invalidate()
    uiTimer = nil

    persistenceManager.stopPersistenceTimer()
  }

  private func checkMinimumDuration() {
    if let activeTimeSegment {
      let duration = Date().timeIntervalSince(activeTimeSegment.startTime)
      if duration < minimumTimeSegmentDuration {
        if let clock = activeTimeSegment.clock,
           let index = clock.timeSegments.firstIndex(where: { $0.id == activeTimeSegment.id })
        {
          clock.timeSegments.remove(at: index)
          modelContext?.delete(activeTimeSegment)
        }
      } else {
        activeTimeSegment.isRunning = false
      }
    }
  }

  func addClock(_ name: String, _ color: Color, note: String? = nil) {
    let clock = Clock(name: name, color: color, notes: note)
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
    updateTime()
  }

  func resetClock(_ clock: Clock) {
    if activeClock?.id == clock.id {
      stopTimer()
    }
    clock.timeSegments.removeAll()
    persistenceManager.persistData()
    updateTime()
  }

  func deleteTimeSegment(_ segment: TimeSegment, from clock: Clock) {
    if activeTimeSegment?.id == segment.id {
      stopTimer()
    }
    if let index = clock.timeSegments.firstIndex(where: { $0.id == segment.id }) {
      clock.timeSegments.remove(at: index)
      modelContext?.delete(segment)
      persistenceManager.persistData()
      updateTime()
    }
  }

  private func updateTime() {
    elapsedTime = clocks.reduce(0) { result, clock in
      result + clock.elapsedTime()
    }

    persistenceManager.updateActiveTimeSegmentEndTimeIfRunning()
  }

  func totalTimeForName(_ name: String) -> TimeInterval {
    clocks.first(where: { $0.name == name })?.elapsedTime() ?? 0
  }

  func persistData() {
    persistenceManager.persistData()
  }

  func updateClock(_ clock: Clock, name: String, color: Color, notes: String?) {
    clock.name = name
    clock.color = color
    clock.notes = notes
    persistenceManager.persistData()
  }
}
