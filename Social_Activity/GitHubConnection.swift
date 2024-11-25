//
//  GitHubConnection.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-01-05.
//

import Foundation

enum ApiError: Error {
    case auth
    case regular
}

func callApi(json: [String : Any]) async throws -> [String: Any]{
    do {
        guard let url = URL(string: "https://api.github.com/graphql") else {
            throw ApiError.regular
        }
        guard let GitHubToken = KeychainService().retriveSecret(account: "Main") else { throw ApiError.auth}
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else { throw ApiError.regular}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("bearer "+GitHubToken, forHTTPHeaderField: "Authorization")
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
    } catch {
        //something went wrong
        throw ApiError.regular
    }
    throw ApiError.regular
}

func clearStatus() async {
    let clearQuery = "\n mutation {\nchangeUserStatus(input: {}) {\nstatus {\nmessage\n}\n}\n}"
    let json = ["query": clearQuery] as [String : Any]
    do {
        try await callApi(json: json)
    }  catch {
        
    }
}

func setStatus(emoji: String, message: String) async {
    let dataQuery = "mutation ($status: ChangeUserStatusInput!) {\nchangeUserStatus(input: $status) {\nstatus {\nemoji\nexpiresAt\nlimitedAvailability: indicatesLimitedAvailability\nmessage\n}\n}\n}"
    let json = ["query": dataQuery, "variables": ["status":["emoji":emoji,"message":message]]] as [String : Any]
    do {
        try await callApi(json: json)
    }  catch {
        
    }
}

func validateToken() async throws -> String {
    let json = ["query": "{\nviewer {\nlogin\n}\n}"]
    do {
        let result = try await callApi(json: json)
        let data = result["data"] as! [String: Any]
        let viewer = data["viewer"] as! [String: Any]
        let login = viewer["login"] as! String
        return login
    }  catch {
        throw ApiError.regular
    }
}


class GitHubEmoji: ObservableObject {
	@Published var emojis: [String:String] = [:]
	
	init() {
		Task {
			do {
				try await _loadUrls()
			} catch {
				
			}
		}
	}
	
	func _loadUrls() async throws -> Void {
		do {
			guard let url = URL(string: "https://api.github.com/emojis") else {
				throw ApiError.regular
			}
			let request = URLRequest(url: url)
			let (responseData, _) = try await URLSession.shared.data(
				for: request
			)
			
			guard let decodedResponse = try? JSONDecoder().decode([String:String].self, from: responseData) else { throw ApiError.regular }
			emojis = decodedResponse
		} catch {
			throw ApiError.regular
		}
	}
	
	func getUrl(emoji: String) async throws -> String {
		if (emojis.count == 0) {
			try await _loadUrls()
		}
		guard let result = emojis[emoji] else {
			throw ApiError.regular
		}
		return result
	}
	
	func getEmojis() async throws -> [String:String] {
		if (emojis.count == 0) {
			try await _loadUrls()
		}
		return emojis
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
