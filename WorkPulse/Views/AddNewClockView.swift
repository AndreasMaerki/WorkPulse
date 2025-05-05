import SwiftUI

struct AddNewClockView: View {
  @Environment(GlobalEnvironment.self) private var viewModel
  @Environment(\.dismiss) var dismiss

  @State private var name = ""
  @State private var color: Color = .green

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text("Add new clock")
        .font(.headline)

      TextField("Clock name", text: $name)
        .frame(maxWidth: 180)
        .textFieldStyle(.plain)

      ColorPicker("Color", selection: $color)

      HStack {
        Button("Cancel") {
          dismiss()
        }
        .tint(.red)
        .buttonStyle(.plain)
        Button("Add Clock") {
          viewModel.addClock(name, color)
          dismiss()
        }
        .buttonStyle(.borderedProminent)
      }
    }
    .padding()
  }
}

#Preview {
  AddNewClockView()
    .environment(GlobalEnvironment())
}
