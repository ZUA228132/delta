//
//  MKRUserDistribution.swift
//  MKR Messenger
//
//  Распределение пользователей по ролям и группам
//

import Foundation

/// Система распределения пользователей по ролям и группам
public struct MKRUserDistribution {

    // MARK: - Distribution Structure

    /// Структура распределения пользователей
    public struct Distribution {
        let squadNumber: Int
        let commander: TestUser
        let technicians: [TestUser]
        let osintSpecs: [TestUser]
        let regularUsers: [TestUser]
        let totalUsers: Int

        /// Все пользователи в отряде
        var allUsers: [TestUser] {
            var users: [TestUser] = []
            users.append(commander)
            users.append(contentsOf: technicians)
            users.append(contentsOf: osintSpecs)
            users.append(contentsOf: regularUsers)
            return users
        }

        /// Получить пользователя по роли
        func getUsers(byRole role: MKRUserRole) -> [TestUser] {
            switch role {
            case .admin:
                return []
            case .commander:
                return [commander]
            case .technician:
                return technicians
            case .osint:
                return osintSpecs
            case .user:
                return regularUsers
            }
        }
    }

    // MARK: - Pre-configured Distributions

    /// Отряд #1 (Alpha Squad)
    public static let squad1 = Distribution(
        squadNumber: 1,
        commander: TestUser(
            email: "cmdr1.alpha@kluboksrm.ru",
            password: "Alpha1_Cmdr_2024!",
            username: "alpha1",
            role: .commander,
            description: "Командир Alpha Squad"
        ),
        technicians: [
            TestUser(
                email: "tech1.alpha@kluboksrm.ru",
                password: "Alpha1_Tech_2024!",
                username: "alpha_tech1",
                role: .technician,
                description: "Техник Alpha Squad #1"
            ),
            TestUser(
                email: "tech2.alpha@kluboksrm.ru",
                password: "Alpha2_Tech_2024!",
                username: "alpha_tech2",
                role: .technician,
                description: "Техник Alpha Squad #2"
            )
        ],
        osintSpecs: [
            TestUser(
                email: "osint1.alpha@kluboksrm.ru",
                password: "Alpha1_Osint_2024!",
                username: "alpha_osint1",
                role: .osint,
                description: "OSINT специалист Alpha Squad"
            )
        ],
        regularUsers: [
            TestUser(
                email: "user1.alpha@kluboksrm.ru",
                password: "Alpha1_User_2024!",
                username: "alpha_user1",
                role: .user,
                description: "Боец Alpha Squad #1"
            ),
            TestUser(
                email: "user2.alpha@kluboksrm.ru",
                password: "Alpha2_User_2024!",
                username: "alpha_user2",
                role: .user,
                description: "Боец Alpha Squad #2"
            ),
            TestUser(
                email: "user3.alpha@kluboksrm.ru",
                password: "Alpha3_User_2024!",
                username: "alpha_user3",
                role: .user,
                description: "Боец Alpha Squad #3"
            )
        ],
        totalUsers: 7
    )

    /// Отряд #2 (Bravo Squad)
    public static let squad2 = Distribution(
        squadNumber: 2,
        commander: TestUser(
            email: "cmdr2.bravo@kluboksrm.ru",
            password: "Bravo1_Cmdr_2024!",
            username: "bravo1",
            role: .commander,
            description: "Командир Bravo Squad"
        ),
        technicians: [
            TestUser(
                email: "tech1.bravo@kluboksrm.ru",
                password: "Bravo1_Tech_2024!",
                username: "bravo_tech1",
                role: .technician,
                description: "Техник Bravo Squad #1"
            ),
            TestUser(
                email: "tech2.bravo@kluboksrm.ru",
                password: "Bravo2_Tech_2024!",
                username: "bravo_tech2",
                role: .technician,
                description: "Техник Bravo Squad #2"
            )
        ],
        osintSpecs: [
            TestUser(
                email: "osint1.bravo@kluboksrm.ru",
                password: "Bravo1_Osint_2024!",
                username: "bravo_osint1",
                role: .osint,
                description: "OSINT специалист Bravo Squad"
            )
        ],
        regularUsers: [
            TestUser(
                email: "user1.bravo@kluboksrm.ru",
                password: "Bravo1_User_2024!",
                username: "bravo_user1",
                role: .user,
                description: "Боец Bravo Squad #1"
            ),
            TestUser(
                email: "user2.bravo@kluboksrm.ru",
                password: "Bravo2_User_2024!",
                username: "bravo_user2",
                role: .user,
                description: "Боец Bravo Squad #2"
            ),
            TestUser(
                email: "user3.bravo@kluboksrm.ru",
                password: "Bravo3_User_2024!",
                username: "bravo_user3",
                role: .user,
                description: "Боец Bravo Squad #3"
            )
        ],
        totalUsers: 7
    )

