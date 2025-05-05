import Foundation
import SwiftData
import SwiftUICore

@Model
final class TimeSegment {
  var id: UUID
  var startTime: Date
  var endTime: Date?
  @Relationship var clock: Clock?

  init(id: UUID = UUID(), startTime: Date, endTime: Date? = nil, clock: Clock? = nil) {
    self.id = id
    self.startTime = startTime
    self.endTime = endTime
    self.clock = clock
  }

  func elapsedTime(refTime: Date) -> TimeInterval {
    (endTime ?? refTime).timeIntervalSince(startTime)
  }
}
