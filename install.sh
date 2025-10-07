#!/bin/bash

# --- ФИНАЛЬНЫЙ ЭКСПЕРИМЕНТАЛЬНЫЙ СКРИПТ ДЛЯ UBUNTU 24.04 ---
# Метод: Временное добавление репозитория Ubuntu 20.04 (Focal) для установки Python 2.

# Выход при любой ошибке
set -e

# --- ВАШИ ДАННЫЕ УЖЕ ВСТАВЛЕНЫ ---
GITHUB_USER="vl010101"
FILES_REPO="ace-proxy"
BRANCH_PATH="refs/heads/master"
# -----------------------------------

echo "Starting FINAL ATTEMPT installation for Ubuntu 24.04..."

## 1. Обновление и установка базовых пакетов
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y net-tools git mc htop ffmpeg supervisor tor apache2 mariadb-server php8.3 libapache2-mod-php8.3 php8.3-mysql php8.3-cli wget curl

echo "Basic packages installed."

## 2. Установка Python 2.7 через временный репозиторий Ubuntu 20.04
echo "Adding Ubuntu 20.04 repository to install Python 2.7..."

# Добавляем репозиторий Ubuntu 20.04 (Focal)
echo "deb http://archive.ubuntu.com/ubuntu/ focal main universe" | sudo tee /etc/apt/sources.list.d/focal.list

# Создаем файл настроек (pinning), чтобы система устанавливала ТОЛЬКО python2 из focal
# и не трогала другие пакеты.
cat <<EOF | sudo tee /etc/apt/preferences.d/focal-pin
Package: *
Pin: release n=noble
Pin-Priority: 900

Package: python2.7* libpython2.7*
Pin: release n=focal
Pin-Priority: 901
EOF

# Обновляем список пакетов с учетом нового репозитория
sudo apt-get update

# Устанавливаем Python 2.7. APT теперь найдет его в репозитории focal.
echo "Installing Python 2.7 and its libraries..."
sudo apt-get install -y python2.7 libpython2.7

# Удаляем временные файлы, чтобы система оставалась чистой
echo "Cleaning up temporary repository files..."
sudo rm /etc/apt/sources.list.d/focal.list
sudo rm /etc/apt/preferences.d/focal-pin
sudo apt-get update

echo "Python 2.7 should be installed successfully."

## 3. Установка pip для Python 2.7
echo "Installing pip for Python 2.7..."
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py
sudo python2.7 /tmp/get-pip.py
echo "pip for Python 2.7 installed."

## 4. Установка Python-зависимостей через pip
echo "Installing python dependencies via pip..."
sudo python2.7 -m pip install m2crypto apsw resources

# ... (остальная часть скрипта остается без изменений) ...

## 5. Создание папок и настройка прав
sudo mkdir -p /mnt/films /opt/acestream /opt/BackUP-HTTPAceProxy /opt/acelist /opt/lists
sudo chmod -R 777 /mnt/films

## 6. Установка Ace Stream Engine и Acesearch
echo "Downloading Ace Stream Engine..."
wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/$BRANCH_PATH/acestream.tar.gz" -O /tmp/acestream.tar.gz
sudo tar -zxf /tmp/acestream.tar.gz -C /opt/acestream

echo "Downloading Acesearch..."
wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/$BRANCH_PATH/acesearch.tar.gz" -O /tmp/acesearch.tar.gz
sudo tar -zxf /tmp/acesearch.tar.gz -C /opt/acelist
sudo php /opt/acelist/as.php /opt/lists/as

echo "Installation script finished. Check for errors above."
exit 0
