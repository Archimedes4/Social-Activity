//
//  GitHubConnection.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-01-05.
//

import Foundation

let GITHUB_CLIENT_ID = "Ov23liCq5p4ZHp6wfTen"//TODO fix this
let gitHubAuthLink = "https://github.com/login/oauth/authorize?client_id=\(GITHUB_CLIENT_ID)&scope=user"

enum ApiError: Error {
	case auth
	case regular
}

func callApi(json: [String : Any], token: String) async throws -> [String: Any]{
	do {
		guard let url = URL(string: "https://api.github.com/graphql") else {
			throw ApiError.regular
		}
		guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else { throw ApiError.regular}
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("bearer "+token, forHTTPHeaderField: "Authorization")
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData
		let (responseData, _) = try await URLSession.shared.data(
			for: request
		)
		if let json = try JSONSerialization.jsonObject(with: responseData, options: [.allowFragments])  as? [String: Any] {
			if (json["message"] as? String == "Bad credentials") {
				//Failed due to auth
				throw ApiError.auth
			} else {
				//Looks good
				return json
			}
		} else {
			throw ApiError.regular
		}
	} catch let error {
		//something went wrong
		throw error
	}
}

func clearStatus(token: String) async {
	let clearQuery = "\n mutation {\nchangeUserStatus(input: {}) {\nstatus {\nmessage\n}\n}\n}"
	let json = ["query": clearQuery] as [String : Any]
	do {
		let _ = try await callApi(json: json, token: token)
	} catch {
		//TODO
	}
}

func setStatus(emoji: String, message: String, token: String) async {
	let dataQuery = "mutation ($status: ChangeUserStatusInput!) {\nchangeUserStatus(input: $status) {\nstatus {\nemoji\nexpiresAt\nlimitedAvailability: indicatesLimitedAvailability\nmessage\n}\n}\n}"
	let json = ["query": dataQuery, "variables": ["status":["emoji":emoji,"message":message]]] as [String : Any]
	do {
		let _ = try await callApi(json: json, token: token)
	} catch {
		//TODO
	}
}

func validateToken(token: String) async throws -> String {
	let json = ["query": "{\nviewer {\nlogin\n}\n}"]
	do {
		let result = try await callApi(json: json, token: token)
		let data = result["data"] as! [String: Any]
		let viewer = data["viewer"] as! [String: Any]
		let login = viewer["login"] as! String
		return login
	} catch {
		throw ApiError.regular
	}
}

/**
 Returns nul if something has gone wrong
 */
func getUserData(token: String) async throws -> UserData? {
	let json = ["query": "{\nviewer {\nname\navatarUrl\npronouns\nlogin\nstatus {\nid\nmessage\nemoji\n}\n}\n}"]
	do {
		let result = try await callApi(json: json, token: token)
		guard let data = result["data"] as? [String: Any] else {return nil}
		guard let viewer = data["viewer"] as? [String: Any] else {return nil}
		guard let name = viewer["name"] as? String else {return nil}
		guard let avatarUrl = viewer["avatarUrl"] as? String else {return nil}
		guard let pronouns = viewer["pronouns"] as? String else {return nil}
		guard let login = viewer["login"] as? String else {return nil}
		
		guard let status = viewer["status"] as? [String: String] else {
			return UserData(fullName: name, advatar: avatarUrl, pronouns: pronouns, username: login, status: nil)
		}
		guard var status_emoji = status["emoji"] else {return nil}
		status_emoji = status_emoji.filter { ":".contains($0) == false }
		guard let status_id = status["id"] else {return nil}
		guard let status_message = status["message"] else {return nil}

		return UserData(fullName: name, advatar: avatarUrl, pronouns: pronouns, username: login, status: StatusInformation(id: status_id, name: status_message, emoji: status_emoji))
	} catch let error {
		throw error
	}
}

func getUserStatus(token: String) async -> StatusInformation? {
	let json = ["query": "{\nviewer {\nstatus {\nid\nmessage\nemoji\n}\n}\n}"]
	do {
		let result = try await callApi(json: json, token: token)
		guard let data = result["data"] as? [String: Any] else {return nil}
		guard let viewer = data["viewer"] as? [String: Any] else {return nil}
		
		guard let status = viewer["status"] as? [String: String] else {
			return nil
		}
		guard var status_emoji = status["emoji"] else {return nil}
		status_emoji = status_emoji.filter { ":".contains($0) == false }
		guard let status_id = status["id"] else {return nil}
		guard let status_message = status["message"] else {return nil}

		return StatusInformation(id: status_id, name: status_message, emoji: status_emoji)
	} catch {
		return nil
	}
}

func getAuthToken(code: String) async throws -> String {
	guard let url = URL(string: "https://github.com/login/oauth/access_token?client_id=\(GITHUB_CLIENT_ID)&client_secret=\("73854e99a7c42f4cb004ba10f5900acd0263e92e")&code=\(code)") else {
		throw ApiError.regular
	}
	var request = URLRequest(url: url)
	request.setValue("application/json", forHTTPHeaderField: "Accept")
	let (responseData, _) = try await URLSession.shared.data(
		for: request
	)
	guard let decodedResponse = try? JSONDecoder().decode([String:String].self, from: responseData) else { throw ApiError.regular }
	guard let accessToken = decodedResponse["access_token"] else {throw ApiError.regular}
	return accessToken
}

func loadGitHubUrls() async throws -> [String:String] {
	do {
		guard let url = URL(string: "https://api.github.com/emojis") else {
			throw ApiError.regular
		}
		let request = URLRequest(url: url)
		let (responseData, _) = try await URLSession.shared.data(
			for: request
		)
		
		guard let decodedResponse = try? JSONDecoder().decode([String:String].self, from: responseData) else { throw ApiError.regular }
		return decodedResponse
	} catch {
		throw ApiError.regular
	}
}
