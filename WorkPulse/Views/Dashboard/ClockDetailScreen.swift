import SwiftUI

struct ClockDetailScreen: View {
  let clock: Clock
  @State private var isExpanded = true
  @Environment(GlobalEnvironment.self) private var viewModel

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        HStack(spacing: 12) {
          Text(clock.name)
            .font(.largeTitle)
          Spacer()
          Button(action: toggleClock) {
            Label(
              viewModel.activeClock?.id == clock.id ? "Stop" : "Start",
              systemImage: viewModel.activeClock?.id == clock.id ? "stop.circle.fill" : "play.circle.fill"
            )
            .font(.title2)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
          }
          .buttonStyle(.borderedProminent)
          .tint(viewModel.activeClock?.id == clock.id ? clock.color : .accentColor)
          .help(viewModel.activeClock?.id == clock.id ? "Stop clock" : "Start clock")
        }

        HStack(alignment: .top, spacing: 20) {
          VStack(alignment: .leading, spacing: 8) {
            Text("Current Segment")
              .font(.subheadline)
              .foregroundStyle(.secondary)
            Text(currentSegmentTime.formattedHHMMSS())
              .font(.title)
              .monospacedDigit()
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .cardBackground()

          Spacer()

          VStack(alignment: .leading, spacing: 6) {
            Text("Total Time")
              .font(.subheadline)
              .foregroundStyle(.secondary)
            Text(clock.elapsedTime().formattedHHMMSS())
              .font(.headline)
              .monospacedDigit()
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 10)
          .cardBackground()
        }
        .frame(maxWidth: .infinity)

        VStack(alignment: .leading, spacing: 16) {
          Text("Details")
            .font(.headline)

          ClockDetailView(
            clock: clock,
            isExpanded: $isExpanded
          )
        }
        .padding()
        .cardBackground()

        Spacer()
      }
      .padding()
    }
  }

  private func toggleClock() {
    if viewModel.activeClock?.id == clock.id {
      viewModel.stopTimer()
    } else {
      viewModel.startTimer(clock)
    }
  }

  private var currentSegmentTime: TimeInterval {
    _ = viewModel.elapsedTime
    guard viewModel.activeClock?.id == clock.id,
          let segment = viewModel.activeTimeSegment,
          segment.clock?.id == clock.id
    else {
      return 0
    }
    return segment.elapsedTime(refTime: segment.endTime ?? Date())
  }
}

#Preview {
  ClockDetailScreen(clock: Clock(name: "Work", color: .blue))
    .environment(GlobalEnvironment())
}
