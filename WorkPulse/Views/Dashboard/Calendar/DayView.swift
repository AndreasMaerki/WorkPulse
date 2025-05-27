import SwiftUI

struct DayView: View {
  @Environment(CalendarViewModel.self) private var viewModel
  private let layoutProvider: CalendarLayoutProvider

  let timeSlots: [Int] = Array(0 ... 23)
  let slotHeight: CGFloat = 60
  let hourLabelWidth: CGFloat = 50
  let calendar = Calendar.current

  init() {
    layoutProvider = CalendarLayoutProvider(slotHeight: slotHeight, calendar: calendar)
  }

  var body: some View {
    GeometryReader { geometry in
      VStack {
        navigationHeader
          .padding()

        ScrollView {
          ScrollViewReader { proxy in
            ZStack(alignment: .topLeading) {
              timeSlotList
              eventsOverlay(availableWidth: geometry.size.width)
            }
            .padding(.horizontal)
            .onAppear {
              // Scroll to 7:00 AM
              withAnimation {
                proxy.scrollTo(7, anchor: .top)
              }
            }
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }

  private var navigationHeader: some View {
    HStack {
      Button(action: { viewModel.goToPreviousDay() }) {
        Image(systemName: "chevron.left")
      }
      Text(viewModel.selectedDate, style: .date)
      Button(action: { viewModel.goToNextDay() }) {
        Image(systemName: "chevron.right")
      }
    }
  }

  private var timeSlotList: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(timeSlots, id: \.self) { hour in
        HStack {
          Text("\(hour):00")
            .frame(width: hourLabelWidth, alignment: .leading)
          Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(maxWidth: .infinity)
            .frame(height: 1)
        }
        .frame(height: slotHeight)
        .id(hour) // Add id for scrolling
      }
    }
  }

  private func eventsOverlay(availableWidth: CGFloat) -> some View {
    HStack(alignment: .top) {
      // Space for hour labels
      Spacer()
        .frame(width: hourLabelWidth + 8)

      ZStack(alignment: .topLeading) {
        ForEach(layoutProvider.eventsForDate(viewModel.selectedDate, from: viewModel.events)) { event in
          let height = layoutProvider.calculateEventHeight(event)
          EventView(event: event)
            .frame(maxWidth: .infinity)
            .position(
              x: (availableWidth - hourLabelWidth - 40) / 2,
              y: layoutProvider.calculateEventYPosition(event) + height / 2
            )
            .frame(height: height)
        }
      }
      .frame(maxWidth: .infinity)
    }
  }
}

#Preview {
  DayView()
    .environment(CalendarViewModel(events: CalendarEvent.mockEvents))
}
