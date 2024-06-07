//
//  FireChatApp.swift
//  FireChat
//

import SwiftUI
import FirebaseCore

@main
struct FireChatApp: App {

    @State private var authManager: AuthManager

    init() {
        FirebaseApp.configure()
        authManager = AuthManager()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.user != nil {

                // We have a logged in user, go to ChatView
                ChatView()
                    .environment(authManager)
            } else {

                // No logged in user, go to LoginView
                LoginView()
                    .environment(authManager)
            }
        }
    }
}
