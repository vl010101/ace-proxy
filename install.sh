#!/bin/bash

# --- ВАШИ ДАННЫЕ УЖЕ ВСТАВЛЕНЫ ---
GITHUB_USER="v010101"
FILES_REPO="ace-proxy" # Имя вашего репозитория
# -----------------------------------

echo "Starting installation from your repository: $GITHUB_USER/$FILES_REPO"

## Добавление репозитория PHP
cd /etc/apt/sources.list.d
echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu $(lsb_release -cs) main" | sudo tee php.list > /dev/null
sudo apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com:443 4F4EA0AAE5267A6C
cd

sleep 5

## Обновление системы
sudo apt update && sudo apt full-upgrade -y

## Установка необходимых пакетов
sudo apt install -y net-tools git python2.7 libpython2.7 python-apsw python-setuptools mc htop ffmpeg supervisor tor apache2 mariadb-server php libapache2-mod-php php-mysql php-cli python3-pip

## Создание нужных папок и прав
sudo mkdir -p /mnt/films /opt/acestream /opt/BackUP-HTTPAceProxy /opt/acelist /opt/lists
sudo chmod -R 777 /mnt/films

## Установка pip для Python 2.7
wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/master/get-pip.py" -O /tmp/get-pip.py
sudo python2.7 /tmp/get-pip.py
sudo python2.7 -m pip install resources

## Установка Ace Stream Engine и Acesearch из вашего репозитория
echo "Downloading Ace Stream Engine..."
wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/master/acestream.tar.gz" -O /tmp/acestream.tar.gz
sudo tar -zxf /tmp/acestream.tar.gz -C /opt/acestream

echo "Downloading Acesearch..."
wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/master/acesearch.tar.gz" -O /tmp/acesearch.tar.gz
sudo tar -zxf /tmp/acesearch.tar.gz -C /opt/acelist
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
