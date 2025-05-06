import SwiftUI

struct DashboardView: View {
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var expandedClockId: UUID? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      HStack {
        Text("Dashboard")
          .font(.largeTitle)
        Spacer()
      }

      // Total time section
      VStack(alignment: .leading, spacing: 8) {
        Text("Total Time")
          .font(.headline)
        Text(viewModel.elapsedTime.formattedHHMMSS())
          .font(.title)
          .monospacedDigit()
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .cornerRadius(8)

      // Individual clocks section
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text("Clocks")
            .font(.headline)

          ForEach(viewModel.clocks) { clock in
            ClockDetailView(
              clock: clock,
              isExpanded: expandedClockId == clock.id,
              onTap: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                  if expandedClockId == clock.id {
                    expandedClockId = nil
                  } else {
                    expandedClockId = clock.id
                  }
                }
              }
            )
          }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
      }

      Spacer()
    }
    .padding()
  }
}

struct ClockDetailView: View {
  let clock: Clock
  let isExpanded: Bool
  let onTap: () -> Void
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var expandedDays: Set<Date> = []

  private func isActiveSegment(_ segment: TimeSegment) -> Bool {
    guard let activeClock = viewModel.activeClock,
          let lastSegment = activeClock.timeSegments.last
    else {
      return false
    }
    return segment.id == lastSegment.id
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

  var body: some View {
    VStack(spacing: 0) {
      Button(action: onTap) {
        HStack {
          Circle()
            .fill(clock.color)
            .frame(width: 12, height: 12)
          Text(clock.name)
            .foregroundStyle(.secondary)
          Spacer()
          Text(clock.elapsedTime().formattedHHMMSS())
            .monospacedDigit()
            .foregroundStyle(clock.id == viewModel.activeClock?.id ? clock.color : .primary)
          Image(systemName: "chevron.right")
            .foregroundStyle(.secondary)
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding(.vertical, 4)
      }
      .buttonStyle(.plain)

      // Time segments
      if isExpanded {
        VStack(alignment: .leading, spacing: 16) {
          ForEach(groupSegmentsByDay(), id: \.0) { day, dayName, segments in
            VStack(alignment: .leading, spacing: 8) {
              Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                  if expandedDays.contains(day) {
                    expandedDays.remove(day)
                  } else {
                    expandedDays.insert(day)
                  }
                }
              }) {
                HStack {
                  Text(dayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                  Spacer()
                  Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(expandedDays.contains(day) ? 90 : 0))
                }
                .padding(.vertical, 4)
              }
              .buttonStyle(.plain)

              if expandedDays.contains(day) {
                VStack(alignment: .leading, spacing: 8) {
                  List {
                    ForEach(segments) { segment in
                      HStack {
                        Text(segment.startTime.formatted(date: .omitted, time: .shortened))
                          .foregroundStyle(.secondary)
                        Text("-")
                          .foregroundStyle(.secondary)
                        Text((isActiveSegment(segment) ? "Running" : segment.endTime?.formatted(date: .omitted, time: .shortened) ?? ""))
                          .foregroundStyle(.secondary)
                        Spacer()
                        Text(segment.elapsedTime(refTime: Date()).formattedHHMMSS())
                          .monospacedDigit()
                      }
                      .font(.footnote)
                      .listRowInsets(EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 8))
                    }
                  }
                  .scrollContentBackground(.hidden)
                  .listStyle(.plain)
                  .frame(height: CGFloat(segments.count * 24)) // Approximate height for each row
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
              }
            }
          }
        }
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
          // Expand the first day by default
          if let firstDay = groupSegmentsByDay().first {
            expandedDays.insert(firstDay.0)
          }
        }
      }
    }
  }
}

#Preview {
  DashboardView()
    .environment(GlobalEnvironment())
}
