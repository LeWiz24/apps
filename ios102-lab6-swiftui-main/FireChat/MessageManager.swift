//
//  MessageManager.swift
//  FireChat
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@Observable // <-- Add the Observable macro
class MessageManager {

    var messages: [Message] = []

    private let dataBase = Firestore.firestore()

    init(isMocked: Bool = false) {
        if isMocked {
            messages = Message.mockedMessages
        } else {
            // TODO: Fetch messages from Firestore database
            getMessages()

        }
    }

    // TODO: Save message
    func getMessages() {
        dataBase.collectionGroup("messages").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }

            let messages = documents.compactMap { document in
                do {
                    return try document.data(as: Message.self)
                } catch {
                    print("Error decoding document into message: \(error)")
                    return nil
                }
            }

            self.messages = messages.sorted(by: { $0.timestamp < $1.timestamp })
        }
    }

    // TODO: Get messages
    func sendMessage(text: String, username: String) {
        do {
            let message = Message(id: UUID().uuidString, text: text, timestamp: Date(), username: username)
            try dataBase.collection("messages").document().setData(from: message)

        } catch {
            print("Error sending message to Firestore: \(error)")
        }
    }
}
