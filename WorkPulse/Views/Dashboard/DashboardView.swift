import SwiftUI

struct DashboardView: View {
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var expandedClockId: UUID? = nil
  @State private var showCalendar = false
  @State private var calendarViewModel: CalendarViewModel?

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
          .cardBackground()

          HStack(spacing: 16) {
            PieChartView()
              .frame(width: 120, height: 120)

            calendarButton
          }

          Spacer()
        }
        .frame(maxWidth: .infinity)

        // Individual clocks section
        VStack(alignment: .leading, spacing: 16) {
          Text("Clocks")
            .font(.headline)

          ForEach(viewModel.clocks) { clock in
            detailViewWithAnimation(clock)
          }
        }
        .padding()
        .cardBackground()

        Spacer()
      }
      .padding()
    }
    .sheet(isPresented: $showCalendar) {
      if let calendarViewModel {
        CalendarView()
          .environment(calendarViewModel)
          .frame(minWidth: 800, minHeight: 600)
      }
    }
    .onChange(of: showCalendar) { _, isShowing in
      if isShowing {
        calendarViewModel = CalendarViewModel(events: calendarEvents)
      }
    }
  }

  private var calendarButton: some View {
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

  private func detailViewWithAnimation(_ clock: Clock) -> some View {
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

#Preview {
  DashboardView()
    .environment(GlobalEnvironment())
}
