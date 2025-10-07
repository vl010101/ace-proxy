import requests
from bs4 import BeautifulSoup

# URL сайта acestreamsearch.net
url = 'https://acestreamsearch.net'

# Отправка запроса на сайт
response = requests.get(url)

# Проверка статуса ответа
if response.status_code == 200:
    # Создание объекта BeautifulSoup
    soup = BeautifulSoup(response.content, 'html.parser')
    
    # Сохранение HTML страницы в файл для анализа
    with open('acestreamsearch.html', 'w', encoding='utf-8') as file:
        file.write(soup.prettify())
    
    print("HTML страницы сохранен в acestreamsearch.html. Проверьте файл, чтобы увидеть структуру HTML.")
else:
    print(f'Ошибка при загрузке страницы: {response.status_code}')
