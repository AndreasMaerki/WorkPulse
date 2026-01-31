import SwiftUI

struct ClockHeaderView: View {
  let clock: Clock
  @Binding var isExpanded: Bool
  let isActive: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Button(action: {
        withAnimation(.easeInOut(duration: 0.2)) {
          isExpanded.toggle()
        }
      }) {
        HStack {
          Circle()
            .fill(clock.color)
            .frame(width: 12, height: 12)
          Text(clock.name)
            .foregroundStyle(.secondary)
          Spacer()
          Text(clock.elapsedTime().formattedHHMMSS())
            .monospacedDigit()
            .foregroundStyle(isActive ? clock.color : .primary)
          Image(systemName: "chevron.right")
            .foregroundStyle(.secondary)
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)

      if isExpanded, let notes = clock.notes {
        Text(notes)
          .font(.footnote)
          .foregroundStyle(.secondary)
          .lineLimit(2)
          .padding(.leading, 24)
          .padding(.bottom, 4)
      }
    }
  }
}
