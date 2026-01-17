//
//  PioneerAPIService.swift
//  MKR Messenger
//
//  API сервис для взаимодействия с Pioneer backend
//

import Foundation
import DcCore

// MARK: - Pioneer API Service
class PioneerAPIService {

    static let shared = PioneerAPIService()

    // Configuration
    private let baseURL = "https://kluboksrm.ru"
    private let apiVersion = "/v1"
    private var apiURL: String {
        return "\(baseURL)/api\(apiVersion)"
    }

    private let urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutInterval = 30
        config.httpShouldSetCookies = true
        return URLSession(configuration: config)
    }()

    // Auth token (хранится в Keychain)
    private var authToken: String? {
        get {
            return KeychainManager.shared.load(key: "pioneer_auth_token")
        }
        set {
            if let newValue = newValue {
                KeychainManager.shared.save(key: "pioneer_auth_token", data: newValue.data(using: .utf8)!)
            } else {
                KeychainManager.shared.delete(key: "pioneer_auth_token")
            }
        }
    }

    // MARK: - Auth

    /// Login user and get auth token
    func login(email: String, password: String) async throws -> AuthResponse {
        let url = URL(string: "\(apiURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginRequest = LoginRequest(email: email, password: password)
        request.httpBody = try? JSONEncoder().encode(loginRequest)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.invalidCredentials
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        authToken = authResponse.token

        // Also store refresh token if available
        if let refreshToken = authResponse.refreshToken {
            KeychainManager.shared.save(key: "pioneer_refresh_token", data: refreshToken.data(using: .utf8)!)
        }

        return authResponse
    }

    /// Register new user
    func register(email: String, password: String, username: String) async throws -> AuthResponse {
        let url = URL(string: "\(apiURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let registerRequest = RegisterRequest(
            email: email,
            password: password,
            username: username
        )
        request.httpBody = try? JSONEncoder().encode(registerRequest)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw PioneerError.userExists
        }

        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        authToken = authResponse.token

        // Also store refresh token if available
        if let refreshToken = authResponse.refreshToken {
            KeychainManager.shared.save(key: "pioneer_refresh_token", data: refreshToken.data(using: .utf8)!)
        }

        return authResponse
    }

    /// Logout user
    func logout() async throws {
        authToken = nil
        KeychainManager.shared.delete(key: "pioneer_refresh_token")
    }

    // MARK: - Users Management

    /// Get all users (admin only)
    func getUsers() async throws -> [PioneerUser] {
        let url = URL(string: "\(apiURL)/users")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.notAuthorized
        }

        let usersResponse = try JSONDecoder().decode(UsersResponse.self, from: data)
        return usersResponse.users
    }

    /// Get user by ID
    func getUser(id: Int) async throws -> PioneerUser {
        let url = URL(string: "\(apiURL)/users/\(id)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.userNotFound
        }

        return try JSONDecoder().decode(PioneerUser.self, from: data)
    }

    /// Create new user (admin only)
    func createUser(email: String, password: String, username: String, role: String) async throws -> PioneerUser {
        let url = URL(string: "\(apiURL)/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let createRequest = CreateUserRequest(email: email, password: password, username: username, role: role)
        request.httpBody = try? JSONEncoder().encode(createRequest)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw PioneerError.userExists
        }

        return try JSONDecoder().decode(PioneerUser.self, from: data)
    }

    /// Update user role (admin only)
    func updateUserRole(userId: Int, role: String) async throws -> PioneerUser {
        let url = URL(string: "\(apiURL)/users/\(userId)/role")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let roleRequest = RoleUpdateRequest(role: role)
        request.httpBody = try? JSONEncoder().encode(roleRequest)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.notAuthorized
        }

        return try JSONDecoder().decode(PioneerUser.self, from: data)
    }

    /// Verify user (admin only)
    func verifyUser(userId: Int, verified: Bool) async throws -> Bool {
        let url = URL(string: "\(apiURL)/users/\(userId)/verify")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let verifyRequest = VerifyRequest(verified: verified)
        request.httpBody = try? JSONEncoder().encode(verifyRequest)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.notAuthorized
        }

        let result = try JSONDecoder().decode(VerifyResponse.self, from: data)
        return result.verified
    }

    /// Ban/unban user (admin only)
    func banUser(userId: Int, ban: Bool, reason: String? = nil) async throws -> Bool {
        let url = URL(string: "\(apiURL)/users/\(userId)/ban")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let banRequest = BanRequest(ban: ban, reason: reason)
        request.httpBody = try? JSONEncoder().encode(banRequest)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.notAuthorized
        }

        let result = try JSONDecoder().decode(BanResponse.self, from: data)
        return result.success
    }

    /// Delete user (admin only)
    func deleteUser(userId: Int) async throws -> Bool {
        let url = URL(string: "\(apiURL)/users/\(userId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
            throw PioneerError.notAuthorized
        }

        return httpResponse.statusCode == 204
    }

    // MARK: - Verification Requests

    /// Get pending verification requests
    func getVerificationRequests() async throws -> [VerificationRequest] {
        let url = URL(string: "\(apiURL)/verification/requests")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.notAuthorized
        }

        let verificationResponse = try JSONDecoder().decode(VerificationRequestsResponse.self, from: data)
        return verificationResponse.requests
    }

    /// Create verification request
    func createVerificationRequest(role: String) async throws -> VerificationRequest {
        let url = URL(string: "\(apiURL)/verification/requests")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let createRequest = CreateVerificationRequest(role: role)
        request.httpBody = try? JSONEncoder().encode(createRequest)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw PioneerError.invalidResponse
        }

        return try JSONDecoder().decode(VerificationRequest.self, from: data)
    }

    /// Approve verification request (admin only)
    func approveVerificationRequest(requestId: Int) async throws -> Bool {
        let url = URL(string: "\(apiURL)/verification/requests/\(requestId)/approve")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.notAuthorized
        }

        let result = try JSONDecoder().decode(ApproveRejectResponse.self, from: data)
        return result.success
    }

    /// Reject verification request (admin only)
    func rejectVerificationRequest(requestId: Int) async throws -> Bool {
        let url = URL(string: "\(apiURL)/verification/requests/\(requestId)/reject")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.notAuthorized
        }

        let result = try JSONDecoder().decode(ApproveRejectResponse.self, from: data)
        return result.success
    }

    // MARK: - Server Stats

    /// Get server statistics (admin only)
    func getServerStats() async throws -> ServerStats {
        let url = URL(string: "\(apiURL)/stats")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.notAuthorized
        }

        return try JSONDecoder().decode(ServerStats.self, from: data)
    }

    /// Get server configuration
    func getServerConfig() async throws -> ServerConfig {
        let url = URL(string: "\(apiURL)/config")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.notAuthorized
        }

        return try JSONDecoder().decode(ServerConfig.self, from: data)
    }

    /// Update server configuration (admin only)
    func updateServerConfig(_ config: ServerConfig) async throws -> ServerConfig {
        let url = URL(string: "\(apiURL)/config")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(authToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONEncoder().encode(config)

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PioneerError.notAuthorized
        }

        return try JSONDecoder().decode(ServerConfig.self, from: data)
    }
}

