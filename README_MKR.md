# MKR Messenger - Готово к сборке! 🚀

## 📍 Где находится проект

**Полный проект для сборки находится здесь:**
```
/home/makarov/Рабочий стол/Алиса/pioneer/deltachat-ios-original/
```

---

## 🚀 Быстрый старт

### 1. Открыть проект
```bash
cd "/home/makarov/Рабочий стол/Алиса/pioneer/deltachat-ios-original"
open deltachat-ios.xcworkspace
```

⚠️ **Важно:** Открывайте `.xcworkspace`, а не `.xcodeproj`!

### 2. Изменить Bundle Identifier в Xcode
- Выберите проект → Target "deltachat-ios"
- General → Bundle Identifier → измените на `com.mkr.messenger`

### 3. Собрать
- Product → Build (⌘+B)
- Product → Archive (для создания IPA)

### 4. Подписать через easign
```bash
npm install -g easign
easign build/MKRMessenger.ipa --output build/MKRMessenger_signed.ipa
```

---

## 👤 Тестовые пользователи

| Роль | Email | Пароль |
|------|-------|--------|
| 🔴 Admin | admin@kluboksrm.ru | MKR_Admin_2024! |
| ⭐ Commander Alpha | cmdr1.alpha@kluboksrm.ru | Alpha1_Cmdr_2024! |
| ⭐ Commander Bravo | cmdr2.bravo@kluboksrm.ru | Bravo1_Cmdr_2024! |
| 👤 User Alpha | user1.alpha@kluboksrm.ru | Alpha1_User_2024! |
| 👤 User Bravo | user1.bravo@kluboksrm.ru | Bravo1_User_2024! |

---

## 📁 Что добавлено в проект

### MKR файлы в deltachat-ios/:
- `Admin/` - Админ-панель для управления пользователями
- `API/` - Интеграция с Pioneer Backend
- `MKRConfig.swift` - Конфигурация серверов kluboksrm.ru
- `MKRTestUsers.swift` - Тестовые пользователи
- `MKRUserDistribution.swift` - Распределение по отрядам (Alpha, Bravo, Charlie)

---

## 🔧 Конфигурация сервера

### IMAP/SMTP
- IMAP: `kluboksrm.ru:993` (SSL)
- SMTP: `kluboksrm.ru:25` (STARTTLS)

### API
- Base URL: `https://kluboksrm.ru/api/v1`
- Эндпоинты: пользователи, верификация, статистика

### WebRTC (звонки)
- TURN: `turn.kluboksrm.ru:3478`
- STUN: `stun.kluboksrm.ru:3478`

---

## 📖 Документация

- [BUILD_INSTRUCTIONS.md](BUILD_INSTRUCTIONS.md) - Подробная инструкция по сборке
- [DEPLOYMENT.md](../deltachat-ios-main/DEPLOYMENT.md) - Настройка сервера

---

## ✅ Проверка перед сборкой

```bash
# Проверить наличие Xcode
xcodebuild -version

# Проверить CocoaPods
pod --version

# Установить зависимости (если нужно)
cd "/home/makаров/Рабочий стол/Алиса/pioneer/deltachat-ios-original"
pod install
```

---

## 🎯 Следующие шаги

1. Откройте проект в Xcode
2. Измените Bundle Identifier
3. Соберите проект
4. Создайте Archive
5. Подпишите IPA
6. Установите на устройство через Sideloadly

---

## 💬 Поддержка

По вопросам: admin@kluboksrm.ru
