import SwiftUI

struct MenuBarView: View {
  @Environment(GlobalEnvironment.self) private var globalEnvironment
  @Environment(\.openWindow) var openWindow
  var body: some View {
    VStack(spacing: 12) {
      totalTime

      clockSection

      Divider()

      actions
    }
    .padding(.vertical, 8)
    .frame(width: 250)
  }

  private var totalTime: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Total Time")
        .font(.callout)
        .foregroundStyle(.secondary)
      Text(globalEnvironment.elapsedTime.formattedHHMMSS())
        .font(.callout.weight(.medium))
        .monospacedDigit()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 12)
  }

  private var clockSection: some View {
    VStack(spacing: 8) {
      ForEach(globalEnvironment.clocks) { clock in
        let activeSegment = activeSegmentForClock(clock)
        HStack {
          Circle()
            .fill(clock.color)
            .frame(width: 8, height: 8)
          Text(clock.name)
            .font(.callout)
          Spacer()
          if let activeSegment {
            Text(activeSegment.elapsedTime(refTime: activeSegment.endTime ?? Date()).formattedHHMMSS())
              .font(.callout.weight(.medium))
              .monospacedDigit()
          }
          Button {
            toggleClock(clock)
          } label: {
            Image(systemName: globalEnvironment.activeClock?.id == clock.id ? "stop.fill" : "play.fill")
              .font(.callout)
              .foregroundStyle(globalEnvironment.activeClock?.id == clock.id ? .red : .green)
          }
          .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
      }
    }
  }

  private var actions: some View {
    VStack(spacing: 8) {
      Button("Open WorkPulse") {
        openWorkPulse()
      }
      .buttonStyle(.plain)

      Button("Quit") {
        NSApplication.shared.terminate(nil)
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal, 12)
  }

  private func toggleClock(_ clock: Clock) {
    if globalEnvironment.activeClock?.id == clock.id {
      globalEnvironment.stopTimer()
    } else {
      globalEnvironment.startTimer(clock)
    }
  }

  private func activeSegmentForClock(_ clock: Clock) -> TimeSegment? {
    _ = globalEnvironment.elapsedTime
    guard globalEnvironment.activeClock?.id == clock.id,
          let segment = globalEnvironment.activeTimeSegment,
          segment.clock?.id == clock.id
    else {
      return nil
    }
    return segment
  }

  private func openWorkPulse() {
    NSApplication.shared.activate(ignoringOtherApps: true)
    openWindow(id: "WorkPulse")
  }
}