    /// Отряд #3 (Charlie Squad)
    public static let squad3 = Distribution(
        squadNumber: 3,
        commander: TestUser(
            email: "cmdr3.charlie@kluboksrm.ru",
            password: "Charlie1_Cmdr_2024!",
            username: "charlie1",
            role: .commander,
            description: "Командир Charlie Squad"
        ),
        technicians: [
            TestUser(
                email: "tech1.charlie@kluboksrm.ru",
                password: "Charlie1_Tech_2024!",
                username: "charlie_tech1",
                role: .technician,
                description: "Техник Charlie Squad"
            )
        ],
        osintSpecs: [
            TestUser(
                email: "osint1.charlie@kluboksrm.ru",
                password: "Charlie1_Osint_2024!",
                username: "charlie_osint1",
                role: .osint,
                description: "OSINT специалист Charlie Squad"
            )
        ],
        regularUsers: [
            TestUser(
                email: "user1.charlie@kluboksrm.ru",
                password: "Charlie1_User_2024!",
                username: "charlie_user1",
                role: .user,
                description: "Боец Charlie Squad #1"
            ),
            TestUser(
                email: "user2.charlie@kluboksrm.ru",
                password: "Charlie2_User_2024!",
                username: "charlie_user2",
                role: .user,
                description: "Боец Charlie Squad #2"
            )
        ],
        totalUsers: 5
    )

    // MARK: - All Squads

    /// Все отряды
    public static let allSquads: [Distribution] = [squad1, squad2, squad3]

    /// Главный администратор системы
    public static let systemAdmin = TestUser(
        email: "admin@kluboksrm.ru",
        password: "MKR_Admin_2024!",
        username: "admin",
        role: .admin,
        description: "Главный администратор системы"
    )

    // MARK: - Statistics

    /// Статистика по распределению
    public struct Statistics {
        public let totalSquads: Int
        public let totalUsers: Int
        public let totalCommanders: Int
        public let totalTechnicians: Int
        public let totalOsintSpecs: Int
        public let totalRegularUsers: Int
        public let usersPerSquad: [Int]
    }

    /// Получить статистику распределения
    public static func getStatistics() -> Statistics {
        var totalUsers = 1 // + admin
        var totalCommanders = 0
        var totalTechnicians = 0
        var totalOsintSpecs = 0
        var totalRegularUsers = 0
        var usersPerSquad: [Int] = []

        for squad in allSquads {
            totalUsers += squad.totalUsers
            totalCommanders += 1
            totalTechnicians += squad.technicians.count
            totalOsintSpecs += squad.osintSpecs.count
            totalRegularUsers += squad.regularUsers.count
            usersPerSquad.append(squad.totalUsers)
        }

        return Statistics(
            totalSquads: allSquads.count,
            totalUsers: totalUsers,
            totalCommanders: totalCommanders,
            totalTechnicians: totalTechnicians,
            totalOsintSpecs: totalOsintSpecs,
            totalRegularUsers: totalRegularUsers,
            usersPerSquad: usersPerSquad
        )
    }

    // MARK: - Helper Methods

    /// Получить отряд по номеру
    public static func getSquad(byNumber number: Int) -> Distribution? {
        return allSquads.first { $0.squadNumber == number }
    }

    /// Получить все пользователеи всех отрядов
    public static func getAllSquadUsers() -> [TestUser] {
        var users: [TestUser] = []
        for squad in allSquads {
            users.append(contentsOf: squad.allUsers)
        }
        return users
    }

    /// Получить всех пользователеи включая админа
    public static func getAllUsers() -> [TestUser] {
        var users: [TestUser] = [systemAdmin]
        users.append(contentsOf: getAllSquadUsers())
        return users
    }

    /// Получить пользователей определенной роли из всех отрядов
    public static func getUsersByRole(_ role: MKRUserRole) -> [TestUser] {
        var users: [TestUser] = []

        if role == .admin {
            return [systemAdmin]
        }

        for squad in allSquads {
            users.append(contentsOf: squad.getUsers(byRole: role))
        }

        return users
    }

    // MARK: - Export for Backend

    /// Экспорт всех пользователей для создания на backend
    public static func exportForBackend() -> String {
        var output = """
        # MKR User Distribution - Backend Setup
        # Generated: \(Date())
        # Total Squads: \(allSquads.count)
        # Total Users: \(getAllUsers().count)

        ## System Admin
        """
        output += exportUserForBackend(systemAdmin)

        for (index, squad) in allSquads.enumerated() {
            output += """

        ## Squad \(squad.squadNumber) (\(squad.squadNumber == 1 ? "Alpha" : squad.squadNumber == 2 ? "Bravo" : "Charlie"))
        """
            output += exportUserForBackend(squad.commander)
            for technician in squad.technicians {
                output += exportUserForBackend(technician)
            }
            for osint in squad.osintSpecs {
                output += exportUserForBackend(osint)
            }
            for user in squad.regularUsers {
                output += exportUserForBackend(user)
            }
        }

        return output
    }

    /// SQL запросы для создания пользователей
    public static func exportSQL() -> String {
        var sql = "-- MKR User Distribution - SQL Setup\n"
        sql += "-- Generated: \(Date())\n\n"

        // Admin
        sql += "-- System Admin\n"
        sql += sqlInsertFor(systemAdmin) + "\n"

        for squad in allSquads {
            sql += "-- Squad \(squad.squadNumber)\n"
            sql += sqlInsertFor(squad.commander)
            for technician in squad.technicians {
                sql += sqlInsertFor(technician)
            }
            for osint in squad.osintSpecs {
                sql += sqlInsertFor(osint)
            }
            for user in squad.regularUsers {
                sql += sqlInsertFor(user)
            }
            sql += "\n"
        }

        return sql
    }

