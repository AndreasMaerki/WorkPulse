import SwiftUI

struct MenuBarView: View {
  @Environment(GlobalEnvironment.self) private var globalEnvironment
  @Environment(\.openWindow) var openWindow
  var body: some View {
    VStack(spacing: 12) {
      // Total time section
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

      // Clocks section
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
              if globalEnvironment.activeClock?.id == clock.id {
                globalEnvironment.stopTimer()
              } else {
                globalEnvironment.startTimer(clock)
              }
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

      Divider()

      // Actions section
      VStack(spacing: 8) {
        Button("Open WorkPulse") {
          NSApplication.shared.activate(ignoringOtherApps: true)
          openWindow(id: "WorkPulse")
        }
        .buttonStyle(.plain)

        Button("Quit") {
          NSApplication.shared.terminate(nil)
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal, 12)
    }
    .padding(.vertical, 8)
    .frame(width: 250)
  }
}
