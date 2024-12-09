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
	@ObservedObject var gitHubEmojis: GitHubEmoji
	@Binding var token: String
	
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
				EmojiView(emoji: emojiBinding, gitHubEmojis: gitHubEmojis)
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
						await clearStatus(token: token)
					}
				}) {
					Image(systemName: "xmark")
						.resizable()
						.frame(width: 25, height: 25)
						.padding(.trailing, 20)
						.foregroundStyle(.black)
				}
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
	@Binding var token: String
	@ObservedObject var gitHubEmojis: GitHubEmoji
	@StateObject var homeData: HomeData = HomeData()
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
									Image(systemName: "gearshape")
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
										}, gitHubEmojis: gitHubEmojis)
									} else if (geometry.size.height >= 700 || !isShowingSettings) {
										ProfileView(for: geometry)
									}
									if (geometry.size.height >= 700 || isShowingSettings) {
										SettingsView(for: geometry, token: $token)
											.transition(.opacity)
									}
									Spacer()
								}
							}
							if (geometry.size.width >= 600 || !isShowingSettings) {
								VStack {
									StatusComponent(gitHubEmojis: gitHubEmojis, token: $token)
									HomeList(token: $token, gitHubEmojis: gitHubEmojis, for: (geometry.size.height * 0.9) - (geometry.safeAreaInsets.bottom + 70))
								}
							}
						}
					}
					if (homeData.selectedIndex != -1 && geometry.size.width < 600) {
						VStack {
							EmojiPicker(for: geometry, onDismiss: { hello in
								homeData.selectedIndex = -1
							}, gitHubEmojis: gitHubEmojis)
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
						return
					}
					result.append(nil)
					homeData.statusItems = result
					homeData.statusItemsState = LoadingState.success
				}
				Task {
					guard let result = await getUserData(token: token) else {
						return
					}
					print(result)
					homeData.profile = result
				}
			}
			.onChange(of: homeData.selectedEmoji) { oldVal, newVal in
				if homeData.selectedIndex < homeData.statusItems.count && homeData.selectedIndex >= 0 {
					homeData.statusItems[homeData.selectedIndex] = StatusInformation(id: homeData.statusItems[homeData.selectedIndex]!.id, name: homeData.statusItems[homeData.selectedIndex]!.name, emoji: homeData.selectedEmoji)
				} else if homeData.selectedIndex == homeData.statusItems.count {
					homeData.createSelectedEmoji = newVal
				}
			}
			.environmentObject(homeData)
		}.ignoresSafeArea(.keyboard, edges: .all)
	}
}


struct HomeList: View {
	@Binding var token: String
	@ObservedObject var gitHubEmojis: GitHubEmoji
	@EnvironmentObject var homeData: HomeData
	@State var minHeight: CGFloat
	
	init (token: Binding<String>, gitHubEmojis: GitHubEmoji, for minHeight: CGFloat) {
		self._token = token
		self.gitHubEmojis = gitHubEmojis
		self.minHeight = minHeight
	}
	
	var body: some View {
		ScrollView {
			LazyVStack( spacing: 0) {
				if (homeData.statusItemsState == LoadingState.loading) {
					VStack {
						Spacer()
						ProgressView()
							.scaleEffect(max(minHeight/600, 1))
						Spacer()
					}
					.frame(height: minHeight - 75)
				} else if (homeData.statusItemsState == LoadingState.failed) {
					VStack {
						Spacer()
						Image(systemName: "exclamationmark.icloud.fill")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: 30, height: 30)
						Spacer()
					}
					.frame(height: minHeight - 100)
				}
				ForEach(Array(homeData.statusItems.enumerated()), id: (\.element?.id)) { index, item in
					if (item != nil) {
						StatusItem(information: item, gitHubEmojis: gitHubEmojis, onSelectEmoji: {
							homeData.selectedIndex = index
							homeData.selectedEmoji = item!.emoji
						}, onDelete: {
							var newArr = homeData.statusItems
							newArr.remove(at: index)
							homeData.statusItems = newArr
							homeData.selectedIndex = -1
						}, onCreate: {id, name, emoji in}, token: $token)
					} else {
						StatusItem(information: nil, gitHubEmojis: gitHubEmojis, onSelectEmoji: {
							homeData.selectedIndex = homeData.statusItems.count
							homeData.selectedEmoji = homeData.createSelectedEmoji
						}, onDelete: {}, onCreate: { id, name, emoji in
							var newArr = homeData.statusItems
							newArr[newArr.count - 1] = StatusInformation(id: id, name: name, emoji: emoji)
							newArr.append(nil)
							homeData.statusItems = newArr
							homeData.selectedIndex = -1
						}, token: $token)
						.padding(.bottom)
					}
				}
			}.frame(minHeight: (homeData.statusItemsState != LoadingState.success) ? minHeight:0)
		}.padding(.horizontal, 10)
	}
}
