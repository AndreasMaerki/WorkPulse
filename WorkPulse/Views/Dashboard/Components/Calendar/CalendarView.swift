import SwiftData
import SwiftUI

struct CalendarView: View {
  @Environment(CalendarViewModel.self) private var viewModel
  @Environment(\.dismiss) private var dismiss
  @State private var selectedView = CalendarViewType.day

  enum CalendarViewType {
    case day
    case week
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Button(action: { dismiss() }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(.secondary)
            .font(.title2)
        }
        .buttonStyle(.plain)
        .padding()

        Spacer()
      }

      Picker("View", selection: $selectedView) {
        Text("Day").tag(CalendarViewType.day)
        Text("Week").tag(CalendarViewType.week)
      }
      .pickerStyle(.segmented)
      .padding(.horizontal)
      .padding(.bottom)

      switch selectedView {
      case .day:
        DayView()
      case .week:
        WeekView()
      }
    }
    .frame(minWidth: 800, minHeight: 600)
  }
}

#Preview {
  CalendarView()
    .environment(CalendarViewModel(events: CalendarEvent.mockEvents))
}
