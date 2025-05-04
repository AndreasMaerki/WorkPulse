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
      Item.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  @State var globalEnvironment =  GlobalEnvironment()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(globalEnvironment)
    }
    .modelContainer(sharedModelContainer)
  }
}
