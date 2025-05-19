import SwiftData
import SwiftUI

@main
struct WorkPulseApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Clock.self,
      TimeSegment.self,
      ColorComponents.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  @State var globalEnvironment: GlobalEnvironment

  init() {
    let context = sharedModelContainer.mainContext
    _globalEnvironment = State(initialValue: GlobalEnvironment(modelContext: context))
    print(URL.documentsDirectory.path())
  }

  var body: some Scene {
    WindowGroup(id: "WorkPulse") {
      ContentView()
        .environment(globalEnvironment)
    }
    .modelContainer(sharedModelContainer)

    MenuBarExtra("WorkPulse", systemImage: "clock") {
      MenuBarView()
        .environment(globalEnvironment)
    }
    .menuBarExtraStyle(.window)
  }
}
