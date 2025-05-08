import SwiftUI

struct CalendarDayHeader: View {
  let dateString: String
  let segmentCount: Int
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(dateString)
        .font(.title3.bold())
      Text("You have \(segmentCount) segment\(segmentCount == 1 ? "" : "s") scheduled for today")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .padding(.horizontal)
    .padding(.bottom, 8)
  }
}
