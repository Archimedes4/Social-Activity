//
//  Keychain.swift
//  ArchGithHubStatus
//
//  Created by Andrew Mainella on 2024-01-05.
//

import Foundation
import Security

class KeychainService {
    func save(_ secret: String, for id: String) {
        let query = [kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: id,
                 kSecValueData: Data(secret.utf8)] as CFDictionary
        let result = self.retriveSecret(account: id)
        if (result == nil) {
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else { return print("save error")}
        } else {
            let attributesToUpdate = [
                kSecValueData:Data(secret.utf8)
               ] as CFDictionary
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate)
            guard status == errSecSuccess else { return print("save error")}
        }
    }
    func retriveSecret(account: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: kCFBooleanTrue as Any]
        
        
        var retrivedData: AnyObject? = nil
        let _ = SecItemCopyMatching(query as CFDictionary, &retrivedData)
        
        
        guard let data = retrivedData as? Data else {return nil}
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
