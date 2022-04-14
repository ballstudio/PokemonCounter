//
//  PokemonCounterApp.swift
//  Shared
//
//  Created by Mictel on 2022/4/2.
//

import SwiftUI

@main
struct PokemonCounterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
