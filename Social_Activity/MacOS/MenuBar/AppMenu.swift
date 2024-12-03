//
//  AppMenu.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-01-05.
//

import SwiftUI

struct AppMenu: View {
	@State var isAuth = false
	@State var isLoading = true
	@State var validToken = false
	@State var newSecret = ""
	@State var username = ""
	@State var token = ""
	@State var statusItems: [StatusInformation] = []
	@State var advatar = "https://avatars.githubusercontent.com/u/82121191?u=25181e386cc5fa9ec942cf4c41f825b72ff91c3c&v=4"
	@Environment(\.openURL) var openURL
	
	func loadUser() async {
		do {
			guard let tokenRes = KeychainService().retriveSecret(id: "gitauth") else {
				return
			}
			token = tokenRes
			username = try await validateToken(token: tokenRes)
			validToken = true
			isLoading = false
		} catch  {
			print("failed")
			isLoading = false
		}
	}
	
	var body: some View {
		if (!isAuth) {
			Button(action: {
				Task {
					isAuth = await authenticateUser()
				}
			}, label: {
				Text("Login")
					.padding()
			})
		} else {
			if (isLoading) {
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
				VStack(spacing: 0) {
					HStack {
						Button(action: {
							guard let url = URL(string: "https://github.com/" + username) else {
								return
							}
							openURL(url)}) {
							AsyncImage(url: URL(string: advatar)) { image in
								image.resizable()
							} placeholder: {
								Color.red
							}
							.frame(width: 25, height: 25)
							.cornerRadius(15)
						}.buttonStyle(.plain)
						Spacer()
						Text("Hello, \(username)")
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
			} else {
				
			}
		}
	}
}
