import SwiftUI

struct WeekView: View {
  @State var viewModel = CalendarViewModel(events: CalendarEvent.mockEvents)
  private let layoutProvider: CalendarLayoutProvider

  let timeSlots: [Int] = Array(0 ... 23)
  let slotHeight: CGFloat = 60
  let hourLabelWidth: CGFloat = 50
  let calendar = Calendar.current

  init(viewModel: CalendarViewModel = CalendarViewModel(events: CalendarEvent.mockEvents)) {
    _viewModel = State(initialValue: viewModel)
    layoutProvider = CalendarLayoutProvider(slotHeight: slotHeight, calendar: calendar)
  }

  var body: some View {
    GeometryReader { geometry in
      VStack {
        navigationHeader
          .padding()

        ScrollView {
          HStack(alignment: .top, spacing: 0) {
            timeColumn
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 0) {
                ForEach(0 ..< 7) { dayOffset in
                  if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) {
                    HStack(spacing: 0) {
                      dayColumn(for: date, columnWidth: (geometry.size.width - hourLabelWidth - 40) / 7)

                      // Add separator after each day except the last one
                      if dayOffset < 6 {
                        Rectangle()
                          .fill(Color.gray.opacity(0.2))
                          .frame(width: 1)
                          .frame(height: CGFloat(timeSlots.count) * slotHeight + 30) // Add 30 for header space
                      }
                    }
                  }
                }
              }
            }
          }
          .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }

  private var startOfWeek: Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: viewModel.currentDate)
    return calendar.date(from: components) ?? viewModel.currentDate
  }

  private var navigationHeader: some View {
    HStack {
      Button(action: { goToPreviousWeek() }) {
        Image(systemName: "chevron.left")
      }
      Text("\(startOfWeek, format: .dateTime.month().day()) - \(endOfWeek, format: .dateTime.month().day())")
      Button(action: { goToNextWeek() }) {
        Image(systemName: "chevron.right")
      }
    }
  }

  private var endOfWeek: Date {
    calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
  }

  private var timeColumn: some View {
    VStack(alignment: .leading, spacing: 0) {
      Rectangle()
        .fill(.clear)
        .frame(width: hourLabelWidth, height: 30) // Header space

      ForEach(timeSlots, id: \.self) { hour in
        Text("\(hour):00")
          .frame(width: hourLabelWidth, alignment: .trailing)
          .frame(height: slotHeight)
      }
    }
  }

  private func dayColumn(for date: Date, columnWidth: CGFloat) -> some View {
    VStack(spacing: 0) {
      Text(date, format: .dateTime.weekday(.abbreviated).day())
        .frame(width: columnWidth)
        .padding(.bottom, 8)

      ZStack(alignment: .topLeading) {
        VStack(spacing: 0) {
          ForEach(timeSlots, id: \.self) { _ in
            Rectangle()
              .fill(Color.gray.opacity(0.2))
              .frame(width: columnWidth, height: 1)
              .frame(height: slotHeight)
          }
        }

        ForEach(layoutProvider.eventsForDate(date, from: viewModel.events)) { event in
          let height = layoutProvider.calculateEventHeight(event)
          EventView(event: event)
            .frame(width: columnWidth - 4)
            .position(
              x: (columnWidth - 4) / 2,
              y: layoutProvider.calculateEventYPosition(event) + height / 2
            )
            .frame(height: height)
        }
      }
    }
    .frame(width: columnWidth)
  }

  private func goToNextWeek() {
    viewModel.currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: viewModel.currentDate) ?? viewModel.currentDate
  }

  private func goToPreviousWeek() {
    viewModel.currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: viewModel.currentDate) ?? viewModel.currentDate
  }
}

#Preview {
  WeekView()
}
