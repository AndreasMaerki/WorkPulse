import SwiftUI

struct ExpandableDayView: View {
  let day: Date
  let dayName: String
  let segments: [TimeSegment]
  @Binding var isExpanded: Bool
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var selectedSegment: TimeSegment?
  @State private var showNoteEditor = false

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
            VStack(alignment: .leading, spacing: 4) {
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

              if let note = segment.note {
                Text(note)
                  .font(.caption)
                  .foregroundStyle(.secondary)
                  .lineLimit(2)
                  .padding(.leading)
              }
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 8))
            .onTapGesture(count: 2) {
              selectedSegment = segment
              showNoteEditor = true
            }
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
        .frame(height: min(CGFloat(segments.count * 24), 300))
      }
    }
    .padding(8)
    .background(Color.gray.opacity(0.05))
    .cornerRadius(8)
    .sheet(isPresented: $showNoteEditor) {
      if let segment = selectedSegment {
        TimeSegmentNoteView(segment: segment)
      }
    }
  }
}
