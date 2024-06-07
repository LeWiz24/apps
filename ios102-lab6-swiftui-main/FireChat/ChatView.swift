//
//  ChatView.swift
//  FireChat
//

import SwiftUI

struct ChatView: View {

    @Environment(AuthManager.self) var authManager
    @State var messageManager: MessageManager

    init(isMocked: Bool = false) {
        messageManager = MessageManager(isMocked: isMocked)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(messageManager.messages) { message in
                        MessageRow(text: message.text, isOutgoing: authManager.userEmail == message.username)
                    }
                }
            }
            .defaultScrollAnchor(.bottom)
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button("Sign out") {
                        authManager.signOut()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                SendMessageView { messageText in
                    // TODO: Save message to Firestore
                    messageManager.sendMessage(text: messageText, username: authManager.userEmail ?? "")
                }
            }
        }
    }
}

struct MessageRow: View {
    let text: String
    let isOutgoing: Bool

    var body: some View {
        HStack {
            if isOutgoing {
                Spacer()
            }
            messageBubble
            if !isOutgoing {
                Spacer()
            }
        }
    }

    private var messageBubble: some View {
        Text(text)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundStyle(isOutgoing ? .white : .primary)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20.0)
                    .fill(isOutgoing ? Color.blue.gradient : Color(.systemGray5).gradient)
            )
            .padding(isOutgoing ? .trailing : .leading, 12)
            .containerRelativeFrame(.horizontal, count: 7, span: 5, spacing: 0, alignment: isOutgoing ? .trailing : .leading)
    }
}

struct SendMessageView: View {
    var onSend: (String) -> Void

    @State private var messageText: String = ""

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TextField("Message", text: $messageText, axis: .vertical)
                .padding(.leading)
                .padding(.trailing, 4)
                .padding(.vertical, 8)

            Button {
                onSend(messageText)
                messageText = ""
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .bold()
                    .padding(4)
            }
            .disabled(messageText.isEmpty)
        }
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(Color(uiColor: .systemGray2)))
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.thickMaterial)
        //        .focused($isMessageFieldFocused)
    }
}

#Preview {
    ChatView(isMocked: true)
        .environment(AuthManager(isMocked: true))
}
