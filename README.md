# KZ Business Database

Локальный веб-сервер для ведения базы данных казахстанских компаний. Данные хранятся в файлах `.xlsx` на Google Drive. Поиск информации о компаниях выполняется через Gemini 2.5 Flash.

---

## Возможности

- Чтение всех `.xlsx`-файлов из папки Google Drive при запуске
- Автоматическое объединение данных и дедупликация по названию компании
- Сохранение всех изменений обратно в `database.xlsx` на Drive
- Поиск информации о компании через Gemini API
- Работа по локальной сети и через интернет (ngrok)

---

## Структура проекта

```
project/
  server.py               # основной сервер
  index.html              # фронтенд
  service_account.json    # ключ сервисного аккаунта Google (не публиковать)
  .env                    # переменные окружения
```

---

## Установка

**1. Установите зависимости**

```bash
pip install google-api-python-client google-auth openpyxl google-generativeai
```

**2. Создайте файл `.env`**

```env
GEMINI_API_KEY=ваш_ключ_gemini
```

---

## Настройка Google Drive

### 1. Создание сервисного аккаунта

1. Откройте [console.cloud.google.com](https://console.cloud.google.com) и создайте проект
2. Перейдите в **APIs & Services → Library**, найдите **Google Drive API** и включите его
3. Перейдите в **APIs & Services → Credentials → Create Credentials → Service Account**
4. Укажите любое имя, нажмите **Create and Continue**, затем **Done**
5. Откройте созданный аккаунт → вкладка **Keys → Add Key → Create new key → JSON**
6. Скачайте JSON-файл, переименуйте в `service_account.json` и положите рядом с `server.py`

> `service_account.json` содержит приватный ключ. Не добавляйте его в репозиторий — добавьте в `.gitignore`.

### 2. Доступ к папке Drive

1. Откройте нужную папку в Google Drive
2. Нажмите правой кнопкой → **Поделиться**
3. Вставьте значение поля `client_email` из `service_account.json`
4. Выберите уровень доступа **Редактор** и нажмите **Отправить**

### 3. ID папки

ID папки — часть ссылки после `/folders/`:

```
https://drive.google.com/drive/folders/13SfBTZqqFogzm4j46Dkqp_XUWOTKVerP
                                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                        это и есть GDRIVE_FOLDER_ID
```

Значение уже указано в `server.py` в переменной `GDRIVE_FOLDER_ID`.

---

## Запуск

```bash
python server.py
```

После запуска сервер выведет адреса:

| Способ | Адрес |
|---|---|
| Локально | `http://localhost:8000` |
| По сети (Wi-Fi) | `http://[IP-адрес]:8000` |
| Через интернет | `ngrok http 8000` |

---

## API

### `GET /api/load-local`

Читает все `.xlsx` из папки Drive и возвращает объединённый список компаний.

```json
{
  "success": true,
  "data": [ { "Company name": "...", "City": "...", ... } ],
  "count": 342
}
```

---

### `POST /api/save-all`

Принимает полный массив компаний и перезаписывает `database.xlsx` на Drive.

Тело запроса:
```json
{ "data": [ { "Company name": "...", ... } ] }
```

Ответ:
```json
{ "success": true, "saved": 342 }
```

---

### `POST /api/search`

Ищет информацию о компании через Gemini API.

Тело запроса:
```json
{ "company": "Halyk Bank", "categories": "Банк, Финансы, Страхование" }
```

Ответ:
```json
{
  "success": true,
  "data": {
    "Company name": "Halyk Bank",
    "Category": "Банк",
    "City": "Алматы",
    "Website": "halykbank.kz",
    "Status": "Активный"
  }
}
```

---

## Поля базы данных

| Поле | Описание |
|---|---|
| `Company name` | Название компании |
| `Category` | Категория из предустановленного списка |
| `Status` | Статус записи |
| `City` | Город |
| `Website` | Сайт |
| `Email` | Email |
| `Phone` | Телефон |
| `Address` | Адрес |
| `CEO-1` | Имя первого руководителя |
| `Position-1` | Должность первого руководителя |
| `CEO-2` | Имя второго руководителя |
| `Position-2` | Должность второго руководителя |
| `Linkedin` | LinkedIn |
| `Status-L` | Статус LinkedIn |
| `Facebook` | Facebook |
| `Status-F` | Статус Facebook |

---

## Логика работы с несколькими файлами

- При запуске сервер читает все `.xlsx` из папки Drive в алфавитном порядке
- Дубликаты определяются по полю `Company name` без учёта регистра
- При совпадении имён сохраняется запись из файла, обработанного первым
- Сохранение всегда производится в один файл — `database.xlsx`
- Если `database.xlsx` уже существует в папке — он перезаписывается, если нет — создаётся

---

## Типичные ошибки

| Ошибка | Решение |
|---|---|
| `service_account.json не найден` | Положите файл рядом с `server.py` |
| `403 Forbidden` от Drive API | Проверьте, что `client_email` получил доступ к папке |
| `GEMINI_API_KEY не задан` | Добавьте ключ в `.env` |
| `.xlsx не найдены в папке` | Проверьте `GDRIVE_FOLDER_ID` и права сервисного аккаунта |
| `ModuleNotFoundError` | Выполните `pip install google-api-python-client google-auth openpyxl google-generativeai` |

---

## .gitignore

```
.env
service_account.json
__pycache__/
*.pyc
```
