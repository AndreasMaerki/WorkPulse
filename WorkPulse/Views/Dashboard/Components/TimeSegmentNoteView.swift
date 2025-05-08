import SwiftUI

struct TimeSegmentNoteView: View {
  let segment: TimeSegment
  @Environment(\.dismiss) private var dismiss
  @State private var note: String

  init(segment: TimeSegment) {
    self.segment = segment
    _note = State(initialValue: segment.note ?? "")
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Add Note")
        .font(.headline)

      TextEditor(text: $note)
        .frame(height: 100)
        .padding(4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)

      HStack {
        Button("Cancel") {
          dismiss()
        }
        .buttonStyle(.plain)

        Spacer()

        Button("Save") {
          segment.note = note.isEmpty ? nil : note
          dismiss()
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .padding()
    .frame(width: 300)
  }
}
