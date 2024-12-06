//
//  AppMenu.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-01-05.
//

import SwiftUI


struct MenuExtensionMain: View {
	@Binding var token: String
	@Binding var profile: UserData?
	@Binding var statusItems: [StatusInformation]
	@Environment(\.openURL) var openURL
	
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				Button(action: {
					guard let username = profile?.username else {
						return
					}
					guard let url = URL(string: "https://github.com/" + username) else {
						return
					}
					openURL(url)}) {
						if (profile != nil) {
							AsyncImage(url: URL(string: profile!.advatar)) { image in
								image.resizable()
							} placeholder: {
								ProgressView()
							}
							.frame(width: 25, height: 25)
							.cornerRadius(15)
						} else {
							ProgressView()
								.frame(width: 25, height: 25)
						}
				}.buttonStyle(.plain)
				Spacer()
				if (profile != nil) {
					Text("Hello, \(profile!.username)")
				}
				Spacer()
				Button(action: {
					guard let url = URL(string: "com.Archimedes4.SocialActivity") else {
						return
					}
					openURL(url)
				}) {
					Image("Logo")
						.resizable()
						.frame(width: 25, height: 25)
						.cornerRadius(7)
				}.buttonStyle(.plain)
			}.padding([.horizontal, .top])
			.padding(.bottom, 7)
			Divider()
				.padding(.horizontal)
			List() {
				ForEach(statusItems) {item in
					StatusButton(text: item.name, emoji: item.emoji, active: false, token: $token)
						.listRowSeparator(.hidden)
						.listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
				}
				ClearButton(token: $token)
					.listRowSeparator(.hidden)
					.listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
			}
		}
	}
}

struct AppMenu: View {
	@State var isAuth = false
	@State var isLoading = true
	@State var validToken = false
	@State var newSecret = ""
	@State var token = ""
	@State var appPasswordProtected: Bool = true
	@State var profile: UserData? = nil
	@State var statusItems: [StatusInformation] = []
	
	func loadUser() async {
		guard let tokenRes = KeychainService().retriveSecret(id: "gitauth") else {
			return
		}
		token = tokenRes
		profile = await getUserData(token: token)
		validToken = true
		isLoading = false
	}
	
	var body: some View {
		if (!isAuth && appPasswordProtected) {
			Button(action: {
				Task {
					isAuth = await authenticateUser()
				}
			}, label: {
				Text("Login")
					.padding()
			}).onAppear() {
				// Get the value if the token is being saved.
				let protectedVal = KeychainService().retriveSecret(id: "protected")
				if (protectedVal == "protected") {
					appPasswordProtected = true
				} else {
					appPasswordProtected = false
				}
			}
		} else if (isLoading) {
			ProgressView()
				 .onAppear {
					 Task {
						 await loadUser()
					 }
					 Task {
						 guard let result = await getStatusInformation() else {
							 return
						 }
						 statusItems = result
					 }
				 }
		 } else if (validToken) {
			 MenuExtensionMain(token: $token, profile: $profile, statusItems: $statusItems)
		 } else {
			 Text("Someting went wrong.")
		 }
	}
}
