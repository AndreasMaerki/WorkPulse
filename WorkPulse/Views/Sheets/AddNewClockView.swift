import SwiftUI

struct AddNewClockView: View {
  @Environment(GlobalEnvironment.self) private var viewModel
  @Environment(\.dismiss) var dismiss

  @State private var name = ""
  @State private var color: Color = .green
  @State private var notes = ""

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      HStack {
        Image(systemName: "plus.circle.fill")
          .font(.title)
          .foregroundStyle(color)
        Text("Add new clock")
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
          viewModel.addClock(name, color, note: notes.isEmpty ? nil : notes)
          dismiss()
        } label: {
          HStack {
            Image(systemName: "plus.circle.fill")
            Text("Add Clock")
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
  AddNewClockView()
    .environment(GlobalEnvironment())
}
