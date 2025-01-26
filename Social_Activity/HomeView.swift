//
//  HomeView.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-11-21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class HomeData: ObservableObject {
	@Published var statusItems: [StatusInformation?] = [nil]
	@Published var statusItemsState: LoadingState = LoadingState.loading
	@Published var createSelectedEmoji: String = "smiley" // The emoji for create
	@Published var selectedEmoji: String = "smiley" // The emoji for picker
	@Published var selectedIndex: Int = -1 // If -1 not selecting a emoji
	@Published var profile: UserData? = nil
	@Published var token: String = ""
	@Published var emojis: [String:String] = [:]
		
	func checkStatus() -> Void {
		guard let currentProfile = profile else {
			return
		}
		Task { @MainActor in
			print(currentProfile.status)
			profile = UserData(fullName: currentProfile.fullName, advatar: currentProfile.advatar, pronouns: currentProfile.advatar, username: currentProfile.username, status: await getUserStatus(token: token))
			print(profile?.status)
		}
	}
	
	init() {
		Task { @MainActor in
			do {
				emojis = try await loadGitHubUrls()
			} catch {
				//TODO
			}
		}
	}
	

	func getUrl(emoji: String) throws -> String {
		guard let result = emojis[emoji] else {
			throw ApiError.regular
		}
		return result
	}
	
	func getEmojis() throws -> [String:String] {
		return emojis
	}
}

protocol StatusItemInformation {}
extension StatusInformation : StatusItemInformation{}
extension Binding<String> : StatusItemInformation {}

struct StatusButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundColor(.white)
	}
}

struct StatusComponent: View {
	@EnvironmentObject var homeData: HomeData
	
	var emojiBinding: Binding<String> {
		 Binding<String>(
				 get: {
					 return self.homeData.profile?.status?.emoji ?? ""
		 },
				 set: { newString in
					 
		 })
	 }
	
	var body: some View {
		HStack {
			if (homeData.profile != nil) {
				AsyncImage(url: URL(string: homeData.profile!.advatar)) { image in
					image.resizable()
				} placeholder: {
					ProgressView()
				}
				.frame(width: 50, height: 50)
				.clipShape(.rect(cornerRadius: 25))
				.overlay(RoundedRectangle(cornerRadius: 25)
									 .stroke(Color.black, lineWidth: 1))
				.padding(.leading)
			} else {
				ProgressView()
					.padding(.leading)
			}
			if (homeData.profile?.status != nil) {
				EmojiView(emoji: emojiBinding)
					.padding(.leading)
				Text((homeData.profile?.status!.name) ?? "")
					.font(Font.custom("Nunito-Regular", size: 20))
					.foregroundStyle(.black)
			} else {
				Text("No Status Set!")
					.font(Font.custom("Nunito-Regular", size: 20))
					.foregroundStyle(.black)
			}
			Spacer()
			if (homeData.profile?.status != nil) {
				Button(action: {
					Task {
						await clearStatus(token: homeData.token)
						homeData.checkStatus()
					}
				}) {
					Image(systemName: "xmark")
						.resizable()
						.frame(width: 25, height: 25)
						.padding(.trailing, 20)
						.foregroundStyle(.black)
				}.buttonStyle(.plain)
			}
		}.frame(maxWidth: .infinity, minHeight:75, maxHeight: 75)
		.overlay(alignment: .center) {
			RoundedRectangle(cornerRadius: 10)
				.strokeBorder(.black, style: StrokeStyle(lineWidth: 2, dash: [.greatestFiniteMagnitude]))
				.cornerRadius(10)
		}
		.background(.white)
		.clipShape(.rect(cornerRadius: 10))
		.padding(.horizontal, 10)
	}
}

struct HomeView: View {
	@EnvironmentObject var homeData: HomeData
	@State var isShowingSettings: Bool = false

