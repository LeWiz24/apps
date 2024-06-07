//
//  AuthManager.swift
//  FireChat
//

import Foundation
import FirebaseAuth

@Observable
class AuthManager {

    var user: User?
    let isMocked: Bool

    var userEmail: String? {

        // If mocked, return a mocked email string, otherwise return the users email if available
        isMocked ? "kingsley@dog.com" : user?.email
    }

    init(isMocked: Bool = false) {
        self.isMocked = isMocked
        // Persist login if current user exists
        // https://firebase.google.com/docs/auth/ios/manage-users#get_the_currently_signed-in_user
        user = Auth.auth().currentUser
    }

    // https://firebase.google.com/docs/auth/ios/start#sign_up_new_users
    func signUp(email: String, password: String) {
        Task {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                user = authResult.user
            } catch {
                print(error)
            }
        }

    }

    // https://firebase.google.com/docs/auth/ios/start#sign_in_existing_users
    func signIn(email: String, password: String) {
        Task {
            do {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                user = authResult.user
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            print(error.localizedDescription)
        }
    }
}
