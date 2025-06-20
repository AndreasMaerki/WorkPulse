import SwiftUI

struct ExpandableDayView: View {
  let day: Date
  let dayName: String
  let segments: [TimeSegment]
  @Binding var isExpanded: Bool
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var selectedSegment: TimeSegment?
  @State private var showNoteEditor = false

  private var totalDayTime: TimeInterval {
    segments.reduce(0) { result, segment in
      result + segment.elapsedTime(refTime: Date())
    }
  }

  private var listHeight: CGFloat {
    let baseHeight: CGFloat = 24 // Base height for each segment
    let noteHeight: CGFloat = 32 // Extra height for segments with notes
    let maxHeight: CGFloat = 300 // Maximum height of the list

    let totalHeight = segments.reduce(0) { result, segment in
      result + baseHeight + (segment.note != nil ? noteHeight : 0)
    }

    return min(totalHeight, maxHeight)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      dayOpeningButton

      if isExpanded {
        List {
          ForEach(segments) { segment in
            timeSegment(segment)
          }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .frame(height: listHeight)
      }
    }
    .padding(8)
    .secondaryCardBackground()
    .sheet(isPresented: $showNoteEditor) {
      if let segment = selectedSegment {
        TimeSegmentNoteView(segment: segment)
      }
    }
  }

  private var dayOpeningButton: some View {
    Button(action: { isExpanded.toggle() }) {
      HStack {
        Text(dayName)
          .font(.subheadline)
          .foregroundStyle(.secondary)
        Spacer()
        Text(totalDayTime.formattedHHMMSS())
          .font(.subheadline)
          .monospacedDigit()
          .foregroundStyle(.primary)
        Image(systemName: "chevron.right")
          .foregroundStyle(.secondary)
          .rotationEffect(.degrees(isExpanded ? 90 : 0))
      }
      .padding(.vertical, 4)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  private func timeSegment(_ segment: TimeSegment) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        Text(segment.startTime.shortTimeString)
          .foregroundStyle(.secondary)
        Text("-")
          .foregroundStyle(.secondary)
        Text((segment.isRunning ? "Running" : segment.endTime?.shortTimeString ?? ""))
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
      handleSegmentDoubleTap(segment)
    }
    .swipeActions(edge: .trailing) {
      Button(role: .destructive) {
        deleteTimeSegment(segment)
      } label: {
        Label("Delete", systemImage: "trash")
      }
    }
  }

  private func handleSegmentDoubleTap(_ segment: TimeSegment) {
    selectedSegment = segment
    showNoteEditor = true
  }

  private func deleteTimeSegment(_ segment: TimeSegment) {
    if let clock = segment.clock {
      viewModel.deleteTimeSegment(segment, from: clock)
    }
  }
}
