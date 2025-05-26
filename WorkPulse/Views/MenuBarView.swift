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
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(globalEnvironment.elapsedTime.formattedHHMMSS())
        .font(.system(size: 16, weight: .medium))
        .monospacedDigit()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 12)
  }

  private var clockSection: some View {
    VStack(spacing: 8) {
      ForEach(globalEnvironment.clocks) { clock in
        HStack {
          Circle()
            .fill(clock.color)
            .frame(width: 8, height: 8)
          Text(clock.name)
            .font(.system(size: 12))
          Spacer()
          Text(clock.elapsedTime().formattedHHMMSS())
            .font(.system(size: 12, weight: .medium))
            .monospacedDigit()
          Button {
            toggleClock(clock)
          } label: {
            Image(systemName: globalEnvironment.activeClock?.id == clock.id ? "stop.fill" : "play.fill")
              .font(.system(size: 10))
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

  private func openWorkPulse() {
    NSApplication.shared.activate(ignoringOtherApps: true)
    openWindow(id: "WorkPulse")
  }
}
