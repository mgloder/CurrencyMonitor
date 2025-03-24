//
//  MultiCurrencyMonitorApp.swift
//  MultiCurrencyMonitor
//
//  Created by Yan Xu on 24/3/2025.
//

import SwiftUI
import SwiftData

@main
struct MultiCurrencyMonitorApp: App {
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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
