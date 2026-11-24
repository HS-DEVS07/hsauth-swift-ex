import Foundation

public struct UserData {
    public var username: String = ""
    public var ip: String = ""
    public var hwid: String = ""
    public var expiresAt: String = ""
}

public struct AuthResponse {
    public var success: Boolean = false
    public var message: String = ""
}

public class HSAuth: ObservableObject {
    public let name: String
    public let ownerId: String
    public let secret: String
    public let version: String
    public let apiUrl: String

    public var sessionId: String = ""
    public var isInitialized: Bool = false
    public var userData = UserData()
    public var devMessage: String = ""

    public init(name: String, ownerId: String, secret: String, version: String = "1.0", apiUrl: String = "https://auth.hsdevs.pro/api/1.3/") {
        self.name = name
        self.ownerId = ownerId
        self.secret = secret
        self.version = version
        self.apiUrl = apiUrl
    }

    public func initialize() async -> Bool {
        let params = [
            "type": "init",
            "name": name,
            "ownerid": ownerId,
            "ver": version
        ]
        guard let json = await post(params: params) else { return false }
        let success = json["success"] as? Bool ?? false
        if success {
            self.sessionId = json["sessionid"] as? String ?? ""
            self.isInitialized = true
        }
        return success
    }

    public func login(username: String, pass: String) async -> Bool {
        if !isInitialized {
            _ = await initialize()
        }
        let params = [
            "type": "login",
            "username": username,
            "pass": pass,
            "sessionid": sessionId,
            "name": name,
            "ownerid": ownerId
        ]
        guard let json = await post(params: params) else { return false }
        let success = json["success"] as? Bool ?? false
        if success {
            if let info = json["info"] as? [String: Any] {
                self.userData.username = info["username"] as? String ?? username
                self.userData.expiresAt = info["expiry"] as? String ?? ""
            }
        }
        return success
    }

    public func license(key: String) async -> Bool {
        if !isInitialized {
            _ = await initialize()
        }
        let params = [
            "type": "license",
            "key": key,
            "sessionid": sessionId,
            "name": name,
            "ownerid": ownerId
        ]
        guard let json = await post(params: params) else { return false }
        let success = json["success"] as? Bool ?? false
        if success {
            if let info = json["info"] as? [String: Any] {
                self.userData.username = info["username"] as? String ?? ""
                self.userData.expiresAt = info["expiry"] as? String ?? ""
            }
        }
        return success
    }

    private func post(params: [String: String]) async -> [String: Any]? {
        guard let url = URL(string: apiUrl) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = params.map { "($0.key)=($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return try JSONSerialization.jsonObject(with: data) as? [String: Any]
        } catch {
            return nil
        }
    }
}
