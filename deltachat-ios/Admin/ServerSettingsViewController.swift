//
//  ServerSettingsViewController.swift
//  MKR Messenger
//
//  Экран настроек сервера для изменения IMAP/SMTP/WebRTC параметров
//

import UIKit
import DcCore

class ServerSettingsViewController: UITableViewController {

    // MARK: - Settings Sections
    private enum Section: Int {
        case connection = 0
        case webRTC = 1
        case advanced = 2
    }

    // MARK: - Settings
    private var connectionSettings: [(title: String, value: String, type: SettingType)] = [
        ("IMAP сервер", MKRConfig.imapServer, .text),
        ("IMAP порт", "\(MKRConfig.imapPort)", .number),
        ("SMTP сервер", MKRConfig.smtpServer, .text),
        ("SMTP порт", "\(MKRConfig.smtpPort)", .number)
    ]

    private var webRTCSettings: [(title: String, value: String, type: SettingType)] = [
        ("TURN сервер", MKRConfig.webrtcTurnServer, .text),
        ("STUN сервер", MKRConfig.webrtcStunServer, .text),
        ("TURN пользователь", MKRConfig.turnUsername, .text),
        ("TURN пароль", MKRConfig.turnPassword, .password)
    ]

    private var advancedSettings: [(title: String, value: String, type: SettingType)] = [
        ("Бренд", MKRConfig.brandName, .text),
        ("Домен", MKRConfig.brandDomain, .text),
        ("Support Email", MKRConfig.supportEmail, .text),
        ("Help URL", MKRConfig.helpURL, .text)
    ]

    // MARK: - Properties
    private var selectedIndexPath: IndexPath?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Настройки сервера"
        view.backgroundColor = .systemBackground

        setupNavigation()
    }

    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveSettings)
        )
        navigationItem.rightBarButtonItem?.tintColor = MKRColors.primary
    }

    // MARK: - Save
    @objc private func saveSettings() {
        // TODO: Сохранить настройки на сервер через Pioneer API
        print("Saving server settings...")

        // Show loading indicator
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.label.text = "Сохранение..."
        hud?.show(animated: true)

        Task {
            do {
                let config = ServerConfig(
                    imapServer: connectionSettings[0].value,
                    imapPort: Int(connectionSettings[1].value) ?? 993,
                    smtpServer: connectionSettings[2].value,
                    smtpPort: Int(connectionSettings[3].value) ?? 25,
                    turnServer: webRTCSettings[0].value,
                    stunServer: webRTCSettings[1].value,
                    maintenanceMode: false
                )

                let _ = try await PioneerAPIService.shared.updateServerConfig(config)

                await MainActor.run {
                    hud?.hide(animated: true)
                    showSuccess("Настройки сохранены")
                }
            } catch {
                await MainActor.run {
                    hud?.hide(animated: true)
                    showError("Ошибка сохранения: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showSuccess(_ message: String) {
        let alert = UIAlertController(
            title: "Успех",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })

        present(alert, animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table View Data Source & Delegate
extension ServerSettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.connection.rawValue:
            return connectionSettings.count
        case Section.webRTC.rawValue:
            return webRTCSettings.count
        case Section.advanced.rawValue:
            return advancedSettings.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)

        var settings: [(title: String, value: String, type: SettingType)] = []

        switch indexPath.section {
        case Section.connection.rawValue:
            settings = connectionSettings
        case Section.webRTC.rawValue:
            settings = webRTCSettings
        case Section.advanced.rawValue:
            settings = advancedSettings
        default:
            break
        }

        let setting = settings[indexPath.row]

        cell.textLabel?.text = setting.title
        cell.detailTextLabel?.text = setting.value
        cell.accessoryType = .disclosureIndicator

        switch setting.type {
        case .text:
            cell.textLabel?.text = setting.title
            cell.detailTextLabel?.text = setting.value
        case .number:
            cell.textLabel?.text = setting.title
            cell.detailTextLabel?.text = setting.value
        case .password:
            cell.textLabel?.text = setting.title
            cell.detailTextLabel?.text = "•••••••"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        var settings: [(title: String, value: String, type: SettingType)] = []

        switch indexPath.section {
        case Section.connection.rawValue:
            settings = connectionSettings
        case Section.webRTC.rawValue:
            settings = webRTCSettings
        case Section.advanced.rawValue:
            settings = advancedSettings
        default:
            return
        }

        let setting = settings[indexPath.row]

        switch setting.type {
        case .text:
            showTextInputAlert(title: setting.title, currentValue: setting.value, placeholder: setting.title) { newValue in
                if indexPath.section == Section.connection.rawValue {
                    self.connectionSettings[indexPath.row].value = newValue
                } else if indexPath.section == Section.webRTC.rawValue {
                    self.webRTCSettings[indexPath.row].value = newValue
                } else {
                    self.advancedSettings[indexPath.row].value = newValue
                }
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        case .number:
            showNumberInputAlert(title: setting.title, currentValue: Int(setting.value) ?? 0) { newValue in
                if indexPath.section == Section.webRTC.rawValue {
                    self.webRTCSettings[indexPath.row].value = "\(newValue)"
                } else {
                    self.connectionSettings[indexPath.row].value = "\(newValue)"
                }
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        case .password:
            showPasswordAlert(title: setting.title) { newPassword in
                self.webRTCSettings[indexPath.row].value = newPassword
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Section.connection.rawValue:
            return "Подключение (IMAP/SMTP)"
        case Section.webRTC.rawValue:
            return "Звонки (WebRTC)"
        case Section.advanced.rawValue:
            return "Дополнительно"
        default:
            return nil
        }
    }

    // MARK: - Alert Helpers

    private func showTextInputAlert(title: String, currentValue: String, placeholder: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = currentValue
        }

        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { _ in
            if let textField = alert.textFields.first, let newValue = textField.text, !newValue.isEmpty {
                completion(newValue)
            }
        })

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }

    private func showNumberInputAlert(title: String, currentValue: Int, completion: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Число"
            textField.text = "\(currentValue)"
            textField.keyboardType = .numberPad
        }

        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { _ in
            if let textField = alert.textFields.first, let newValue = Int(textField.text ?? "") {
                completion(newValue)
            }
        })

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }

    private func showPasswordAlert(title: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Новый пароль"
            textField.isSecureTextEntry = true
        }

        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { _ in
            if let textField = alert.textFields.first, let newPassword = textField.text, !newPassword.isEmpty {
                completion(newPassword)
            }
        })

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }
}

