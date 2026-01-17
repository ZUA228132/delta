//
//  MKRConfig.swift
//  MKR Messenger
//
//  Configuration for MKR branded messaging servers
//  Использует Delta Chat протокол (IMAP/SMTP) на kluboksrm.ru
//

import Foundation

public struct MKRConfig {

    // MARK: - Environment
    /// Режим работы приложения
    public enum Environment {
        case production
        case staging
        case development
        case debug

        var isProduction: Bool {
            return self == .production
        }

        var isDevelopment: Bool {
            return self == .development || self == .debug
        }
    }

    /// Текущее окружение
    public static let environment: Environment = .production

    // MARK: - Server Configuration
    /// MKR Server Configuration for Delta Chat (IMAP/SMTP)

    /// IMAP Server Configuration (для получения сообщений)
    public static let imapServer = "kluboksrm.ru"
    public static let imapPort = 993
    public static let imapSecurity = "ssl"  // Options: "automatic", "ssl", "starttls", "plain"

    /// SMTP Server Configuration (для отправки сообщений)
    public static let smtpServer = "kluboksrm.ru"
    public static let smtpPort = 25
    public static let smtpSecurity = "starttls"  // Options: "automatic", "ssl", "starttls", "plain"

    /// TURN/STUN Server Configuration (для WebRTC звонков)
    public static let webrtcTurnServer = "turn.kluboksrm.ru"
    public static let webrtcStunServer = "stun.kluboksrm.ru:3478"
    public static let turnUsername = "mkr"
    public static let turnPassword = "mkr_turn_secret_password_2024"

    /// WebRTC Signaling Server (опционально, если используется Pioneer API)
    public static let webrtcSignalingServer = "wss://kluboksrm.ru/call"

    // MARK: - API Configuration
    /// Pioneer API Configuration
    public struct API {
        public static let baseURL: String = {
            switch environment {
            case .production:
                return "https://kluboksrm.ru"
            case .staging:
                return "https://staging.kluboksrm.ru"
            case .development:
                return "https://dev.kluboksrm.ru"
            case .debug:
                return "http://localhost:3000"
            }
        }()

        public static let apiVersion = "/v1"
        public static let apiURL = "\(baseURL)/api\(apiVersion)"

        /// API Timeout в секундах
        public static let timeout: TimeInterval = 30

        /// Включить логирование API запросов
        public static let enableLogging: Bool = {
            switch environment {
            case .production, .staging:
                return false
            case .development, .debug:
                return true
            }
        }()
    }

    // MARK: - Brand Configuration
    public static let brandName = "MKR"
    public static let brandDomain = "kluboksrm.ru"
    public static let supportEmail = "admin@kluboksrm.ru"

    // MARK: - Feature Flags
    public static let enableVoiceCalls = true
    public static let enableVideoCalls = true
    public static let enableE2EEncryption = true
    public static let enableReadReceipts = true
    public static let enableTypingIndicators = true

    // MARK: - Admin Features
    /// Включить админ-панель (только для пользователей с ролью admin)
    public static let enableAdminPanel = true

    /// Разрешить создание тестовых пользователей (только в development)
    public static var allowTestUserCreation: Bool {
        return environment.isDevelopment
    }

    // MARK: - Default Account Settings
    /// Когда пользователи регистрируются с @kluboksrm.ru email
    public static func getDefaultLoginParams(for email: String) -> (imapServer: String, imapPort: Int, smtpServer: String, smtpPort: Int) {
        // Если email @kluboksrm.ru, используем наши сервера
        if email.hasSuffix("@\(brandDomain)") {
            return (imapServer, imapPort, smtpServer, smtpPort)
        }
        // Иначе пользователь настраивает вручную или auto-discovery
        return ("", 0, "", 0)
    }

    // MARK: - Help & Support URLs
    public static let helpURL = "https://kluboksrm.ru/help"
    public static let privacyPolicyURL = "https://kluboksrm.ru/privacy"
    public static let termsOfServiceURL = "https://kluboksrm.ru/terms"
    public static let imprintURL = "https://kluboksrm.ru/imprint"

