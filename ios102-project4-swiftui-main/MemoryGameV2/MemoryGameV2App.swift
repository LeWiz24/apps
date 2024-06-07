//
//  MemoryGameV2App.swift
//  MemoryGameV2
//
//  Created by Mario Olivares on 10/18/23.
//

import SwiftUI

@main
struct MemoryGameV2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView(game: MemoryGame())
        }
    }
}
