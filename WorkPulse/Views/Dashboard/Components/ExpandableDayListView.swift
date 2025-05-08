import SwiftUI

struct ExpandableDayListView: View {
  let days: [(Date, String, [TimeSegment])]
  @Binding var expandedDay: Date?

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      ForEach(days, id: \.0) { day, dayName, segments in
        ExpandableDayView(
          day: day,
          dayName: dayName,
          segments: segments,
          isExpanded: Binding(
            get: { expandedDay == day },
            set: { isExpanded in
              withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                expandedDay = isExpanded ? day : nil
              }
            }
          )
        )
      }
    }
    .onAppear {
      if let firstDay = days.first {
        expandedDay = firstDay.0
      }
    }
  }
}

// #Preview {
//    ExpandableDayListView()
// }
