//
//  WorkPulseApp.swift
//  WorkPulse
//
//  Created by Andreas Maerki on 04.05.2025.
//

import SwiftUI
import SwiftData

@main
struct WorkPulseApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Clock.self,
      TimeSegment.self,
      ColorComponents.self
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
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(globalEnvironment)
    }
    .modelContainer(sharedModelContainer)
  }
}
