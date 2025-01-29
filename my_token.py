import requests
import json
import time
import hashlib
import hmac

# Конфигурация
APP_ID = "43473c32f2d34edda79c9bf75ce6a909"
APP_CERTIFICATE = "fc2f3b68dd7140cbb32ad009dd3cb65f"
BASE_URL = "https://a41.easemob.com"  # Основной URL API. Обновите, если нужно.
ORG_NAME = "zcord-123"  # Имя организации из консоли
APP_NAME = "zcord-123"  # Имя приложения из консоли
USER_ID = "testUser123"  # Пользователь, для которого создается токен
TOKEN_EXPIRATION_SECONDS = 3600  # Время жизни токена (в секундах)

# Генерация URL для API
TOKEN_URL = f"{BASE_URL}/{ORG_NAME}/{APP_NAME}/token"

# Генерация временной метки и подписи
timestamp = str(int(time.time() * 1000))  # Текущая временная метка в миллисекундах
signature_raw = f"{APP_ID}{timestamp}"
signature = hmac.new(APP_CERTIFICATE.encode(), signature_raw.encode(), hashlib.sha256).hexdigest()

# Создание тела запроса
payload = {
    "grant_type": "password",
    "username": USER_ID,
    "password": "123456",  # Пароль пользователя, должен быть установлен при регистрации пользователя.
}

# Заголовки
headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {signature}",
    "x-agora-appid": APP_ID,
    "x-request-timestamp": timestamp,
}

# Отправка POST-запроса
response = requests.post(TOKEN_URL, headers=headers, data=json.dumps(payload))

# Обработка результата
if response.status_code == 200:
    token = response.json().get("access_token")
    print(f"Токен успешно создан: {token}")
else:
    print(f"Ошибка при создании токена: {response.status_code} - {response.text}")
