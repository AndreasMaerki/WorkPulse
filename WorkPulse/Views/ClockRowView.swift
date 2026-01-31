import SwiftUI

struct ClockRowView: View {
  @Environment(GlobalEnvironment.self) private var globalModel
  let clock: Clock
  let showsStartStop: Bool

  var body: some View {
    HStack(spacing: 12) {
      LabeledContent {
        Image(systemName: "hourglass")
          .font(.title2)
          .padding(.horizontal, 4)
          .foregroundStyle(clock.color)
      } label: {
        HStack {
          Text(clock.elapsedTime().formattedHHMMSS())
            .monospaced(true)
            .foregroundStyle(.white)
            .padding(6)
            .background(
              RoundedRectangle(cornerRadius: 4)
                .fill(globalModel.activeClock?.id == clock.id ? clock.color : .clear)
            )
          Text(clock.name)
        }
      }
      .contentShape(Rectangle())

      Spacer()

      if showsStartStop {
        Button {
          toggleClock()
        } label: {
          Image(systemName: globalModel.activeClock?.id == clock.id ? "stop.circle.fill" : "play.circle.fill")
            .foregroundStyle(globalModel.activeClock?.id == clock.id ? clock.color : .secondary)
        }
        .buttonStyle(.borderless)
        .help(globalModel.activeClock?.id == clock.id ? "Stop clock" : "Start clock")
      }
    }
    .background(Color.secondary.opacity(0.1).cornerRadius(Theme.CornerRadius.small))
  }

  private func toggleClock() {
    if globalModel.activeClock?.id == clock.id {
      globalModel.stopTimer()
    } else {
      globalModel.startTimer(clock)
    }
  }
}
