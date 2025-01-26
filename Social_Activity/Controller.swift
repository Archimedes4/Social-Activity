//
//  MacOSController.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-11-21.
//

import SwiftUI
import FirebaseAuth

enum authState {
	case noAuth, signedIn, password, loading
}

struct Controller: View {
	@State var handle: AuthStateDidChangeListenerHandle? = nil
	@State var currentAuthState: authState = authState.loading
	@StateObject var homeData: HomeData = HomeData()
	
	var body: some View {
		VStack {
			if (currentAuthState == authState.signedIn) {
				HomeView()
			} else if (currentAuthState == authState.noAuth) {
				LoginView(onToken: { result in
					homeData.token = result
					guard let tokenRes = KeychainService().retriveSecret(id: "gitauth") else {
						currentAuthState = authState.signedIn
						KeychainService().save(homeData.token, for: "gitauth")
						return
					}
					if (tokenRes == "no-persistence") {
						currentAuthState = authState.signedIn
					} else {
						currentAuthState = authState.signedIn
						KeychainService().save(homeData.token, for: "gitauth")
					}
				})
			} else if (currentAuthState == authState.password) {
				PasswordView(onSuccess: {
					currentAuthState = authState.signedIn
				})
			} else {
				VStack {
					ProgressView()
				}.ignoresSafeArea(.all)
				.frame(maxWidth: .infinity, maxHeight: .infinity).background(
					LinearGradient(stops: [
						Gradient.Stop(color: Color("BlueOne"), location: 0.14),
						Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
						Gradient.Stop(color: Color("GreenOne"), location: 0.87),
					], startPoint: .topTrailing, endPoint: .bottomLeading)
				)
				
			}
		}
		.environmentObject(homeData)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.onAppear() {
			var isPassProtect = false
			// Get the value if the token is being saved.
			let protectedVal = KeychainService().retriveSecret(id: "protected")
			if (protectedVal == "protected") {
				isPassProtect = true
			} else {
				isPassProtect = false
			}
			handle = Auth.auth().addStateDidChangeListener { auth, user in
				if (user !== nil) {
					guard let tokenRes = KeychainService().retriveSecret(id: "gitauth") else {
						return
					}
					if (tokenRes == "no-persistence") {
						currentAuthState = authState.noAuth
					} else {
						homeData.token = tokenRes
						if (isPassProtect) {
							currentAuthState = authState.password
						} else {
							currentAuthState = authState.signedIn
						}
					}
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
