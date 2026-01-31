import SwiftUI

struct ExpandableDayView: View {
  let day: Date
  let dayName: String
  let segments: [TimeSegment]
  @Binding var isExpanded: Bool
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var selectedSegment: TimeSegment?
  @State private var showNoteEditor = false
  @State private var listContentHeight: CGFloat = 0

  private var totalDayTime: TimeInterval {
    segments.reduce(0) { result, segment in
      result + segment.elapsedTime(refTime: Date())
    }
  }

  private var listHeight: CGFloat {
    let maxHeight: CGFloat = 300 // Maximum height of the list

    return min(listContentHeight, maxHeight)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      dayOpeningButton

      if isExpanded {
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(segments) { segment in
              timeSegment(segment)
            }
          }
          .background(
            GeometryReader { proxy in
              Color.clear
                .onAppear {
                  withAnimation(.easeInOut(duration: 0.2)) {
                    listContentHeight = proxy.size.height
                  }
                }
                .onChange(of: proxy.size.height) { _, newValue in
                  withAnimation(.easeInOut(duration: 0.2)) {
                    listContentHeight = newValue
                  }
                }
            }
          )
        }
        .frame(height: listHeight)
      }
    }
    .padding(8)
    .secondaryCardBackground()
    .onChange(of: isExpanded) { _, expanded in
      if !expanded {
        withAnimation(.easeInOut(duration: 0.2)) {
          listContentHeight = 0
        }
      }
    }
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
          .font(.callout)
          .foregroundStyle(.secondary)
        Spacer()
        Text(totalDayTime.formattedHHMMSS())
          .font(.callout)
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

        editButton(segment)

        Text(segment.elapsedTime(refTime: Date()).formattedHHMMSS())
          .monospacedDigit()
      }
      .font(.callout)

      if let note = segment.note {
        Text(note)
          .font(.footnote)
          .foregroundStyle(.secondary)
          .lineLimit(2)
          .padding(.leading)
      }
    }
    .padding(.vertical, 4)
    .padding(.leading, 24)
    .padding(.trailing, 8)
    .swipeActions(edge: .trailing) {
      Button(role: .destructive) {
        deleteTimeSegment(segment)
      } label: {
        Label("Delete", systemImage: "trash")
      }
    }
  }

  private func editButton(_ segment: TimeSegment) -> some View {
    Button {
      handleSegmentEdit(segment)
    } label: {
      Image(systemName: "pencil")
        .bold()
        .font(.body)
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .tint(.accentColor)
    .help("Edit note")
  }

  private func handleSegmentEdit(_ segment: TimeSegment) {
    selectedSegment = segment
    showNoteEditor = true
  }

  private func deleteTimeSegment(_ segment: TimeSegment) {
    if let clock = segment.clock {
      viewModel.deleteTimeSegment(segment, from: clock)
    }
  }
}

#Preview {
  ExpandableDayView(
    day: Calendar.current.startOfDay(for: Date()),
    dayName: Date().formattedForTimeSegment(),
    segments: TimeSegment.mockSegments(
      for: Clock(name: "Deep Work", color: .blue, notes: "Focus blocks")
    ),
    isExpanded: .constant(true)
  )
  .environment(GlobalEnvironment())
  .padding()
}
