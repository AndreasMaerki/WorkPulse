import SwiftData
import SwiftUI

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(GlobalEnvironment.self) private var globalModel
  @Query private var items: [Item]

  @State var showSheet = false

  var body: some View {
    NavigationSplitView {
      List {
        Section(header: Text("Dashboard")) {
          NavigationLink {
            DashboardView()
          } label: {
            Text("Dashboard")
          }
        }
        Section(header: Text("Clocks")) {
          ForEach(globalModel.clocks) { clock in
            ClockRowView(clock: clock)
              .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                  globalModel.deleteClock(clock)
                } label: {
                  Label("Delete", systemImage: "trash")
                }
              }
          }
        }
        Section(header: Text("More")) {
          NavigationLink {
            Text("Settings")
          } label: {
            settings
          }
        }
      }
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
      .toolbar {
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $showSheet) {
        AddNewClockView()
      }
    } detail: {
      Text("Select an item")
    }
  }

  var settings: some View {
    LabeledContent {
      Image(systemName: "gear")
    } label: {
      Text("Settings")
    }
  }

  private func addItem() {
    showSheet.toggle()
  }
}

struct ClockRowView: View {
  @Environment(GlobalEnvironment.self) private var globalModel
  let clock: Clock

  var body: some View {
    Button {
      toggleClock()
    } label: {
      LabeledContent {
        Image(systemName: "hourglass")
          .font(.title2)
          .padding(.horizontal, 4)
          .foregroundStyle(clock.color)
      } label: {
        HStack {
          Text(clock.elapsedTime().formattedHHMMSS())
            .monospaced(true)
            .foregroundStyle(.white)
            .padding(6)
            .background(
              RoundedRectangle(cornerRadius: 4)
                .fill(globalModel.activeClock?.id == clock.id ? clock.color : .clear)
            )
          Text(clock.name)
        }
      }
    }
    .buttonStyle(.plain)
    .background(Color.secondary.opacity(0.1).cornerRadius(4))
  }

  private func toggleClock() {
    if globalModel.activeClock?.id == clock.id {
      globalModel.stopTimer()
    } else {
      globalModel.startTimer(clock)
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
    .environment(GlobalEnvironment())
}
