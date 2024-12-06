//
//  LoginView.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-11-21.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct PasswordButton: View {
	var onSuccess: () -> Void
	
	// Get an instance of WebAuthenticationSession using SwiftUI's
	// @Environment property wrapper.
	@Environment(\.webAuthenticationSession) private var webAuthenticationSession
	
	var body: some View {
		Button(action: {
			Task {
				let result = await authenticateUser()
				if (result) {
					onSuccess()
				}
			}
		}) {
			HStack {
				Image(systemName: "lock")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 25, height: 25)
				Text("Login")
					.foregroundStyle(.black)
			}
			.padding()
			.padding(.horizontal)
			.padding(.horizontal)
			.background(Color.white)
			.cornerRadius(12)
		}
		.focusEffectDisabled()
		.buttonStyle(.plain)
	}
}


struct PasswordView: View {
	var onSuccess: () -> Void
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
				PasswordButton(onSuccess: {
					onSuccess()
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