    // MARK: - App Store / Review URLs
    public static let appStoreURL = "https://apps.apple.com/app/mkr-messenger"
    public static let reviewURL = "https://kluboksrm.ru/review"

    // MARK: - Security & Privacy
    /// Требовать верификацию пользователей
    public static let requireVerification = true

    /// Максимальное количество неудачных попыток входа
    public static let maxFailedLoginAttempts = 5

    /// Время блокировки после неудачных попыток (в минутах)
    public static let lockoutDuration: TimeInterval = 15 * 60

    // MARK: - File & Media Limits
    /// Максимальный размер файла для отправки (в байтах) - 100MB
    public static let maxFileSize: Int64 = 100 * 1024 * 1024

    /// Максимальный размер изображения (в байтах) - 25MB
    public static let maxImageSize: Int64 = 25 * 1024 * 1024

    /// Максимальное разрешение видео
    public static let maxVideoResolution = "1920x1080"

    // MARK: - Cache Settings
    /// Размер кэша сообщений (в количестве)
    public static let messageCacheSize = 1000

    /// Размер кэша изображений (в MB)
    public static let imageCacheSize: Int64 = 500 * 1024 * 1024

    // MARK: - Rate Limiting
    /// Максимум сообщений в минуту
    public static let maxMessagesPerMinute = 30

    /// Максимум запросов к API в секунду
    public static let maxAPIRequestsPerSecond = 10

    // MARK: - Background Tasks
    /// Интервал обновления в фоне (в секундах)
    public static let backgroundFetchInterval: TimeInterval = 300

    /// Включить фоновую синхронизацию
    public static let enableBackgroundSync = true

    // MARK: - Logging & Analytics
    /// Включить логирование (только для development)
    public static var enableLogging: Bool {
        return environment.isDevelopment
    }

    /// Включить аналитику
    public static let enableAnalytics = false

    /// Уровень логирования
    public enum LogLevel {
        case verbose
        case debug
        case info
        case warning
        case error
        case none
    }

    public static var logLevel: LogLevel {
        switch environment {
        case .production:
            return .error
        case .staging:
            return .warning
        case .development:
            return .debug
        case .debug:
            return .verbose
        }
    }

    // MARK: - Provider Information
    /// Returns provider information for MKR email addresses
    public static let providerInfo = """
    MKR Messaging Service

    Welcome to MKR! Your messages are secured with end-to-end encryption.

    IMAP: \(imapServer):\(imapPort)
    SMTP: \(smtpServer):\(smtpPort)

    For support, visit: \(helpURL)
    """

    // MARK: - Test Accounts (для тестирования)
    /// Тестовые аккаунты для проверки работы сервера
    /// ВНИМАНИЕ: Использовать только в development/testing окружении!
    public static let testAccounts = [
        "admin@kluboksrm.ru:MKR_Admin_2024!",
        "commander1@kluboksrm.ru:Cmdr1_Pass_2024!",
        "tech1@kluboksrm.ru:Tech1_Pass_2024!",
        "user1@kluboksrm.ru:User1_Pass_2024!"
    ]

    // MARK: - Configuration Validation
    /// Проверить конфигурацию перед запуском
    public static func validate() -> [ValidationError] {
        var errors: [ValidationError] = []

        // Проверка серверов
        if imapServer.isEmpty {
            errors.append(ValidationError(field: "IMAP Server", message: "IMAP server address is empty"))
        }

        if smtpServer.isEmpty {
            errors.append(ValidationError(field: "SMTP Server", message: "SMTP server address is empty"))
        }

        // Проверка портов
        if imapPort < 1 || imapPort > 65535 {
            errors.append(ValidationError(field: "IMAP Port", message: "Invalid IMAP port: \(imapPort)"))
        }

        if smtpPort < 1 || smtpPort > 65535 {
            errors.append(ValidationError(field: "SMTP Port", message: "Invalid SMTP port: \(smtpPort)"))
        }

        // Проверка TURN credentials в production
        if environment.isProduction {
            if turnUsername.isEmpty || turnPassword.isEmpty {
                errors.append(ValidationError(field: "TURN", message: "TURN credentials are missing"))
            }
        }

        return errors
    }

