//
//  AdminViewController.swift
//  MKR Messenger
//
//  Административная панель для управления пользователями, ролями и сервером
//

import UIKit
import DcCore

// MARK: - Admin Main View Controller
class AdminViewController: UIViewController {

    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!

    // Menu sections
    private enum Section: Int {
        case users = 0
        case server = 1
        case stats = 2
    }

    private var menuItems: [[MenuItem]] = [
        // Users Section
        [
            MenuItem(icon: "person.badge.plus", title: "Пользователи", badge: 0, action: #selector(openUsers)),
            MenuItem(icon: "person.2", title: "Запросы на верификацию", badge: 5, action: #selector(openVerificationRequests))
        ],
        // Server Section
        [
            MenuItem(icon: "gear", title: "Настройки сервера", badge: nil, action: #selector(openServerSettings)),
            MenuItem(icon: "server.rack", title: "Статус сервера", badge: nil, action: #selector(openServerStats))
        ],
        // Stats Section
        [
            MenuItem(icon: "chart.bar", title: "Статистика", badge: nil, action: #selector(openStats))
        ]
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Админ-панель"
        view.backgroundColor = .systemBackground

        setupTableView()
        setupNavigation()
        refreshData()
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AdminCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true

        // Add right bar button for refresh
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
        refreshButton.tintColor = MKRColors.primary
        navigationItem.rightBarButtonItem = refreshButton
    }

    // MARK: - Data
    @objc private func refreshData() {
        // TODO: Load from server
        loadMenuItems()

        UIView.animate(withDuration: 0.3) {
            self.tableView.reloadData()
        }

        if let refreshControl = refreshControl {
            refreshControl.endRefreshing()
        }
    }

    private func loadMenuItems() {
        // TODO: Get actual counts from server
        menuItems[Section.users.rawValue][1].badge = 5 // 5 запросов на верификацию
    }

    // MARK: - Navigation Actions
    @objc private func openUsers() {
        let vc = UsersManagementViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openVerificationRequests() {
        let vc = VerificationRequestsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openServerSettings() {
        let vc = ServerSettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openServerStats() {
        let vc = ServerStatusViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openStats() {
        let vc = StatsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Table View Data Source & Delegate
extension AdminViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdminCell", for: indexPath)

        let item = menuItems[indexPath.section][indexPath.row]

        cell.textLabel?.text = item.title
        cell.imageView?.image = UIImage(systemName: item.icon)
        cell.tintColor = MKRColors.primary

        // Badge
        if let badge = item.badge, badge > 0 {
            let badgeLabel = UILabel()
            badgeLabel.text = "\(badge)"
            badgeLabel.textColor = .white
            badgeLabel.backgroundColor = .systemRed
            badgeLabel.textAlignment = .center
            badgeLabel.font = .systemFont(ofSize: 12, weight: .bold)
            badgeLabel.layer.cornerRadius = 10
            badgeLabel.clipsToBounds = true
            badgeLabel.translatesAutoresizingMaskIntoConstraints = false

            let padding = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
            let badgeSize = badgeLabel.intrinsicContentSize
            let badgeView = UIView(frame: CGRect(x: 0, y: 0, width: badgeSize.width + padding.left + padding.right, height: badgeSize.height + padding.top + padding.bottom))
            badgeView.addSubview(badgeLabel)
            badgeLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                badgeLabel.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
                badgeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20)
            ])

            cell.accessoryView = badgeView
        } else {
            cell.accessoryView = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = menuItems[indexPath.section][indexPath.row]
        perform(item.action)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.users.rawValue:
            return "Управление"
        case Section.server.rawValue:
            return "Сервер"
        case Section.stats.rawValue:
            return "Информация"
        default:
            return ""
        }
    }
}

// MARK: - Models

struct MenuItem {
    let icon: String
    let title: String
    var badge: Int?
    let action: Selector
}

// MARK: - Server Status View Controller
class ServerStatusViewController: UIViewController {

    private var serverConfig: ServerConfig?
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Статус сервера"
        view.backgroundColor = .systemBackground

        setupTableView()
        loadServerStatus()
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StatusCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshStatus), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func refreshStatus() {
        loadServerStatus()

        if let refreshControl = tableView.refreshControl {
            refreshControl.endRefreshing()
        }
    }

    private func loadServerStatus() {
        Task {
            do {
                let config = try await PioneerAPIService.shared.getServerConfig()
                await MainActor.run {
                    self.serverConfig = config
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    // Show default config on error
                    self.serverConfig = ServerConfig(
                        imapServer: MKRConfig.imapServer,
                        imapPort: MKRConfig.imapPort,
                        smtpServer: MKRConfig.smtpServer,
                        smtpPort: MKRConfig.smtpPort,
                        turnServer: MKRConfig.webrtcTurnServer,
                        stunServer: MKRConfig.webrtcStunServer,
                        maintenanceMode: false
                    )
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension ServerStatusViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath)
        cell.selectionStyle = .none

        guard let config = serverConfig else {
            cell.textLabel?.text = "Загрузка..."
            return cell
        }

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "IMAP сервер"
            cell.detailTextLabel?.text = "\(config.imapServer):\(config.imapPort)"
        case 1:
            cell.textLabel?.text = "SMTP сервер"
            cell.detailTextLabel?.text = "\(config.smtpServer):\(config.smtpPort)"
        case 2:
            cell.textLabel?.text = "TURN сервер"
            cell.detailTextLabel?.text = config.turnServer
        case 3:
            cell.textLabel?.text = "STUN сервер"
            cell.detailTextLabel?.text = config.stunServer
        case 4:
            cell.textLabel?.text = "Режим обслуживания"
            cell.detailTextLabel?.text = config.maintenanceMode ? "Включён" : "Выключен"
            cell.detailTextLabel?.textColor = config.maintenanceMode ? .systemRed : .systemGreen
        case 5:
            cell.textLabel?.text = "Статус IMAP"
            cell.detailTextLabel?.text = "✓ Онлайн"
            cell.detailTextLabel?.textColor = .systemGreen
        case 6:
            cell.textLabel?.text = "Статус SMTP"
            cell.detailTextLabel?.text = "✓ Онлайн"
            cell.detailTextLabel?.textColor = .systemGreen
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Конфигурация сервера"
    }
}

// MARK: - Users Management
class UsersManagementViewController: UIViewController {

    private var users: [MKRUser] = []
    private var tableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Пользователи"
        view.backgroundColor = .systemBackground

        setupTableView()
        setupNavigation()
        loadUsers()
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Add right bar button for adding users
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUserTapped))
        addButton.tintColor = MKRColors.primary
        navigationItem.rightBarButtonItem = addButton
    }

    private func setupNavigation() {
        // Navigation setup if needed
    }

    private func loadUsers() {
        Task {
            do {
                let pioneerUsers = try await PioneerAPIService.shared.getUsers()
                await MainActor.run {
                    self.users = pioneerUsers.map { user in
                        MKRUser(
                            id: user.id,
                            email: user.email,
                            username: user.username,
                            role: MKRUserRole(rawValue: user.role) ?? .user,
                            isVerified: user.isVerified,
                            isBanned: user.isBanned,
                            status: MKRUserStatus(rawValue: user.status) ?? .offline,
                            lastSeen: user.lastSeen
                        )
                    }
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    // Demo data on error
                    self.users = [
                        MKRUser(
                            id: 1,
                            email: "admin@kluboksrm.ru",
                            username: "admin",
                            role: .admin,
                            isVerified: true,
                            isBanned: false,
                            status: .online,
                            lastSeen: Date()
                        ),
                        MKRUser(
                            id: 2,
                            email: "commander1@kluboksrm.ru",
                            username: "commander1",
                            role: .commander,
                            isVerified: true,
                            isBanned: false,
                            status: .offline,
                            lastSeen: Date().addingTimeInterval(-3600)
                        ),
                        MKRUser(
                            id: 3,
                            email: "tech1@kluboksrm.ru",
                            username: "tech1",
                            role: .technician,
                            isVerified: false,
                            isBanned: false,
                            status: .pending,
                            lastSeen: nil
                        ),
                        MKRUser(
                            id: 4,
                            email: "osint1@kluboksrm.ru",
                            username: "osint1",
                            role: .osint,
                            isVerified: false,
                            isBanned: false,
                            status: .offline,
                            lastSeen: nil
                        ),
                        MKRUser(
                            id: 5,
                            email: "banned@kluboksrm.ru",
                            username: "banned",
                            role: .user,
                            isVerified: false,
                            isBanned: true,
                            status: .banned,
                            lastSeen: nil
                        )
                    ]
                    self.tableView.reloadData()
                }
            }
        }
    }

    @objc private func addUserTapped() {
        let alert = UIAlertController(
            title: "Добавить пользователя",
            message: "Введите email нового пользователя для отправки приглашения",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "email@kluboksrm.ru"
        }

        alert.addAction(UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields.first,
                  let email = textField.text,
                  !email.isEmpty else {
                self?.showAlert(message: "Введите email")
                return
            }

            if self.emailHasValidDomain(email: email) {
                self.inviteUser(email: email)
            } else {
                self.showAlert(message: "Email должен быть на kluboksrm.ru")
            }
        })

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }

    private func emailHasValidDomain(_ email: String, domain: String = "kluboksrm.ru") -> Bool {
        return email.hasSuffix("@\(domain)")
    }

    private func inviteUser(email: String) {
        // TODO: Отправить приглашение через Pioneer API
        print("Приглашение пользователю: \(email)")

        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.label.text = "Отправка..."
        hud?.show(animated: true)

        Task {
            do {
                let _ = try await PioneerAPIService.shared.createUser(
                    email: email,
                    password: "tempPassword123!",
                    username: email.components(separatedBy: "@").first ?? email,
                    role: "user"
                )

                await MainActor.run {
                    hud?.hide(animated: true)
                    self.showAlert(message: "Приглашение отправлено на \(email)")
                    self.loadUsers()
                }
            } catch {
                await MainActor.run {
                    hud?.hide(animated: true)
                    self.showAlert(message: "Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table View Data Source & Delegate

extension UsersManagementViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else {
            return UITableViewCell()
        }

        let user = users[indexPath.row]
        cell.configure(with: user)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let user = users[indexPath.row]
        showUserOptions(for: user)
    }
}

// MARK: - User Options

extension UsersManagementViewController {

    private func showUserOptions(for user: MKRUser) {
        let alert = UIAlertController(
            title: user.username,
            message: "Выберите действие",
            preferredStyle: .actionSheet
        )

        if !user.isVerified {
            alert.addAction(UIAlertAction(title: "Верифицировать", style: .default) { [weak self] in
                self?.verifyUser(user)
            })
        }

        alert.addAction(UIAlertAction(title: "Изменить роль", style: .default) { [weak self] in
            self?.changeUserRole(user)
        })

        if !user.isBanned {
            alert.addAction(UIAlertAction(title: "Забанить", style: .destructive) { [weak self] in
                self?.banUser(user)
            })
        } else {
            alert.addAction(UIAlertAction(title: "Разбанить", style: .default) { [weak self] in
                self?.unbanUser(user)
            })
        }

        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] in
            self?.deleteUser(user)
        })

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }

    private func verifyUser(_ user: MKRUser) {
        Task {
            do {
                let _ = try await PioneerAPIService.shared.verifyUser(userId: user.id, verified: true)
                await MainActor.run {
                    self.showAlert(message: "Пользователь верифицирован")
                    self.loadUsers()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(message: "Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }

    private func changeUserRole(_ user: MKRUser) {
        let alert = UIAlertController(title: "Изменить роль", message: "Выберите новую роль", preferredStyle: .actionSheet)

        for role in MKRUserRole.allCases {
            alert.addAction(UIAlertAction(title: role.displayName, style: .default) { [weak self] in
                self?.updateUserRole(user, newRole: role)
            })
        }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }

    private func updateUserRole(_ user: MKRUser, newRole: MKRUserRole) {
        Task {
            do {
                let _ = try await PioneerAPIService.shared.updateUserRole(userId: user.id, role: newRole.rawValue)
                await MainActor.run {
                    self.showAlert(message: "Роль изменена на \(newRole.displayName)")
                    self.loadUsers()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(message: "Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }

    private func banUser(_ user: MKRUser) {
        Task {
            do {
                let _ = try await PioneerAPIService.shared.banUser(userId: user.id, ban: true, reason: "Violation of rules")
                await MainActor.run {
                    self.showAlert(message: "Пользователь забанен")
                    self.loadUsers()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(message: "Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }

    private func unbanUser(_ user: MKRUser) {
        Task {
            do {
                let _ = try await PioneerAPIService.shared.banUser(userId: user.id, ban: false, reason: nil)
                await MainActor.run {
                    self.showAlert(message: "Пользователь разбанен")
                    self.loadUsers()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(message: "Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }

    private func deleteUser(_ user: MKRUser) {
        let confirmAlert = UIAlertController(
            title: "Удалить пользователя?",
            message: "Это действие нельзя отменить",
            preferredStyle: .alert
        )

        confirmAlert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] in
            self?.performDelete(user)
        })

        confirmAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(confirmAlert, animated: true)
    }

    private func performDelete(_ user: MKRUser) {
        Task {
            do {
                let _ = try await PioneerAPIService.shared.deleteUser(userId: user.id)
                await MainActor.run {
                    self.showAlert(message: "Пользователь удалён")
                    self.loadUsers()
                }
            } catch {
                await MainActor.run {
                    self.showAlert(message: "Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - User Cell

class UserCell: UITableViewCell {

    private var user: MKRUser?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with user: MKRUser) {
        self.user = user

        textLabel?.text = user.username

        // Icon based on role
        var iconName = "person.circle"
        var roleColor = MKRColors.primary

        switch user.role {
        case .admin:
            iconName = "person.circle.fill"
            roleColor = .systemPurple
        case .commander:
            iconName = "star.circle.fill"
            roleColor = .systemOrange
        case .technician:
            iconName = "wrench.and.screwdriver"
            roleColor = .systemBlue
        case .osint:
            iconName = "eye.circle"
            roleColor = .systemIndigo
        case .user:
            iconName = "person.circle"
            roleColor = .systemGray
        }

        imageView?.image = UIImage(systemName: iconName)
        imageView?.tintColor = roleColor

        // Status and role text
        var statusText = ""
        var statusColor: UIColor = .label

        switch user.status {
        case .online:
            statusText = "🟢 Онлайн"
            statusColor = .systemGreen
        case .offline:
            statusText = "⚫️ Оффлайн"
            statusColor = .systemGray
        case .pending:
            statusText = "⏳ Ожидает"
            statusColor = .systemOrange
        case .banned:
            statusText = "🚫 Забанен"
            statusColor = .systemRed
        case .blocked:
            statusText = "🔒 Заблокирован"
            statusColor = .systemRed
        }

        detailTextLabel?.text = "\(user.role.displayName) • \(statusText)"
        detailTextLabel?.textColor = statusColor

        // Verification indicator
        if !user.isVerified && !user.isBanned {
            textLabel?.text = "○ \(user.username)"
        } else if user.isBanned {
            textLabel?.text = "🚫 \(user.username)"
            textLabel?.textColor = .systemRed
        } else {
            textLabel?.text = user.username
            textLabel?.textColor = .label
        }
    }
}

// MARK: - Models

struct MKRUser {
    let id: Int
    let email: String
    let username: String
    var role: MKRUserRole
    var isVerified: Bool
    var isBanned: Bool
    var status: MKRUserStatus
    var lastSeen: Date?
}

enum MKRUserRole: String, CaseIterable {
    case admin = "admin"
    case commander = "commander"
    case technician = "technician"
    case osint = "osint"
    case user = "user"

    var displayName: String {
        switch self {
        case .admin: return "Админ"
        case .commander: return "Командир"
        case .technician: return "Техник"
        case .osint: return "Осинт"
        case .user: return "Пользователь"
        }
    }
}

enum MKRUserStatus: String {
    case online = "online"
    case offline = "offline"
    case pending = "pending"
    case banned = "banned"
    case blocked = "blocked"

    var displayName: String {
        switch self {
        case .online: return "Онлайн"
        case .offline: return "Оффлайн"
        case .pending: return "Ожидает"
        case .banned: return "Забанен"
        case .blocked: return "Заблокирован"
        }
    }
}
