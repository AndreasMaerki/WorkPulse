import SwiftUI

struct ClockDetailView: View {
  let clock: Clock
  @Binding var isExpanded: Bool
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var expandedDay: Date?

  var body: some View {
    VStack(spacing: 0) {
      ClockHeaderView(
        clock: clock,
        isExpanded: $isExpanded,
        isActive: clock.id == viewModel.activeClock?.id
      )

      if isExpanded {
        ExpandableDayListView(
          days: groupSegmentsByDay(),
          expandedDay: $expandedDay
        )
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
  }

  private func groupSegmentsByDay() -> [(Date, String, [TimeSegment])] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: clock.sortedTimeSegments) { segment in
      calendar.startOfDay(for: segment.startTime)
    }
    return grouped.sorted { $0.key > $1.key }
      .map { ($0.key.formattedForTimeSegment(), $0.value.sorted(by: { $0.startTime > $1.startTime })) }
      .map { (calendar.startOfDay(for: $0.1.first?.startTime ?? Date()), $0.0, $0.1) }
  }
}
