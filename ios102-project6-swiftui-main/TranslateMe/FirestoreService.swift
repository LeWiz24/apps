//
//  FirestoreService.swift
//  TranslateMe
//
//  Created by Mario Olivares on 3/24/24.
//
import Foundation

import FirebaseFirestore

class FirestoreService {
    private let db = Firestore.firestore()
    
    // Fetch all translations
    func fetchTranslations(completion: @escaping ([Translation]) -> Void) {
        db.collection("translations").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let translations = documents.compactMap { doc -> Translation? in
                try? doc.data(as: Translation.self)
            }
            completion(translations)
        }
    }
    
    // Add a new translation
    func addTranslation(_ translation: Translation) {
        do {
            _ = try db.collection("translations").addDocument(from: translation)
        } catch let error {
            print("Error writing translation to Firestore: \(error.localizedDescription)")
        }
    }
    
    // Example method to delete a translation (if needed)
    func deleteTranslation(_ translationId: String) {
        db.collection("translations").document(translationId).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func clearAllTranslations() {
        let collectionRef = db.collection("translations")
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    collectionRef.document(document.documentID).delete { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                }
            }
        }
    }

}

