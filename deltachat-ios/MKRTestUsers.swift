//
//  MKRTestUsers.swift
//  MKR Messenger
//
//  Тестовые пользователи для разных ролей в системе
//

import Foundation

/// Тестовые пользователи для разработки и тестирования
public struct MKRTestUsers {

    // MARK: - Admin Users
    /// Главный администратор системы
    public static let admin = TestUser(
        email: "admin@kluboksrm.ru",
        password: "MKR_Admin_2024!",
        username: "admin",
        role: .admin,
        description: "Главный администратор системы с полным доступом"
    )

    // MARK: - Commanders (Командиры)
    /// Тестовые командиры
    public static let commanders: [TestUser] = [
        TestUser(
            email: "commander1@kluboksrm.ru",
            password: "Cmdr1_Pass_2024!",
            username: "commander1",
            role: .commander,
            description: "Командир отряда #1"
        ),
        TestUser(
            email: "commander2@kluboksrm.ru",
            password: "Cmdr2_Pass_2024!",
            username: "commander2",
            role: .commander,
            description: "Командир отряда #2"
        ),
        TestUser(
            email: "commander3@kluboksrm.ru",
            password: "Cmdr3_Pass_2024!",
            username: "commander3",
            role: .commander,
            description: "Командир отряда #3"
        )
    ]

    // MARK: - Technicians (Техники)
    /// Тестовые техники
    public static let technicians: [TestUser] = [
        TestUser(
            email: "tech1@kluboksrm.ru",
            password: "Tech1_Pass_2024!",
            username: "tech1",
            role: .technician,
            description: "Старший техник"
        ),
        TestUser(
            email: "tech2@kluboksrm.ru",
            password: "Tech2_Pass_2024!",
            username: "tech2",
            role: .technician,
            description: "Техник по связи"
        ),
        TestUser(
            email: "tech3@kluboksrm.ru",
            password: "Tech3_Pass_2024!",
            username: "tech3",
            role: .technician,
            description: "Техник по оборудованию"
        )
    ]

    // MARK: - OSINT Specialists
    /// Тестовые специалисты OSINT
    public static let osintSpecs: [TestUser] = [
        TestUser(
            email: "osint1@kluboksrm.ru",
            password: "Osint1_Pass_2024!",
            username: "osint1",
            role: .osint,
            description: "Старший аналитик OSINT"
        ),
        TestUser(
            email: "osint2@kluboksrm.ru",
            password: "Osint2_Pass_2024!",
            username: "osint2",
            role: .osint,
            description: "Аналитик OSINT"
        )
    ]

    // MARK: - Regular Users
    /// Тестовые обычные пользователи
    public static let regularUsers: [TestUser] = [
        TestUser(
            email: "user1@kluboksrm.ru",
            password: "User1_Pass_2024!",
            username: "user1",
            role: .user,
            description: "Обычный пользователь #1"
        ),
        TestUser(
            email: "user2@kluboksrm.ru",
            password: "User2_Pass_2024!",
            username: "user2",
            role: .user,
            description: "Обычный пользователь #2"
        ),
        TestUser(
            email: "user3@kluboksrm.ru",
            password: "User3_Pass_2024!",
            username: "user3",
            role: .user,
            description: "Обычный пользователь #3"
        ),
        TestUser(
            email: "user4@kluboksrm.ru",
            password: "User4_Pass_2024!",
            username: "user4",
            role: .user,
            description: "Обычный пользователь #4"
        ),
        TestUser(
            email: "user5@kluboksrm.ru",
            password: "User5_Pass_2024!",
            username: "user5",
            role: .user,
            description: "Обычный пользователь #5"
        )
    ]

    // MARK: - Special Test Users
    /// Пользователь для тестирования верификации
    public static let pendingUser = TestUser(
        email: "pending@kluboksrm.ru",
        password: "Pending_Pass_2024!",
        username: "pending",
        role: .user,
        description: "Пользователь ожидающий верификации"
    )

    /// Забаненный пользователь
    public static let bannedUser = TestUser(
        email: "banned@kluboksrm.ru",
        password: "Banned_Pass_2024!",
        username: "banned",
        role: .user,
        description: "Забаненный пользователь для тестирования"
    )

