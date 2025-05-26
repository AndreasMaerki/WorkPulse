import SwiftData
import SwiftUI

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(GlobalEnvironment.self) private var globalModel
  @Query private var items: [Item]

  @State var showSheet = false
  @State var runningSegment: TimeSegment?
  @State var editingClock: Clock?

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
              .contextMenu {
                Button {
                  editingClock = clock
                } label: {
                  Label("Edit Clock", systemImage: "pencil")
                }

                Button(role: .destructive) {
                  globalModel.deleteClock(clock)
                } label: {
                  Label("Delete", systemImage: "trash")
                }
              }
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
            SettingsView()
          } label: {
            settings
          }
        }
      }
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
      .toolbar {
        ToolbarItem {
          Button(action: { showSheet.toggle() }) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $showSheet) {
        AddNewClockView()
      }
      .sheet(item: $editingClock) { clock in
        AddNewClockView(clock: clock)
      }
      .sheet(item: $runningSegment) { segment in
        RunningSegmentView(segment: segment)
      }
      .onAppear {
        checkForRunningTimeSegments()
      }
    } detail: {
      DashboardView()
    }
  }

  var settings: some View {
    LabeledContent {
      Image(systemName: "gear")
    } label: {
      Text("Settings")
    }
  }

  private func checkForRunningTimeSegments() {
    // Only check the first time app launches
    guard runningSegment == nil else { return }
    runningSegment = globalModel.findRunningTimeSegment()
  }
}

#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
    .environment(GlobalEnvironment())
}