    /// CSV экспорт для массового импорта
    public static func exportCSV() -> String {
        var csv = "email,password,username,role,description,squad\n"

        // Admin
        csv += csvRowFor(systemAdmin, squad: 0) + "\n"

        for squad in allSquads {
            csv += csvRowFor(squad.commander, squad: squad.squadNumber) + "\n"
            for technician in squad.technicians {
                csv += csvRowFor(technician, squad: squad.squadNumber) + "\n"
            }
            for osint in squad.osintSpecs {
                csv += csvRowFor(osint, squad: squad.squadNumber) + "\n"
            }
            for user in squad.regularUsers {
                csv += csvRowFor(user, squad: squad.squadNumber) + "\n"
            }
        }

        return csv
    }

    // MARK: - Private Helpers

    private static func exportUserForBackend(_ user: TestUser) -> String {
        return """
        # \(user.description)
        POST /api/v1/users
        {
            "email": "\(user.email)",
            "password": "\(user.password)",
            "username": "\(user.username)",
            "role": "\(user.role.rawValue)",
            "is_verified": true
        }

        """
    }

    private static func sqlInsertFor(_ user: TestUser) -> String {
        return """
        INSERT INTO users (email, password_hash, username, role, is_verified, is_banned, created_at)
        VALUES ('\(user.email)', '$2a$12$...', '\(user.username)', '\(user.role.rawValue)', true, false, NOW());
        """
    }

    private static func csvRowFor(_ user: TestUser, squad: Int) -> String {
        return "\(user.email),\(user.password),\(user.username),\(user.role.rawValue),\(user.description),\(squad == 0 ? "Admin" : "Squad\(squad)")"
    }
}

// MARK: - Squad Management Extension

extension MKRUserDistribution {

    /// Информация об отряде для UI
    public struct SquadInfo {
        public let number: Int
        public let name: String
        public let callsign: String
        public let totalUsers: Int
        public let commander: String
        public let technicianCount: Int
        public let osintCount: Int
        public let regularUserCount: Int
    }

    /// Получить информацию об отряде
    public static func getSquadInfo(for squadNumber: Int) -> SquadInfo? {
        guard let squad = getSquad(byNumber: squadNumber) else {
            return nil
        }

        let names = ["", "Alpha", "Bravo", "Charlie"]
        let callsigns = ["", "ALPHA-1", "BRAVO-2", "CHARLIE-3"]

        return SquadInfo(
            number: squad.squadNumber,
            name: names[squad.squadNumber],
            callsign: callsigns[squad.squadNumber],
            totalUsers: squad.totalUsers,
            commander: squad.commander.username,
            technicianCount: squad.technicians.count,
            osintCount: squad.osintSpecs.count,
            regularUserCount: squad.regularUsers.count
        )
    }

    /// Получить информацию обо всех отрядах
    public static func getAllSquadsInfo() -> [SquadInfo] {
        var infos: [SquadInfo] = []
        for squad in allSquads {
            if let info = getSquadInfo(for: squad.squadNumber) {
                infos.append(info)
            }
        }
        return infos
    }
}

// MARK: - Quick Reference Card

extension MKRUserDistribution {

    /// Карта быстрого доступа для тестирования
    public static func quickReference() -> String {
        let stats = getStatistics()

        return """
        MKR MESSENGER - QUICK REFERENCE
        ================================

        📊 STATISTICS
        ─────────────────────────────────────
        Total Squads:     \(stats.totalSquads)
        Total Users:       \(stats.totalUsers)
        Commanders:        \(stats.totalCommanders)
        Technicians:       \(stats.totalTechnicians)
        OSINT Specialists: \(stats.totalOsintSpecs)
        Regular Users:     \(stats.totalRegularUsers)

        🔑 ADMIN CREDENTIALS
        ─────────────────────────────────────
        Email:    \(systemAdmin.email)
        Password: \(systemAdmin.password)

        📋 SQUADS OVERVIEW
        ─────────────────────────────────────
        \(getSquadInfo(for: 1)?.callsign ?? "Alpha")    - \(getSquadInfo(for: 1)?.totalUsers ?? 0) users
        \(getSquadInfo(for: 2)?.callsign ?? "Bravo")    - \(getSquadInfo(for: 2)?.totalUsers ?? 0) users
        \(getSquadInfo(for: 3)?.callsign ?? "Charlie")  - \(getSquadInfo(for: 3)?.totalUsers ?? 0) users

        ⚡ QUICK ACCESS
        ─────────────────────────────────────
        Squad 1 Commander:  \(squad1.commander.email) / \(squad1.commander.password)
        Squad 2 Commander:  \(squad2.commander.email) / \(squad2.commander.password)
        Squad 3 Commander:  \(squad3.commander.email) / \(squad3.commander.password)

        Generated: \(Date())
        """
    }
}
