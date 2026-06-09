import SwiftData
import SwiftUI

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(GlobalEnvironment.self) private var globalModel

  @State private var showSheet = false
  @State private var runningSegment: TimeSegment?
  @State private var editingClock: Clock?
  @State private var selection: SidebarSelection? = .dashboard

  enum SidebarSelection: Hashable {
    case dashboard
    case clock(UUID)
    case settings
  }

  var body: some View {
    NavigationSplitView {
      List(selection: $selection) {
        Section(header: Text("Dashboard")) {
          NavigationLink(value: SidebarSelection.dashboard) {
            Text("Dashboard")
          }
        }
        Section(header: Text("Clocks")) {
          ForEach(globalModel.clocks) { clock in
            NavigationLink(value: SidebarSelection.clock(clock.id)) {
              ClockRowView(clock: clock, showsStartStop: true)
            }
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
          NavigationLink(value: SidebarSelection.settings) {
            settings
          }
        }
      }
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
      .toolbar {
        ToolbarItem {
          Button("Add Clock", systemImage: "plus") { showSheet.toggle() }
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
        if selection == nil {
          selection = .dashboard
        }
      }
    } detail: {
      switch selection {
      case .dashboard,
           .none:
        DashboardView()
      case .settings:
        SettingsView()
      case let .clock(clockId):
        if let clock = globalModel.clocks.first(where: { $0.id == clockId }) {
          ClockDetailScreen(clock: clock)
        } else {
          Text("Clock not found")
            .foregroundStyle(.secondary)
        }
      }
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
    .environment(GlobalEnvironment())
}