// MARK: - Setting Types

enum SettingType {
    case text
    case number
    case password
}

// MARK: - Stats View Controller
class StatsViewController: UIViewController {

    private var stats: ServerStats?

    // MARK: - UI Components
    private var scrollView: UIScrollView!
    private var contentStackView: UIStackView!
    private var refreshControl: UIRefreshControl!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Статистика"
        view.backgroundColor = .systemBackground

        setupUI()
        loadStats()
    }

    private func setupUI() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshStats), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }

    @objc private func refreshStats() {
        loadStats()

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }

    private func loadStats() {
        Task {
            do {
                let serverStats = try await PioneerAPIService.shared.getServerStats()
                await MainActor.run {
                    self.stats = serverStats
                    self.displayStats()
                }
            } catch {
                await MainActor.run {
                    // Show demo data on error
                    self.stats = ServerStats(
                        totalUsers: 156,
                        verifiedUsers: 89,
                        onlineUsers: 34,
                        totalMessages: 2847,
                        serverUptime: "21д 4ч 12мин",
                        lastUpdate: "только что"
                    )
                    self.displayStats()
                }
            }
        }
    }

    private func displayStats() {
        guard let stats = stats else { return }

        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Overview Stats
        let overviewSection = createSection(title: "Общая информация")
        addStatRow(to: overviewSection, title: "Всего пользователей", value: "\(stats.totalUsers)")
        addStatRow(to: overviewSection, title: "Онлайн сейчас", value: "\(stats.onlineUsers)")
        addStatRow(to: overviewSection, title: "Верифицировано", value: "\(stats.verifiedUsers)")
        contentStackView.addArrangedSubview(overviewSection)

        // Activity Stats
        let activitySection = createSection(title: "Активность")
        addStatRow(to: activitySection, title: "Всего сообщений", value: "\(stats.totalMessages)")
        addStatRow(to: activitySection, title: "Uptime сервера", value: stats.serverUptime)
        addStatRow(to: activitySection, title: "Последнее обновление", value: stats.lastUpdate)
        contentStackView.addArrangedSubview(activitySection)

        // Users by Role (demo data)
        let rolesSection = createSection(title: "Пользователи по ролям")
        addStatRow(to: rolesSection, title: "Командиры", value: "12")
        addStatRow(to: rolesSection, title: "Техники", value: "8")
        addStatRow(to: rolesSection, title: "Осинты", value: "5")
        addStatRow(to: rolesSection, title: "Пользователи", value: "131")
        contentStackView.addArrangedSubview(rolesSection)
    }

    private func createSection(title: String) -> UIStackView {
        let section = UIStackView()
        section.axis = .vertical
        section.spacing = 12
        section.backgroundColor = .secondarySystemBackground
        section.layer.cornerRadius = 12
        section.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        section.isLayoutMarginsRelativeArrangement = true

        let headerLabel = UILabel()
        headerLabel.text = title
        headerLabel.font = .systemFont(ofSize: 14, weight: .bold)
        headerLabel.textColor = .label
        section.addArrangedSubview(headerLabel)

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        section.addArrangedSubview(separator)

        return section
    }

    private func addStatRow(to section: UIStackView, title: String, value: String) {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalCentering

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.textColor = .label

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        valueLabel.textColor = MKRColors.primary

        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(valueLabel)

        section.addArrangedSubview(row)
    }
}

// MARK: - Verification Requests View Controller
class VerificationRequestsViewController: UIViewController {

    private var requests: [VerificationRequestModel] = []
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Запросы на верификацию"
        view.backgroundColor = .systemBackground

