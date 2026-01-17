# ⚠️ ВАЖНО: Интеграция MKR файлов в проект

## Проблема

Ошибка `exit code 65` - MKR файлы существуют в папке, но **НЕ добавлены в Xcode проект**.

---

## ✅ Быстрое решение

### Шаг 1: Убрать MKR файлы для чистой сборки

```bash
cd "/home/makarov/Рабочий стол/Алиса/pioneer/deltachat-ios-original"

# Временно переместить MKR файлы
mkdir -p ../mkr-backup
mv deltachat-ios/Admin ../mkr-backup/
mv deltachat-ios/API ../mkr-backup/
mv deltachat-ios/MKR*.swift ../mkr-backup/

# Залить на GitHub
git add .
git commit -m "Clean build"
git push
```

### Шаг 2: Скачать чистый IPA

1. Дождаться зелёного галочки ✅ в Actions
2. Скачать `MKR-Messenger.zip` из Artifacts
3. Распаковать - получить `deltachat-ios.ipa`

### Шаг 3: Добавить MKR локально

```bash
# Вернуть файлы
mv ../mkr-backup/* deltachat-ios/

# Открыть Xcode
open deltachat-ios.xcworkspace

# В Xcode:
# 1. Добавить Admin/ и API/ в проект (правая кнопка → Add Files)
# 2. Добавить MKR*.swift в проект
# 3. Product → Build
# 4. Product → Archive
```

### Шаг 4: Подписать

```bash
easign sign ~/Desktop/MKRMessenger.ipa -o MKR-signed.ipa
```

---

## 🔧 Что исправить в коде

### Заменить Keychain на UserDefaults:

```swift
class KeychainManager {
    static let shared = KeychainManager()
    private let defaults = UserDefaults.standard

    func save(key: String, data: Data) -> Bool {
        defaults.set(data, forKey: key)
        return true
    }

    func load(key: String) -> String? {
        return defaults.string(forKey: key)
    }

    func delete(key: String) -> Bool {
        defaults.removeObject(forKey: key)
        return true
    }
}
```

---

## Готово к работе!

1. **Чистый Delta Chat:** Сборка на GitHub Actions ✅
2. **С MKR функциями:** Локальная сборка в Xcode
3. **Подпись:** Через easign