    /// Получить описание конфигурации для отладки
    public static var debugDescription: String {
        return """
        MKR Configuration
        ==================
        Environment: \(environment)
        IMAP: \(imapServer):\(imapPort) (\(imapSecurity))
        SMTP: \(smtpServer):\(smtpPort) (\(smtpSecurity))
        TURN: \(webrtcTurnServer) (\(turnUsername))
        STUN: \(webrtcStunServer)
        API: \(API.apiURL)
        Admin Panel: \(enableAdminPanel)
        Logging: \(enableLogging) (level: \(logLevel))
        """
    }
}

// MARK: - Validation Error

public struct ValidationError {
    public let field: String
    public let message: String

    public var localizedDescription: String {
        return "\(field): \(message)"
    }
}

// MARK: - MKR Colors (для UI)

public struct MKRColors {
    public static let primary = UIColor(red: 0.0, green: 0.48, blue: 0.98, alpha: 1.0)
    public static let secondary = UIColor(red: 0.0, green: 0.73, blue: 1.0, alpha: 1.0)
    public static let accent = UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
    public static let success = UIColor.systemGreen
    public static let warning = UIColor.systemOrange
    public static let error = UIColor.systemRed
    public static let unreadBadge = UIColor.systemRed
}

// MARK: - Configuration Export

extension MKRConfig {

    /// Экспорт конфигурации в JSON (для backend/деплоя)
    public static func exportToJSON() -> String {
        let config: [String: Any] = [
            "environment": "\(environment)",
            "imap": [
                "server": imapServer,
                "port": imapPort,
                "security": imapSecurity
            ],
            "smtp": [
                "server": smtpServer,
                "port": smtpPort,
                "security": smtpSecurity
            ],
            "webrtc": [
                "turn_server": webrtcTurnServer,
                "stun_server": webrtcStunServer,
                "turn_username": turnUsername,
                "turn_password": turnPassword
            ],
            "api": [
                "base_url": API.baseURL,
                "version": API.apiVersion
            ],
            "features": [
                "voice_calls": enableVoiceCalls,
                "video_calls": enableVideoCalls,
                "e2e_encryption": enableE2EEncryption,
                "admin_panel": enableAdminPanel
            ]
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: config, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "{}"
        }

        return jsonString
    }

    /// Экспорт переменных окружения (для деплоя)
    public static func exportEnvVars() -> String {
        return """
        # MKR Messenger Configuration
        # Environment: \(environment)

        # IMAP/SMTP Configuration
        MKR_IMAP_SERVER=\(imapServer)
        MKR_IMAP_PORT=\(imapPort)
        MKR_IMAP_SECURITY=\(imapSecurity)

        MKR_SMTP_SERVER=\(smtpServer)
        MKR_SMTP_PORT=\(smtpPort)
        MKR_SMTP_SECURITY=\(smtpSecurity)

        # WebRTC Configuration
        MKR_TURN_SERVER=\(webrtcTurnServer)
        MKR_STUN_SERVER=\(webrtcStunServer)
        MKR_TURN_USERNAME=\(turnUsername)
        MKR_TURN_PASSWORD=\(turnPassword)

        # API Configuration
        MKR_API_BASE_URL=\(API.baseURL)
        MKR_API_VERSION=\(API.apiVersion)

        # Features
        MKR_ENABLE_VOICE_CALLS=\(enableVoiceCalls)
        MKR_ENABLE_VIDEO_CALLS=\(enableVideoCalls)
        MKR_ENABLE_ADMIN_PANEL=\(enableAdminPanel)

        # Security
        MKR_REQUIRE_VERIFICATION=\(requireVerification)
        MKR_MAX_LOGIN_ATTEMPTS=\(maxFailedLoginAttempts)

        # Rate Limiting
        MKR_MAX_MESSAGES_PER_MINUTE=\(maxMessagesPerMinute)
        MKR_MAX_API_REQUESTS_PER_SECOND=\(maxAPIRequestsPerSecond)
        """
    }
}
