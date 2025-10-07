Bash

#!/bin/bash

# --- ЭКСПЕРИМЕНТАЛЬНЫЙ СКРИПТ ДЛЯ UBUNTU 24.04 ---
# Этот скрипт попытается установить Python 2 и другие зависимости,
# которые отсутствуют в Ubuntu 24.04, вручную.
# Используйте на свой страх и риск.

# Выход при любой ошибке
set -e

# --- ВАШИ ДАННЫЕ УЖЕ ВСТАВЛЕНЫ ---
GITHUB_USER="vl010101"
FILES_REPO="ace-proxy"
BRANCH_PATH="refs/heads/master"
# -----------------------------------

echo "Starting EXPERIMENTAL installation for Ubuntu 24.04..."

## 1. Обновление системы и установка базовых пакетов
sudo apt-get update
sudo apt-get upgrade -y
# Устанавливаем основные пакеты. Обратите внимание: все пакеты python2 УДАЛЕНЫ отсюда.
# PHP заменен на версию 8.3, доступную для Ubuntu 24.04.
sudo apt-get install -y net-tools git mc htop ffmpeg supervisor tor apache2 mariadb-server php8.3 libapache2-mod-php8.3 php8.3-mysql php8.3-cli wget curl

echo "Basic packages installed."

## 2. Установка Python 2.7 вручную из репозиториев Ubuntu 20.04
echo "Installing Python 2.7 manually..."
cd /tmp
# Скачиваем необходимые пакеты .deb для Python 2.7
wget http://archive.ubuntu.com/ubuntu/pool/main/m/mime-support/mime-support_3.64ubuntu1_all.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/p/python2.7/libpython2.7-minimal_2.7.18-1~20.04.3_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/p/python2.7/python2.7-minimal_2.7.18-1~20.04.3_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/p/python2.7/libpython2.7-stdlib_2.7.18-1~20.04.3_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/main/p/python2.7/python2.7_2.7.18-1~20.04.3_amd64.deb

# Устанавливаем их, игнорируя некоторые зависимости, которые исправим позже
sudo dpkg -i ./*.deb
# Исправляем возможные проблемы с зависимостями
sudo apt-get -f install -y
echo "Python 2.7 should be installed."

## 3. Установка pip для Python 2.7
echo "Installing pip for Python 2.7..."
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
sudo python2.7 get-pip.py
echo "pip for Python 2.7 installed."

## 4. Установка Python-зависимостей через pip
# Вместо apt, используем pip для установки пакетов, которых нет в системе
echo "Installing python dependencies via pip..."
sudo python2.7 -m pip install m2crypto apsw resources

## 5. Создание папок и настройка прав
sudo mkdir -p /mnt/films /opt/acestream /opt/BackUP-HTTPAceProxy /opt/acelist /opt/lists
sudo chmod -R 777 /mnt/films

## 6. Установка Ace Stream Engine и Acesearch из вашего репозитория
# Используем ВАШУ правильную ссылку
echo "Downloading Ace Stream Engine..."
wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/$BRANCH_PATH/acestream.tar.gz" -O /tmp/acestream.tar.gz
sudo tar -zxf /tmp/acestream.tar.gz -C /opt/acestream

echo "Downloading Acesearch..."
wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/$BRANCH_PATH/acesearch.tar.gz" -O /tmp/acesearch.tar.gz
sudo tar -zxf /tmp/acesearch.tar.gz -C /opt/acelist
# Запускаем генерацию плейлиста
sudo php /opt/acelist/as.php /opt/lists/as

## Добавление задачи в Cron для обновления плейлиста
(sudo crontab -l 2>/dev/null; echo "0 */8 * * * php /opt/acelist/as.php /opt/lists/as") | sudo crontab -

## Установка HTTPAceProxy (в вашем репозитории нет форка, поэтому клонируем оригинал)
cd /opt
sudo git clone "https://github.com/pepsik-kiev/HTTPAceProxy.git"
cd /opt/HTTPAceProxy

# ... (остальная часть вашего скрипта для настройки HTTPAceProxy, Supervisor и т.д.) ...

echo "Installation complete!"
exit
