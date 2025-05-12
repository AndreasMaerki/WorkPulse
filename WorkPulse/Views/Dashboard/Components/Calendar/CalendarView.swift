import SwiftData
import SwiftUI

struct CalendarView: View {
  @Environment(CalendarViewModel.self) private var viewModel
  @State private var selectedView = CalendarViewType.day

  enum CalendarViewType {
    case day
    case week
  }

  var body: some View {
    VStack {
      Picker("View", selection: $selectedView) {
        Text("Day").tag(CalendarViewType.day)
        Text("Week").tag(CalendarViewType.week)
      }
      .pickerStyle(.segmented)
      .padding()

      switch selectedView {
      case .day:
        DayView()
      case .week:
        WeekView()
      }
    }
  }
}

#Preview {
  CalendarView()
    .environment(CalendarViewModel(events: CalendarEvent.mockEvents))
}
