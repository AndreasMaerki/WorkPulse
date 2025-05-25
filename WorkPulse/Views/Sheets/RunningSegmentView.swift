import SwiftUI

struct RunningSegmentView: View {
  let segment: TimeSegment
  @Environment(\.dismiss) private var dismiss
  @Environment(GlobalEnvironment.self) private var globalEnvironment
  @State private var selectedEndTime = Date()

  init(segment: TimeSegment) {
    self.segment = segment
    _selectedEndTime = State(initialValue: segment.endTime ?? Date())
  }

  var body: some View {
    VStack(spacing: 16) {
      Text("Time Segment Still Running")
        .font(.headline)

      if let clock = segment.clock {
        HStack {
          Circle()
            .fill(clock.color)
            .frame(width: 12, height: 12)
          Text(clock.name)
            .foregroundStyle(.secondary)
        }
      }

      Text("Started: \(segment.startTime.shortDateTimeString)")
        .foregroundStyle(.secondary)

      Text("Elapsed: \(segment.elapsedTime(refTime: Date()).formattedHHMMSS())")
        .font(.title2)
        .monospacedDigit()

      Divider()

      Text("What would you like to do?")
        .font(.subheadline)

      VStack(spacing: 12) {
        Button {
          // Continue running
          if let clock = segment.clock {
            globalEnvironment.startTimer(clock, segment: segment)
          }
          dismiss()
        } label: {
          Label("Continue Tracking", systemImage: "play.circle")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)

        Button {
          // End tracking now
          segment.isRunning = false
          segment.endTime = Date()
          globalEnvironment.persistData()
          dismiss()
        } label: {
          Label("End Now", systemImage: "stop.circle")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)

        VStack(alignment: .leading, spacing: 4) {
          Text("Edit End Time (Defaults to seen last update):")
            .font(.subheadline)

          DatePicker("", selection: $selectedEndTime)
            .datePickerStyle(.compact)
            .labelsHidden()

          Button {
            // Set custom end time
            segment.isRunning = false
            segment.endTime = selectedEndTime
            globalEnvironment.persistData()
            dismiss()
          } label: {
            Label("Set Custom End Time", systemImage: "calendar")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
      }
    }
    .padding()
    .frame(width: 350)
    .interactiveDismissDisabled()
  }
}

#Preview {
  let segment = TimeSegment(id: UUID(), startTime: Date(), endTime: Date())
  RunningSegmentView(segment: segment)
    .environment(GlobalEnvironment())
}
