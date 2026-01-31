import Foundation
import SwiftData

@MainActor
class PersistenceManager {
  private var persistenceTimer: Timer?
  private var lastPersistenceTime: Date = .init()
  private let persistenceInterval: TimeInterval = 30.0
  private var modelContext: ModelContext?
  private weak var activeTimeSegment: TimeSegment?

  init(modelContext: ModelContext? = nil) {
    self.modelContext = modelContext
  }

  func startPersistenceTimer() {
    persistenceTimer?.invalidate()
    persistenceTimer = Timer.scheduledTimer(withTimeInterval: persistenceInterval, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.persistData()
      }
    }
    lastPersistenceTime = .init()
  }

  func stopPersistenceTimer() {
    persistenceTimer?.invalidate()
    persistenceTimer = nil
    persistData()
  }

  func persistData() {
    updateActiveTimeSegmentEndTime()
    try? modelContext?.save()
    lastPersistenceTime = .init()
  }

  func updateModelContext(_ modelContext: ModelContext?) {
    self.modelContext = modelContext
  }

  func setActiveTimeSegment(_ timeSegment: TimeSegment?) {
    activeTimeSegment = timeSegment
  }

  private func updateActiveTimeSegmentEndTime() {
    if let activeTimeSegment, activeTimeSegment.isRunning {
      activeTimeSegment.endTime = Date()
    }
  }
}
