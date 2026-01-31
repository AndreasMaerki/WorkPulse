import Foundation
import SwiftData
import SwiftUI

@Model
final class TimeSegment {
  var id: UUID
  var startTime: Date
  var endTime: Date?
  var isRunning: Bool
  var note: String?
  @Relationship var clock: Clock?

  init(id: UUID = UUID(), startTime: Date, endTime: Date? = nil, clock: Clock? = nil, note: String? = nil) {
    self.id = id
    self.startTime = startTime
    self.endTime = endTime
    isRunning = false
    self.clock = clock
    self.note = note
  }

  func elapsedTime(refTime: Date) -> TimeInterval {
    max(0, (endTime ?? refTime).timeIntervalSince(startTime))
  }
}
