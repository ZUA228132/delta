# MKR Messenger - Инструкция по сборке и установке

## Что было сделано

В проект Delta Chat iOS добавлены файлы MKR брендинга и интеграции с Pioneer Backend:

### Добавленные файлы:

```
deltachat-ios/
├── Admin/
│   ├── AdminViewController.swift       # Админ-панель
│   └── ServerSettingsViewController.swift  # Настройки сервера
├── API/
│   └── PioneerAPIService.swift         # API сервис для Pioneer backend
├── MKRConfig.swift                     # Конфигурация серверов
├── MKRTestUsers.swift                  # Тестовые пользователи
└── MKRUserDistribution.swift           # Распределение по отрядам
```

---

## Шаг 1: Открытие проекта в Xcode

1. Откройте терминал и перейдите в папку проекта:
```bash
cd "/home/makarov/Рабочий стол/Алиса/pioneer/deltachat-ios-original"
```

2. Откройте workspace (а не xcodeproj!):
```bash
open deltachat-ios.xcworkspace
```

Или дважды кликните на файл `deltachat-ios.xcworkspace` в Finder.

---

## Шаг 2: Установка зависимостей

Проект использует CocoaPods. Если не установлен:

```bash
sudo gem install cocoapods
```

Установка pods:
```bash
cd "/home/makarov/Рабочий стол/Алиса/pioneer/deltachat-ios-original"
pod install
```

---

## Шаг 3: Изменение Bundle Identifier

В Xcode:

1. Выберите проект `deltachat-ios` в навигаторе
2. Выберите цель `deltachat-ios` (target)
3. Во вкладке "General" найдите "Bundle Identifier"
4. Измените на уникальный, например: `com.mkr.messenger`

---

## Шаг 4: Настройка provisioning profile

### Вариант A: Свой сертификат разработчика

1. Перейдите на [Apple Developer](https://developer.apple.com)
2. Создайте App ID с Bundle Identifier из шага 3
3. Создайте Development Certificate
4. Создайте Provisioning Profile
5. Скачайте и установите профиль

### Вариант B: Подпись через easign (без сертификата)

```bash
npm install -g easign
```

---

## Шаг 5: Сборка проекта

### В Xcode:

1. Выберите устройство (не симулятор!)
2. Product → Build (⌘+B)

Убедитесь что нет ошибок. Если есть - сообщите мне.

---

## Шаг 6: Создание IPA

### Через Xcode:

1. Product → Archive
2. После завершения откроется Organizer
3. Выберите архив → Distribute App
4. Выберите "Ad Hoc" или "Enterprise"
5. Сохраните IPA

### Через командную строку:

```bash
cd "/home/makarov/Рабочий стол/Алиса/pioneer/deltachat-ios-original"

# Сборка
xcodebuild -workspace deltachat-ios.xcworkspace \
           -scheme deltachat-ios \
           -configuration Release \
           -archivePath build/MKRMessenger.xcarchive \
           archive

# Экспорт IPA
xcodebuild -exportArchive \
           -archivePath build/MKRMessenger.xcarchive \
           -exportPath build \
           -exportOptionsPlist ExportOptions.plist
```

---

## Шаг 7: Подпись IPA через easign

```bash
# Установка easign (если не установлен)
npm install -g easign

# Подпись
easign sign build/MKRMessenger.ipa \
  --certificate "Мой Сертификат" \
  --provisioning "MKR_Distribution" \
  --output build/MKRMessenger_signed.ipa
```

---

## Шаг 8: Установка на устройство

### Через Sideloadly (рекомендуется):

1. Скачайте [Sideloadly](https://sideloadly.io/)
2. Подключите iPhone к компьютеру
3. Откройте Sideloadly
4. Перетащите подписанный IPA
5. Введите Apple ID и пароль
6. Дождитесь установки

### Через AltStore:

1. Установите [AltStore](https://altstore.io/)
2. На устройстве откройте AltStore
3. Нажмите "+" → выберите IPA
4. Введите credentials

---

## Тестовые пользователи для входа

### Администратор
- Email: `admin@kluboksrm.ru`
- Пароль: `MKR_Admin_2024!`

### Командиры
- Email: `cmdr1.alpha@kluboksrm.ru`
- Пароль: `Alpha1_Cmdr_2024!`

- Email: `cmdr2.bravo@kluboksrm.ru`
- Пароль: `Bravo1_Cmdr_2024!`

### Обычные пользователи
- Email: `user1.alpha@kluboksrm.ru`
- Пароль: `Alpha1_User_2024!`

---

## Структура проекта после добавления MKR файлов

```
deltachat-ios-original/
├── deltachat-ios.xcworkspace    # ОТКРЫВАЙТЕ ЭТО
├── deltachat-ios.xcodeproj      # Не открывать напрямую
├── deltachat-ios/
│   ├── Admin/                   # Админ-панель MKR
│   ├── API/                     # API сервис
│   ├── MKRConfig.swift          # Конфигурация
│   ├── MKRTestUsers.swift       # Тестовые юзеры
│   ├── MKRUserDistribution.swift # Отряды
│   └── ... (остальные файлы Delta Chat)
├── DcCore/                      # Delta Chat Core
├── Podfile                      # Зависимости
└── BUILD_INSTRUCTIONS.md        # Этот файл
```

---

## Возможные проблемы

### "No such module 'DcCore'"

**Решение:**
```bash
pod install
```

И открывайте `.xcworkspace`, а не `.xcodeproj`

### Ошибки подписи кода

**Решение:** В Xcode → Signing & Capabilities:
- Выберите Automatically manage signing
- Или добавьте свой provisioning profile

### "Missing provisioning profile"

**Решение:**
1. Apple Developer → Certificates → Создать Development Certificate
2. Identifiers → Создать App ID
3. Profiles → Создать Provisioning Profile
4. Скачать и установить

---

## Следующие шаги

После успешной сборки:

1. Протестируйте вход с тестовыми пользователями
2. Проверьте админ-панель (доступна только для admin)
3. Протестируйте создание групп и чатов
4. Проверьте работу уведомлений

---

## Контакты для поддержки

- Email: admin@kluboksrm.ru
- Telegram: (укажите если есть)

---

## Полная документация

Смотрите также:
- [DEPLOYMENT.md](../deltachat-ios-main/DEPLOYMENT.md) - Настройка сервера
- [MKR_ADMIN_INTEGRATION.md](../deltachat-ios-main/MKR_ADMIN_INTEGRATION.md) - Интеграция админки
