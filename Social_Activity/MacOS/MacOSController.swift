//
//  MacOSController.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-11-21.
//

import SwiftUI
import FirebaseAuth

enum authState {
	case noAuth, signedIn
}

struct Controller: View {
	@StateObject var gitHubEmojis = GitHubEmoji()
	@State var handle: AuthStateDidChangeListenerHandle? = nil
	@State var currentAuthState: authState = authState.noAuth
	@State var token: String = ""
	
	var body: some View {
		VStack {
			if (currentAuthState == authState.signedIn) {
				HomeView(token: $token, gitHubEmojis: gitHubEmojis)
			} else {
				LoginView()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.onAppear() {
			handle = Auth.auth().addStateDidChangeListener { auth, user in
				if (user !== nil) {
					guard let tokenRes = KeychainService().retriveSecret(id: "gitauth") else {
						return
					}
					token = tokenRes
					currentAuthState = authState.signedIn
				} else {
					currentAuthState = authState.noAuth
				}
			 }
		 }
		 .onDisappear() {
			 Auth.auth().removeStateDidChangeListener(handle!)
		 }
	}
}

#Preview {
	Controller()
}
