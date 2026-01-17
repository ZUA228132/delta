# ✅ ГОТОВО К ЗАЛИВКЕ НА GITHUB

## Что сделано:

1. ✅ MKR файлы убраны из проекта (временно в `../mkr-backup/`)
2. ✅ Создан рабочий GitHub Actions workflow
3. ✅ Проект готов к чистой сборке Delta Chat

---

## 📋 Следующие шаги:

### 1. Залить на GitHub

```bash
cd "/home/makarov/Рабочий стол/Алиса/pioneer/deltachat-ios-original"

# Инициализировать git (если нет)
git init

# Добавить все файлы
git add .

# Создать коммит
git commit -m "Delta Chat iOS - clean build for MKR"

# Добавить remote (замените на ваш репозиторий)
git remote add origin https://github.com/ВАШ_ЮЗЕР/ВАШ_РЕПО.git

# Залить
git push -u origin main
```

---

### 2. Запустить сборку на GitHub

После пуша автоматом запустится GitHub Actions.

**Или вручную:**
1. Откройте репозиторий на GitHub
2. Перейдите в **Actions**
3. Выберите **Build Delta Chat iOS**
4. Нажмите **Run workflow** → **Run workflow**

---

### 3. Скачать IPA

Когда сборка завершится (зелёная ✅):

1. В том же workflow run прокрутите вниз
2. Найдите секцию **Artifacts**
3. Скачайте **DeltaChat-iOS**
4. Распакуйте ZIP - внутри будет `.ipa` файл

---

### 4. Подписать через easign

```bash
# Установить easign (если нет)
npm install -g easign

# Подписать IPA
easign sign DeltaChat-iOS.ipa -o DeltaChat-signed.ipa

# Установить на устройство
# Через Sideloadly или AltStore
```

---

## 📁 Структура проекта:

```
deltachat-ios-original/
├── .github/workflows/
│   └── build.yml              # ✅ Рабочий workflow
├── deltachat-ios.xcworkspace  # Открывать в Xcode
├── deltachat-ios.xcodeproj
├── deltachat-ios/             # Чистый Delta Chat
├── Podfile
├── Podfile.lock
└── README_MKR.md              # Инструкция

../mkr-backup/                 # MKR файлы (не в проекте)
├── Admin/
├── API/
├── MKRConfig.swift
├── MKRTestUsers.swift
└── MKRUserDistribution.swift
```

---

## 🔧 Где лежат MKR файлы:

```
/home/makarov/Рабочий стол/Алиса/pioneer/mkr-backup/
```

**Когда нужно будет добавить MKR:**
1. Скачать IPA с Delta Chat
2. Распаковать IPA
3. Добавить MKR файлы внутрь
4. Запаковать обратно
5. Подписать

---

## ✅ Проверка перед заливкой:

```bash
# Проверить что MKR файлов нет в проекте
ls deltachat-ios/ | grep -i mkr
# Должно вернуть пустоту

# Проверить что backup есть
ls ../mkr-backup/
# Должно показать: Admin/ API/ MKR*.swift

# Проверить workflow
cat .github/workflows/build.yml
# Должен быть рабочий workflow
```

---

## 📝 Коммит message:

```
Delta Chat iOS - clean build for MKR Messenger

- Removed MKR files temporarily (in ../mkr-backup/)
- Added GitHub Actions workflow for iOS build
- Ready for CI/CD build
```

---

## 🎯 Готово!

Теперь просто:
1. `git push`
2. Скачать IPA из Actions
3. Подписать через easign
4. Установить на iPhone

🚀
