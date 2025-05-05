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

  private func isActiveSegment(_ segment: TimeSegment) -> Bool {
    guard let activeClock = viewModel.activeClock,
          let lastSegment = activeClock.timeSegments.last
    else {
      return false
    }
    return segment.id == lastSegment.id
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
        VStack(alignment: .leading, spacing: 8) {
          ForEach(clock.timeSegments.sorted(by: { $0.startTime > $1.startTime })) { segment in
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
            .padding(.leading, 24)
          }
        }
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
  }
}

#Preview {
  DashboardView()
    .environment(GlobalEnvironment())
}
