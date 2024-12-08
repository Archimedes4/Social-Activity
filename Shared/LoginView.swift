//
//  LoginView.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-11-21.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct LoginButton: View {
	var onToken: (_ token: String) -> Void
	// Get an instance of WebAuthenticationSession using SwiftUI's
	// @Environment property wrapper.
	@Environment(\.webAuthenticationSession) private var webAuthenticationSession
	
	var body: some View {
		Button(action: {
			Task {
				do {
					// Perform the authentication and await the result.
					let urlWithToken = try await webAuthenticationSession.authenticate(
						using: URL(string: gitHubAuthLink)!,
							callbackURLScheme: "com.Archimedes4.SocialActivity.iOS"
					)
					let queryItems = URLComponents(string: urlWithToken.absoluteString)?.queryItems
					guard let code = queryItems?.first(where: { $0.name == "code" })?.value else {
						return
					}
					let token = try await getAuthToken(code: code)
					let credential = OAuthProvider.credential(providerID: AuthProviderID.gitHub, accessToken: token)
					Auth.auth().signIn(with: credential) { authResult, error in
						if error != nil {
							// Handle error.
							print("error", error)
						}
						print("All good", token)
						onToken(token)
						// User is signed in.
						// IdP data available in authResult.additionalUserInfo.profile.

						guard let oauthCredential = authResult?.credential else { return }
						// GitHub OAuth access token can also be retrieved by:
						// oauthCredential.accessToken
						// GitHub OAuth ID token can be retrieved by calling:
						// oauthCredential.idToken
					}
				} catch let error {
					print(error)
					// Respond to any authorization errors.
				}
			}
		}) {
			HStack {
				Image("github-mark-white")
					.resizable()
					.frame(width: 25, height: 25)
				Text("Sign in with GitHub")
					.foregroundStyle(.white)
			}
			.padding()
			.background(Color.black)
			.cornerRadius(12)
		}
		.focusEffectDisabled()
		.buttonStyle(.plain)
	}
}


struct LoginView: View {
	var onToken: (_ token: String) -> Void
    var body: some View {
			VStack {
				Spacer()
				HStack {
					Image("Logo")
						.resizable()
						.frame(width: 50, height: 50)
						.cornerRadius(12)
					Text("Social Activity")
						.font(Font.custom("Nunito-Regular", size: 32))
						.foregroundStyle(.white)
				}.padding(.bottom)
				LoginButton(onToken: { token in
					onToken(token)
				})
				Text("By Andrew Mainella")
					.font(Font.custom("Nunito-Regular", size: 16))
					.foregroundStyle(.white)
					.padding(.top)
				Spacer()
			}
			.ignoresSafeArea(.all)
			.frame(maxWidth: .infinity, maxHeight: .infinity).background(
				LinearGradient(stops: [
					Gradient.Stop(color: Color("BlueOne"), location: 0.14),
					Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
					Gradient.Stop(color: Color("GreenOne"), location: 0.87),
				], startPoint: .topTrailing, endPoint: .bottomLeading)
			)
    }
}
