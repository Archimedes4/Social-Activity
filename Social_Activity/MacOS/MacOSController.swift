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

struct MacOSController: View {
	@StateObject var gitHubEmojis = GitHubEmoji()
	@State var handle: AuthStateDidChangeListenerHandle? = nil
	@State var currentAuthState: authState = authState.noAuth
	var body: some View {
		VStack {
			if (currentAuthState == authState.signedIn) {
				HomeView(gitHubEmojis: gitHubEmojis)
			} else {
				LoginView()
			}
		}
		.onAppear() {
			handle = Auth.auth().addStateDidChangeListener { auth, user in
				if (user !== nil) {
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
    MacOSController()
}
