//
//  Authentication.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-01-05.
//

import Foundation
import AuthenticationServices
import LocalAuthentication
import WebKit

func authenticateUser() async -> Bool {
    let context = LAContext()
    do {
        let success = try await context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "Please authenticate to proceed.")
        if (success) {
            return true
        } else {
            return false
        }
    } catch {
        return false
    }
}
