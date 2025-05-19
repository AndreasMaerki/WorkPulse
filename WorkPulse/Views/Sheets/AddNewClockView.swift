import SwiftUI

struct ClockFormView: View {
  @Environment(GlobalEnvironment.self) private var viewModel
  @Environment(\.dismiss) var dismiss

  let clock: Clock?
  let onSave: (String, Color, String?) -> Void

  @State private var name: String
  @State private var color: Color
  @State private var notes: String

  init(clock: Clock? = nil, onSave: @escaping (String, Color, String?) -> Void) {
    self.clock = clock
    self.onSave = onSave

    // Initialize state with clock values if editing, or defaults if creating
    _name = State(initialValue: clock?.name ?? "")
    _color = State(initialValue: clock?.color ?? .green)
    _notes = State(initialValue: clock?.notes ?? "")
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      HStack {
        Image(systemName: "plus.circle.fill")
          .font(.title)
          .foregroundStyle(color)
        Text(clock == nil ? "Add new clock" : "Edit clock")
          .font(.title2)
          .fontWeight(.semibold)
      }
      .padding(.bottom, 8)

      VStack(alignment: .leading) {
        Text("Clock name")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        TextField("Enter a name for your clock", text: $name)
          .textFieldStyle(.roundedBorder)
          .frame(maxWidth: 300)
      }

      VStack(alignment: .leading) {
        Text("Color")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        ColorPicker("", selection: $color)
          .labelsHidden()
          .scaleEffect(1.2)
      }

      VStack(alignment: .leading) {
        Text("Notes (optional)")
          .font(.subheadline)
          .foregroundStyle(.secondary)

        TextEditor(text: $notes)
          .frame(height: 80)
          .textEditorStyle(.automatic)
          .frame(maxWidth: 300)
      }

      HStack(spacing: 16) {
        Button("Cancel") {
          dismiss()
        }
        .buttonStyle(.bordered)
        .tint(.red)

        Button {
          onSave(name, color, notes.isEmpty ? nil : notes)
          dismiss()
        } label: {
          HStack {
            Image(systemName: clock == nil ? "plus.circle.fill" : "checkmark.circle.fill")
            Text(clock == nil ? "Add Clock" : "Save Changes")
          }
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
        .disabled(name.isEmpty)
      }
      .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .padding(24)
    .frame(width: 400)
    .background(Color(NSColor.windowBackgroundColor))
  }
}

#Preview {
  ClockFormView { name, color, notes in
    print("Creating clock: \(name), \(color), \(notes ?? "no notes")")
  }
  .environment(GlobalEnvironment())
}
