import Charts
import SwiftUI

struct ClockTimeData: Identifiable {
  let id = UUID()
  let name: String
  let time: TimeInterval
  let color: Color
  var isSelected: Bool = false
}

struct PieChartView: View {
  @Environment(GlobalEnvironment.self) private var viewModel
  @State private var selectedTime: TimeInterval?
  @State private var clockData: [ClockTimeData] = []

  let clocks: [Clock]?

  init(clocks: [Clock]? = nil) {
    self.clocks = clocks
  }

  private var sourceClocks: [Clock] {
    clocks ?? viewModel.clocks
  }

  private var sourceClockIds: [UUID] {
    sourceClocks.map(\.id)
  }

  private func updateClockData() {
    clockData = sourceClocks.map { clock in
      ClockTimeData(
        name: clock.name,
        time: clock.elapsedTime(),
        color: clock.color
      )
    }
  }

  var body: some View {
    VStack {
      Chart {
        ForEach(clockData) { data in
          SectorMark(
            angle: .value("Time", data.time),
            innerRadius: .ratio(0.618),
            angularInset: 1.0
          )
          .foregroundStyle(data.color)
          .cornerRadius(Theme.CornerRadius.small)
          .annotation(position: .overlay) {
            if data.isSelected {
              Text(data.name)
                .font(.title3)
                .bold()
                .foregroundStyle(.white)
                .padding(4)
                .background(Color.black.opacity(0.6))
                .cornerRadius(Theme.CornerRadius.small)
            }
          }
        }
      }
      .chartAngleSelection(value: $selectedTime)
    }
    .onChange(of: selectedTime) { _, newTime in
      if let time = newTime {
        var accumulatedTime: TimeInterval = 0
        for (index, clock) in clockData.enumerated() {
          let segmentStart = accumulatedTime
          let segmentEnd = accumulatedTime + clock.time
          clockData[index].isSelected = time >= segmentStart && time < segmentEnd
          accumulatedTime = segmentEnd
        }
      } else {
        // Reset all selections when no time is selected
        for index in clockData.indices {
          clockData[index].isSelected = false
        }
      }
    }
    .onAppear {
      updateClockData()
    }
    .onChange(of: sourceClockIds) { _, _ in
      updateClockData()
    }
  }
}

#Preview {
  PieChartView()
    .environment(GlobalEnvironment())
}
