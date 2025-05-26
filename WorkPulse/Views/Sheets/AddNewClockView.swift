import SwiftUI

struct AddNewClockView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(GlobalEnvironment.self) private var viewModel

  private let clock: Clock?

  @State private var name: String
  @State private var color: Color
  @State private var notes: String

  init(clock: Clock? = nil) {
    self.clock = clock
    _name = State(initialValue: clock?.name ?? "")
    _color = State(initialValue: clock?.color ?? .green)
    _notes = State(initialValue: clock?.notes ?? "")
  }

  private var isEditing: Bool {
    clock != nil
  }

  private var isValid: Bool {
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      HStack {
        Image(systemName: "plus.circle.fill")
          .font(.title)
          .foregroundStyle(color)
        Text(isEditing ? "Edit clock" : "Add new clock")
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
          if isEditing, let clock {
            viewModel.updateClock(clock, name: name, color: color, notes: notes.isEmpty ? nil : notes)
          } else {
            viewModel.addClock(name, color, note: notes.isEmpty ? nil : notes)
          }
          dismiss()
        } label: {
          HStack {
            Image(systemName: isEditing ? "checkmark.circle.fill" : "plus.circle.fill")
            Text(isEditing ? "Save Changes" : "Add Clock")
          }
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
        .disabled(!isValid)
      }
      .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .padding(24)
    .frame(width: 400)
    .background(Color(NSColor.windowBackgroundColor))
  }
}

#Preview {
  AddNewClockView()
    .environment(GlobalEnvironment())
}