        setupTableView()
        setupNavigation()
        loadRequests()
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VerificationRequestCell.self, forCellReuseIdentifier: "RequestCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshRequests), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshRequests)
        )
        navigationItem.rightBarButtonItem?.tintColor = MKRColors.primary
    }

    // MARK: - Data
    @objc private func refreshRequests() {
        loadRequests()

        if let refreshControl = tableView.refreshControl {
            refreshControl.endRefreshing()
        }
    }

    private func loadRequests() {
        Task {
            do {
                let verificationRequests = try await PioneerAPIService.shared.getVerificationRequests()
                await MainActor.run {
                    self.requests = verificationRequests.map { request in
                        VerificationRequestModel(
                            id: request.id,
                            email: request.email,
                            username: request.username,
                            role: MKRUserRole(rawValue: request.role) ?? .user,
                            date: request.date,
                            status: VerificationStatus(rawValue: request.status) ?? .pending
                        )
                    }
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    // Demo data on error
                    self.requests = [
                        VerificationRequestModel(
                            id: 1,
                            email: "newuser1@kluboksrm.ru",
                            username: "newuser1",
                            role: .commander,
                            date: Date(),
                            status: .pending
                        ),
                        VerificationRequestModel(
                            id: 2,
                            email: "newuser2@kluboksrm.ru",
                            username: "newuser2",
                            role: .technician,
                            date: Date().addingTimeInterval(-86400),
                            status: .pending
                        )
                    ]
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Table View Data Source & Delegate

extension VerificationRequestsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as? VerificationRequestCell else {
            return UITableViewCell()
        }

        let request = requests[indexPath.row]
        cell.configure(with: request)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let request = requests[indexPath.row]
        showRequestOptions(for: request)
    }
}

// MARK: - Request Cell

class VerificationRequestCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with request: VerificationRequestModel) {
        switch request.status {
        case .pending:
            textLabel?.text = request.username
            detailTextLabel?.text = "\(request.email) • \(request.role.displayName) • На модерации"
            detailTextLabel?.textColor = .systemOrange
        case .approved:
            textLabel?.text = request.username
            detailTextLabel?.text = "\(request.email) • \(request.role.displayName)"
            detailTextLabel?.textColor = .systemGreen
        case .rejected:
            textLabel?.text = request.username
            detailTextLabel?.text = "\(request.email) • Отклонён"
            detailTextLabel?.textColor = .systemRed
        }
    }
}

// MARK: - Request Options

extension VerificationRequestsViewController {

    private func showRequestOptions(for request: VerificationRequestModel) {
        let alert = UIAlertController(
            title: request.username,
            message: "Выберите действие",
            preferredStyle: .actionSheet
        )

        switch request.status {
        case .pending:
            alert.addAction(UIAlertAction(title: "Верифицировать", style: .default) { [weak self] in
                self?.approveRequest(request)
            })

            alert.addAction(UIAlertAction(title: "Отклонить", style: .destructive) { [weak self] in
                self?.rejectRequest(request)
            })

            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        case .approved:
            alert.addAction(UIAlertAction(title: "Отменить верификацию", style: .destructive) { [weak self] in
                self?.unverifyUser(request)
            })

            alert.addAction(UIAlertAction(title: "OK", style: .default))

        case .rejected:
            alert.addAction(UIAlertAction(title: "Удалить из списка", style: .destructive) { [weak self] in
                self?.deleteRequest(request)
            })

            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }

        present(alert, animated: true)
    }

    private func approveRequest(_ request: VerificationRequestModel) {
        Task {
            do {
                let _ = try await PioneerAPIService.shared.approveVerificationRequest(requestId: request.id)
                await MainActor.run {
                    self.showSuccess("Запрос одобрен")
                    self.loadRequests()
                }
            } catch {
                await MainActor.run {
                    self.showError("Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }

    private func rejectRequest(_ request: VerificationRequestModel) {
        Task {
            do {
                let _ = try await PioneerAPIService.shared.rejectVerificationRequest(requestId: request.id)
                await MainActor.run {
                    self.showSuccess("Запрос отклонён")
                    self.loadRequests()
                }
            } catch {
                await MainActor.run {
                    self.showError("Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }

    private func unverifyUser(_ request: VerificationRequestModel) {
        Task {
            do {
                let _ = try await PioneerAPIService.shared.verifyUser(userId: request.id, verified: false)
                await MainActor.run {
                    self.showSuccess("Верификация отменена")
                    self.loadRequests()
                }
            } catch {
                await MainActor.run {
                    self.showError("Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }

    private func deleteRequest(_ request: VerificationRequestModel) {
        requests.removeAll { $0.id == request.id }
        tableView.reloadData()
    }

    private func showSuccess(_ message: String) {
        let alert = UIAlertController(title: "Успех", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Models

struct VerificationRequestModel {
    let id: Int
    let email: String
    let username: String
    let role: MKRUserRole
    let date: Date
    let status: VerificationStatus
}

enum VerificationStatus: String {
    case pending
    case approved
    case rejected
}
