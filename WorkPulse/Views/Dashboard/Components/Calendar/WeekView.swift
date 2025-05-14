import SwiftUI

struct WeekView: View {
  @Environment(CalendarViewModel.self) private var viewModel
  private let layoutProvider: CalendarLayoutProvider
  @State private var scrollProxy: ScrollViewProxy? = nil

  let timeSlots: [Int] = Array(0 ... 23)
  let slotHeight: CGFloat = 60
  let hourLabelWidth: CGFloat = 50
  let calendar = Calendar.current

  private var startOfWeek: Date {
    let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: viewModel.currentDate)
    return calendar.date(from: components) ?? viewModel.currentDate
  }

  private var endOfWeek: Date {
    calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek
  }

  init() {
    layoutProvider = CalendarLayoutProvider(slotHeight: slotHeight, calendar: calendar)
  }

  var body: some View {
    GeometryReader { geometry in
      let dayWidth = (geometry.size.width - hourLabelWidth - 40) / 7
      let daysOfWeek = (0 ..< 7).compactMap { dayOffset in
        calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
      }

      VStack(spacing: 0) {
        navigationHeader
          .padding()

        // Fixed header row
        HStack(alignment: .top, spacing: 0) {
          Rectangle()
            .fill(.clear)
            .frame(width: hourLabelWidth, height: 12)

          HStack(spacing: 0) {
            ForEach(daysOfWeek.indices, id: \.self) { index in
              let date = daysOfWeek[index]
              Text(date, format: .dateTime.weekday(.abbreviated).day())
                .frame(width: dayWidth)
                .padding(.bottom, 8)

              if index < 6 {
                Rectangle()
                  .fill(Color.gray.opacity(0.2))
                  .frame(width: 1)
                  .frame(height: 12)
              }
            }
          }
        }
        .padding(.horizontal)
        .background(.background)

        ScrollView {
          ScrollViewReader { proxy in
            LazyHStack(alignment: .top, spacing: 0) {
              timeColumn

              LazyHStack(spacing: 0) {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                  let date = daysOfWeek[index]
                  dayColumn(for: date, columnWidth: dayWidth)

                  if index < 6 {
                    Rectangle()
                      .fill(Color.gray.opacity(0.2))
                      .frame(width: 1)
                      .frame(height: CGFloat(timeSlots.count) * slotHeight)
                  }
                }
              }
            }
            .padding()
            .onAppear {
              // Scroll to 6:00 AM
              withAnimation {
                proxy.scrollTo(6, anchor: .top)
              }
            }
          }
        }
      }
    }
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

  private var timeColumn: some View {
    LazyVStack(alignment: .leading, spacing: 0) {
      ForEach(timeSlots, id: \.self) { hour in
        Text("\(hour):00")
          .frame(width: hourLabelWidth, alignment: .trailing)
          .frame(height: slotHeight)
          .id(hour)
      }
    }
  }

  private func dayColumn(for date: Date, columnWidth: CGFloat) -> some View {
    let events = layoutProvider.eventsForDate(date, from: viewModel.events)

    return VStack(spacing: 0) {
      ZStack(alignment: .topLeading) {
        // Time slot separators
        LazyVStack(spacing: 0) {
          ForEach(timeSlots, id: \.self) { _ in
            Rectangle()
              .fill(Color.gray.opacity(0.2))
              .frame(width: columnWidth, height: 1)
              .frame(height: slotHeight)
          }
        }

        ForEach(events) { event in
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
    .environment(CalendarViewModel(events: CalendarEvent.mockEvents))
}
