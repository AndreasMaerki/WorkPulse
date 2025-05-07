import SwiftUI

struct DashboardView: View {
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var expandedClockId: UUID? = nil
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      HStack {
        Text("Dashboard")
          .font(.largeTitle)
        Spacer()
      }

      // Total time section
      VStack(alignment: .leading, spacing: 8) {
        Text("Total Time")
          .font(.headline)
        Text(viewModel.elapsedTime.formattedHHMMSS())
          .font(.title)
          .monospacedDigit()
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .cornerRadius(8)

      // Individual clocks section
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Text("Clocks")
            .font(.headline)

          ForEach(viewModel.clocks) { clock in
            ClockDetailView(
              clock: clock,
              isExpanded: Binding(
                get: { expandedClockId == clock.id },
                set: { isExpanded in
                  withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    expandedClockId = isExpanded ? clock.id : nil
                  }
                }
              )
            )
          }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
      }

      Spacer()
    }
    .padding()
  }
}

#Preview {
  DashboardView()
    .environment(GlobalEnvironment())
}
