import Foundation

extension TimeInterval {
  func formattedHHMMSS() -> String {
    Duration.seconds(self).formatted(.time(pattern: .hourMinuteSecond))
  }
}
