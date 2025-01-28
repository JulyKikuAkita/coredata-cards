//
//  FlashCardsApp.swift
//  FlashCards
//
//  Created by IFang Lee on 1/27/25.
//

import SwiftUI

@main
struct FlashCardsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