    // MARK: - All Users
    /// Все тестовые пользователи
    public static var allUsers: [TestUser] {
        var users: [TestUser] = []
        users.append(admin)
        users.append(contentsOf: commanders)
        users.append(contentsOf: technicians)
        users.append(contentsOf: osintSpecs)
        users.append(contentsOf: regularUsers)
        users.append(pendingUser)
        users.append(bannedUser)
        return users
    }

    // MARK: - Helper Methods

    /// Получить пользователя по email
    public static func getUser(byEmail email: String) -> TestUser? {
        return allUsers.first { $0.email == email }
    }

    /// Получить пользователя по username
    public static func getUser(byUsername username: String) -> TestUser? {
        return allUsers.first { $0.username == username }
    }

    /// Получить всех пользователей определенной роли
    public static func getUsers(byRole role: MKRUserRole) -> [TestUser] {
        return allUsers.filter { $0.role == role }
    }

    /// Получить учетные данные для QuickType Autofill
    public static func getCredentialsForAutofill() -> [(username: String, password: String)] {
        return allUsers.map { ($0.email, $0.password) }
    }

    // MARK: - Export for Backend

    /// Экспорт всех пользователей в формате для создания на backend
    public static func exportForBackend() -> String {
        var output = "# MKR Test Users - Backend Setup\n"
        output += "# Generated: \(Date())\n\n"

        output += "## Admin\n"
        output += exportUserForBackend(admin)

        output += "\n## Commanders\n"
        for commander in commanders {
            output += exportUserForBackend(commander)
        }

        output += "\n## Technicians\n"
        for technician in technicians {
            output += exportUserForBackend(technician)
        }

        output += "\n## OSINT Specialists\n"
        for osint in osintSpecs {
            output += exportUserForBackend(osint)
        }

        output += "\n## Regular Users\n"
        for user in regularUsers {
            output += exportUserForBackend(user)
        }

        output += "\n## Special Users\n"
        output += exportUserForBackend(pendingUser)
        output += exportUserForBackend(bannedUser)

        return output
    }

    /// Экспорт одного пользователя в формате для создания на backend
    private static func exportUserForBackend(_ user: TestUser) -> String {
        return """
        # \(user.description)
        POST /api/v1/users
        {
            "email": "\(user.email)",
            "password": "\(user.password)",
            "username": "\(user.username)",
            "role": "\(user.role.rawValue)"
        }

        """
    }

    /// SQL запросы для создания тестовых пользователей в базе данных
    public static func exportSQL() -> String {
        var sql = "-- MKR Test Users - SQL Setup\n"
        sql += "-- Generated: \(Date())\n\n"

        for user in allUsers {
            sql += """
            -- \(user.description)
            INSERT INTO users (email, password_hash, username, role, is_verified, is_banned, created_at)
            VALUES ('\(user.email)', '$2a$12$...', '\(user.username)', '\(user.role.rawValue)', \(user.role == .admin ? "true" : "false"), false, NOW());

            """
        }

        return sql
    }
}

// MARK: - Test User Model

public struct TestUser {
    public let email: String
    public let password: String
    public let username: String
    public let role: MKRUserRole
    public let description: String

    public init(email: String, password: String, username: String, role: MKRUserRole, description: String) {
        self.email = email
        self.password = password
        self.username = username
        self.role = role
        self.description = description
    }

    /// Учетные данные в формате username:password
    public var credentials: String {
        return "\(email):\(password)"
    }

    /// Полное имя с ролью
    public var fullName: String {
        return "\(username) (\(role.displayName))"
    }
}

// MARK: - QuickType Password Autofill Support

#if canImport(AuthenticationServices)
import AuthenticationServices

/// Поддержка QuickType Autofill для тестовых пользователей
extension MKRTestUsers {

    /// Создать credential для Apple Password Autofill
    public static func createCredential(for user: TestUser) -> ASPasswordCredential {
        return ASPasswordCredential(user: user.email, password: user.password)
    }

    /// Все credentials для Autofill
    public static var allCredentials: [ASPasswordCredential] {
        return allUsers.map { ASPasswordCredential(user: $0.email, password: $0.password) }
    }
}
#endif
