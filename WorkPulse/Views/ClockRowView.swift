import SwiftUI

struct ClockRowView: View {
  @Environment(GlobalEnvironment.self) private var globalModel
  let clock: Clock

  var body: some View {
    Button {
      toggleClock()
    } label: {
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
    }
    .buttonStyle(.plain)
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
