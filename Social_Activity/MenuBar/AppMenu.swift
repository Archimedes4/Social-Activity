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
	@State var active = ""
	
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
							do {
								username = try await validateToken()
								isLoading = false
								validToken = true
							} catch {
								isLoading = false
								validToken = false
							}
						}
					}
			} else if (validToken) {
				VStack {
					Text("Welcome, \(username)")
						.padding(.top)
					Divider()
					
					StatusButton(text: "On Vaction", emoji: "palm_tree", active: $active)
					StatusButton(text: "Sleeping", emoji: "sleeping", active: $active)
					StatusButton(text: "Coding", emoji: "man_technologist", active: $active)
					StatusButton(text: "In Class", emoji: "school_satchel", active: $active)
					Button(action: {
							Task {
									await clearStatus()
							}
					}, label: { Text("Clear Status") })
				}.padding(.horizontal)
			} else {
				TextField("GitHub Api Secret", text: $newSecret)
					.onSubmit {
						
					}
				Button(action: {
						DispatchQueue.global(qos: .default).async {
								
								KeychainService().save(newSecret, for: "Main")
								isLoading = true
						}
				}, label: { Text("GitHub Api") })
			}
		}
	}
}
