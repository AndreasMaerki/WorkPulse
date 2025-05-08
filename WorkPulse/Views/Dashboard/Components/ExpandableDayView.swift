import SwiftUI

struct ExpandableDayView: View {
  let day: Date
  let dayName: String
  let segments: [TimeSegment]
  @Binding var isExpanded: Bool
  @Environment(GlobalEnvironment.self) private var viewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Button(action: { isExpanded.toggle() }) {
        HStack {
          Text(dayName)
            .font(.subheadline)
            .foregroundStyle(.secondary)
          Spacer()
          Image(systemName: "chevron.right")
            .foregroundStyle(.secondary)
            .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding(.vertical, 4)
      }
      .buttonStyle(.plain)

      if isExpanded {
        List {
          ForEach(segments) { segment in
            HStack {
              Text(segment.startTime.formatted(date: .omitted, time: .shortened))
                .foregroundStyle(.secondary)
              Text("-")
                .foregroundStyle(.secondary)
              Text((segment.isRunning ? "Running" : segment.endTime?.formatted(date: .omitted, time: .shortened) ?? ""))
                .foregroundStyle(.secondary)
              Spacer()
              Text(segment.elapsedTime(refTime: Date()).formattedHHMMSS())
                .monospacedDigit()
            }
            .font(.footnote)
            .listRowInsets(EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 8))
            .swipeActions(edge: .trailing) {
              Button(role: .destructive) {
                if let clock = segment.clock {
                  viewModel.deleteTimeSegment(segment, from: clock)
                }
              } label: {
                Label("Delete", systemImage: "trash")
              }
            }
          }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .frame(height: CGFloat(segments.count * 24))
      }
    }
    .padding(8)
    .background(Color.gray.opacity(0.05))
    .cornerRadius(8)
  }
}
