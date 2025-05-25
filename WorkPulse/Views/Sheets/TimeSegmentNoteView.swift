import SwiftUI

struct TimeSegmentNoteView: View {
  let segment: TimeSegment
  @Environment(\.dismiss) private var dismiss
  @Environment(GlobalEnvironment.self) private var globalEnvironment
  @State private var note: String
  @State private var selectedStartTime: Date
  @State private var selectedEndTime: Date
  @State private var showInvalidTimeAlert = false

  init(segment: TimeSegment) {
    self.segment = segment
    _note = State(initialValue: segment.note ?? "")
    _selectedStartTime = State(initialValue: segment.startTime)
    _selectedEndTime = State(initialValue: segment.endTime ?? Date())
  }

  private var isTimeValid: Bool {
    selectedEndTime > selectedStartTime
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Edit Time Segment")
        .font(.headline)

      startTimePicker

      endTimePicker

      VStack(alignment: .leading, spacing: 8) {
        Text("Note")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        TextEditor(text: $note)
          .frame(height: 100)
          .padding(4)
          .background(Color.gray.opacity(0.1))
          .cornerRadius(8)
      }

      HStack {
        Button("Cancel") {
          dismiss()
        }
        .buttonStyle(.plain)

        Spacer()

        Button("Save") {
          if isTimeValid {
            save()
            dismiss()
          } else {
            showInvalidTimeAlert = true
          }
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .padding()
    .frame(width: 300)
    .alert("Invalid Time Range", isPresented: $showInvalidTimeAlert) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("End time must be after start time.")
    }
  }

  private var startTimePicker: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Start Time")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      DatePicker("", selection: $selectedStartTime)
        .datePickerStyle(.compact)
        .labelsHidden()
    }
  }

  private var endTimePicker: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("End Time")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      DatePicker("", selection: $selectedEndTime)
        .datePickerStyle(.compact)
        .labelsHidden()
    }
  }

  private func save() {
    segment.note = note.isEmpty ? nil : note
    segment.startTime = selectedStartTime
    segment.endTime = selectedEndTime
    globalEnvironment.persistData()
  }
}