	var body: some View {
		GeometryReader { geometry in
			VStack {
				ZStack {
					VStack {
						HStack {
							Image("Logo")
								.resizable()
								.frame(width: max(50, geometry.size.height * 0.08), height: max(50, geometry.size.height * 0.08))
								.cornerRadius(12)
								.padding(.leading)
							Text("Social Activity")
								.font(Font.custom("Nunito-Regular", size: 32))
								.foregroundStyle(.white)
							Spacer()
							if (geometry.size.width < 600 || geometry.size.height < 700) {
								Button(action: {
									withAnimation(.spring(duration: 0.3)) {
										isShowingSettings = !isShowingSettings
									}
								}) {
									Image(systemName: "gearshape.fill")
										.resizable()
										.frame(width: 30, height: 30)
										.padding()
										.foregroundStyle(.black)
								}.buttonStyle(.plain)
							}
						}
						.frame(width: geometry.size.width, height: (geometry.size.height * 0.1))
						.fixedSize()
						HStack {
							if (geometry.size.width >= 600 || isShowingSettings) {
								VStack {
									if (homeData.selectedIndex != -1 && geometry.size.width >= 600) {
										EmojiPicker(for: geometry, onDismiss: {selected in
											homeData.selectedIndex = -1
										})
									} else if (geometry.size.height >= 700 || !isShowingSettings) {
										ProfileView(for: geometry)
									}
									if (geometry.size.height >= 700 || isShowingSettings) {
										SettingsView(for: geometry)
											.transition(.opacity)
									}
									Spacer()
								}
							}
							if (geometry.size.width >= 600 || !isShowingSettings) {
								VStack {
									if (geometry.size.width < 600) {
										StatusComponent()
									}
									HomeList(for: (geometry.size.height * 0.9) - (geometry.safeAreaInsets.bottom + 70), for: geometry)
								}
							}
						}
					}
					if (homeData.selectedIndex != -1 && geometry.size.width < 600) {
						VStack {
							EmojiPicker(for: geometry, onDismiss: { hello in
								homeData.selectedIndex = -1
							})
							.position(x: geometry.size.width, y: geometry.size.height)
							.frame(width: geometry.size.width, height: geometry.size.height)
						}
						.position(x: 0, y: 0)
						.frame(width: geometry.size.width, height: geometry.size.height)
						.background(.gray.opacity(0.8))
					}
				}
			}
			.frame(width: geometry.size.width, height: geometry.size.height)
			.background(
				LinearGradient(stops: [
					Gradient.Stop(color: Color("BlueOne"), location: 0.14),
					Gradient.Stop(color: Color("BlueTwo"), location: 0.53),
					Gradient.Stop(color: Color("GreenOne"), location: 0.87),
				], startPoint: .topTrailing, endPoint: .bottomLeading)
			)
			.onAppear() {
				Task {
					guard var result: [StatusInformation?] = await getStatusInformation() else {
						homeData.statusItemsState = LoadingState.failed
						print("Something when wrong when getting status information!")
						return
					}
					result.append(nil)
					homeData.statusItems = result
					homeData.statusItemsState = LoadingState.success
				}
				Task {
					do {
						let result = try await getUserData(token: homeData.token)
						homeData.profile = result
					} catch let error {
						print(error)
						guard let apiError = error as? ApiError else {
							return
						}
						if (apiError == ApiError.auth) {
							try Auth.auth().signOut()
							KeychainService().save("", for: "gitauth")
						}
					}
				}
			}
			.onChange(of: homeData.selectedEmoji) { oldVal, newVal in
				if homeData.selectedIndex < homeData.statusItems.count && homeData.selectedIndex >= 0 {
					homeData.statusItems[homeData.selectedIndex] = StatusInformation(id: homeData.statusItems[homeData.selectedIndex]!.id, name: homeData.statusItems[homeData.selectedIndex]!.name, emoji: homeData.selectedEmoji, selectedTime: homeData.statusItems[homeData.selectedIndex]!.selectedTime, times: homeData.statusItems[homeData.selectedIndex]!.times)
				} else if homeData.selectedIndex == homeData.statusItems.count {
					homeData.createSelectedEmoji = newVal
				}
			}
			.environmentObject(homeData)
		}.ignoresSafeArea(.keyboard, edges: .all)
	}
}
