import SwiftUI

struct DashboardView: View {
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var expandedClockId: UUID? = nil
  @State private var showCalendar = false

  private var calendarEvents: [CalendarEvent] {
    viewModel.clocks.flatMap { clock in
      clock.timeSegments.map { segment in
        CalendarEvent(
          title: clock.name,
          startTime: segment.startTime,
          endTime: segment.endTime ?? Date(),
          color: clock.color
        )
      }
    }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        HStack {
          Text("Dashboard")
            .font(.largeTitle)
          Spacer()
        }

        // Total time and Pie Chart section
        HStack(alignment: .top, spacing: 20) {
          VStack(alignment: .leading, spacing: 16) {
            Text("Total Time")
              .font(.title)
            Text(viewModel.elapsedTime.formattedHHMMSS())
              .font(.largeTitle)
              .monospacedDigit()
          }
          .padding(20)
          .background(Color.gray.opacity(0.1))
          .cornerRadius(8)

          HStack(spacing: 16) {
            PieChartView()
              .frame(width: 120, height: 120)

            Button {
              showCalendar = true
            } label: {
              Image(systemName: "calendar")
                .font(.title2)
                .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("View time segments in calendar")
          }

          Spacer()
        }
        .frame(maxWidth: .infinity)

        // Individual clocks section
        VStack(alignment: .leading, spacing: 16) {
          Text("Clocks")
            .font(.headline)

          ForEach(viewModel.clocks) { clock in
            ClockDetailView(
              clock: clock,
              isExpanded: Binding(
                get: { expandedClockId == clock.id },
                set: { isExpanded in
                  withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    expandedClockId = isExpanded ? clock.id : nil
                  }
                }
              )
            )
          }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)

        Spacer()
      }
      .padding()
    }
    .sheet(isPresented: $showCalendar) {
      CalendarView()
        .environment(CalendarViewModel(events: calendarEvents))
        .presentationSizing(.fitted)
    }
  }
}

#Preview {
  DashboardView()
    .environment(GlobalEnvironment())
}