// MARK: - Models

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let username: String
}

struct CreateUserRequest: Codable {
    let email: String
    let password: String
    let username: String
    let role: String
}

struct VerifyRequest: Codable {
    let verified: Bool
}

struct CreateVerificationRequest: Codable {
    let role: String
}

struct AuthResponse: Codable {
    let token: String
    let user: PioneerUser
    let refreshToken: String?
}

struct UsersResponse: Codable {
    let users: [PioneerUser]
    let total: Int
}

struct RoleUpdateRequest: Codable {
    let role: String
}

struct BanRequest: Codable {
    let ban: Bool
    let reason: String?
}

struct BanResponse: Codable {
    let success: Bool
    let message: String
}

struct VerifyResponse: Codable {
    let verified: Bool
}

struct ApproveRejectResponse: Codable {
    let success: Bool
    let message: String
}

struct VerificationRequestsResponse: Codable {
    let requests: [VerificationRequest]
    let total: Int
}

struct VerificationRequest: Codable {
    let id: Int
    let email: String
    let username: String
    let role: String
    let date: Date
    let status: String  // pending, approved, rejected
}

struct ServerStats: Codable {
    let totalUsers: Int
    let verifiedUsers: Int
    let onlineUsers: Int
    let totalMessages: Int
    let serverUptime: String
    let lastUpdate: String

    private enum CodingKeys: String, CodingKey {
        case totalUsers, verifiedUsers, onlineUsers, totalMessages, serverUptime, lastUpdate
    }
}

struct ServerConfig: Codable {
    let imapServer: String
    let imapPort: Int
    let smtpServer: String
    let smtpPort: Int
    let turnServer: String
    let stunServer: String
    let maintenanceMode: Bool
}

// MARK: - PioneerUser Model

struct PioneerUser: Codable {
    let id: Int
    let email: String
    let username: String
    let role: String
    let isVerified: Bool
    let isBanned: Bool
    let status: String  // online, offline, banned
    let createdAt: Date
    let lastSeen: Date?

    private enum CodingKeys: String, CodingKey {
        case id, email, username, role, isVerified, isBanned, status, createdAt, lastSeen
    }
}

// MARK: - Errors

enum PioneerError: Error {
    case invalidCredentials
    case userExists
    case notAuthorized
    case invalidResponse
    case networkError
    case serverError
    case userNotFound

    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Неверный логин или пароль"
        case .userExists:
            return "Пользователь уже существует"
        case .notAuthorized:
            return "Нет прав для выполнения операции"
        case .invalidResponse:
            return "Неверный ответ сервера"
        case .networkError:
            return "Ошибка сети"
        case .serverError:
            return "Ошибка сервера"
        case .userNotFound:
            return "Пользователь не найден"
        }
    }
}

// MARK: - Keychain Manager

class KeychainManager {

    static let shared = KeychainManager()

    private let keychain = Keychain(service: "com.mkr.su.keychain")

    func save(key: String, data: Data) -> Bool {
        do {
            return try keychain.set(key: key, data: data)
        } catch {
            print("Keychain save error: \(error)")
            return false
        }
    }

    func load(key: String) -> String? {
        do {
            if let data = try keychain.get(key: key) {
                return String(data: data)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }

    func delete(key: String) -> Bool {
        do {
            try keychain.delete(key: key)
            return true
        } catch {
            print("Keychain delete error: \(error)")
            return false
        }
    }
}
