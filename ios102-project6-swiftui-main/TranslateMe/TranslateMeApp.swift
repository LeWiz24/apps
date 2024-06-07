//
//  TranslateMeApp.swift
//  TranslateMe
//
//  Created by Mario Olivares on 2/12/24.
//

import SwiftUI
import FirebaseCore

@main
struct TranslateMeApp: App {
    
    init() { // <-- Add an init
        FirebaseApp.configure() // <-- Configure Firebase app
    }
    
    var body: some Scene {
        WindowGroup {
            TranslationView()
        }
    }
}

