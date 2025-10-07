#!/bin/bash

GITHUB_USER="vl010101"
# Имя репозитория с файлами зависимостей.
FILES_REPO="ace-proxy"
# --- КОНЕЦ НАСТРОЕК ---

echo "Starting installation from your repository: $GITHUB_USER"

## Добавление репозитория PHP
cd /etc/apt/sources.list.d
echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu $(lsb_release -cs) main" | sudo tee php.list > /dev/null
sudo apt-key adv --recv-keys --keyserver hkps://keyserver.ubuntu.com:443 4F4EA0AAE5267A6C
cd

## Пауза, чтобы система успела обработать новый репозиторий
sleep 5

## Обновление системы
sudo apt update && sudo apt full-upgrade -y

## Установка необходимых пакетов
sudo apt install -y net-tools git python2.7 libpython2.7 python-apsw python-setuptools mc htop ffmpeg libzbar-dev libzbar0 libffi-dev supervisor tor tor-geoipdb torsocks vlc apache2 mariadb-server php libapache2-mod-php php-mysql php-cgi php-gd php-zip php-xml php-xmlrpc php-curl php-json php-mbstring php-cli python3-pip
sudo ufw allow in 80/tcp
sudo a2enmod rewrite && sudo sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/apache2.conf && sudo systemctl restart apache2
sudo -H pip3 install cffi 'Cython==0.28' gevent psutil
sudo sh -c 'echo_supervisord_conf > /etc/supervisor/supervisord.conf'

## Создание нужных папок и прав
sudo mkdir -p /mnt/films /opt/acestream /opt/BackUP-HTTPAceProxy /opt/acelist /opt/lists /etc/systemd/system/tor.service.d
sudo chmod -R 777 /mnt/films

## Установка python-m2crypto из вашего репозитория
cd /tmp
wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/main/python-m2crypto_0.27.0-5_amd64.deb"
sudo dpkg -i python-m2crypto_0.27.0-5_amd64.deb
sudo apt install -f -y

## Установка pip для Python 2.7
wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/main/get-pip.py"
sudo python2.7 get-pip.py
sudo python2.7 -m pip install resources

## Установка Ace Stream Engine и Acesearch из вашего репозитория
wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/main/acestream_3.1.49_ubuntu_18.04_x86_64.tar.gz"
sudo tar -zxf acestream_3.1.49_ubuntu_18.04_x86_64.tar.gz -C /opt/acestream

wget "https://raw.githubusercontent.com/$GITHUB_USER/$FILES_REPO/main/acesearch.tar.gz"
sudo tar -zxf acesearch.tar.gz -C /opt/acelist
sudo php /opt/acelist/as.php /opt/lists/as

## Добавление задачи в Cron для обновления плейлиста
(sudo crontab -l 2>/dev/null; echo "0 */8 * * * php /opt/acelist/as.php /opt/lists/as") | sudo crontab -

## Установка HTTPAceProxy из вашего форка и настройка
cd /opt
# ВАЖНО: Клонируем из ВАШЕГО форка
sudo git clone "https://github.com/$GITHUB_USER/HTTPAceProxy.git"
cd /opt/HTTPAceProxy

# Применяем ваши настройки
sudo sed -i -e 's/acespawn = False/acespawn = True/' \
-e "s|acecmd = '/opt/acestream/start-engine --client-console --live-buffer 25 --vod-buffer 10'|acecmd = '/opt/acestream/start-engine --client-console --bind-all --service-remote-access --access-token ReplaceMe --service-access-token user --stats-report-peers --live-buffer 25 --vod-buffer 10 --max-connections 500 --vod-drop-max-age 120 --max-peers 50 --max-upload-slots 50 --download-limit 0 --stats-report-interval 2 --slots-manager-use-cpu-limit 1 --core-dlr-periodic-check-interval 5 --check-live-pos-interval 5 --refill-buffer-interval 1 --core-skip-have-before-playback-pos 1 --webrtc-allow-outgoing-connections 1 --allow-user-config --upload-limit 0 --cache-dir /tmp/.ACEStream --state-dir /tmp/.ACEStream --log-file /var/log/acestream.log --log-debug 0'|" \
-e 's/httpport = 8000/httpport = 8081/' \
-e 's/use_chunked = True/use_chunked = False/' \
-e 's/loglevel = logging.INFO/loglevel = logging.DEBUG/' aceconfig.py

sudo sed -i -e "s|url = ''|url = 'file:///opt/lists/as.m3u'|" \
-e 's/updateevery = 0/updateevery = 60/' plugins/config/torrenttv.py

# ... (остальная часть вашего скрипта остается без изменений) ...

## Настраиваем конфиг Supervisor.
cd /etc/supervisor
sudo sed -i -e 's|file=/tmp/supervisor.sock|file=/var/run/supervisor.sock|' -e 's/;chmod=0700/chmod=0766/' -e 's/\;\[inet_http_server]/[inet_http_server]/' -e 's/;port=127.0.0.1:9001/port=*:9001/' -e 's/;user=chrism/user=root/' -e 's|logfile=/tmp/supervisord.log|logfile=/var/log/supervisor/supervisord.log|' -e 's|pidfile=/tmp/supervisord.pid|pidfile=/var/run/supervisord.pid|' -e 's/nodaemon=false/nodaemon=true/' -e 's|serverurl=unix:///tmp/supervisor.sock|serverurl=unix:///var/run/supervisor.sock|' -e 's/\;\[include]/[include]/' supervisord.conf
sudo sh -c "echo 'files = /etc/supervisor/conf.d/*.conf' >> supervisord.conf"

## Создаём юнит-конфиг запуска HTTPAceProxy в Supervisor.
echo -e '[program:01-HTTPAceProxy]\ncommand=/usr/bin/python3 /opt/HTTPAceProxy/acehttp.py\nstdout_logfile=/var/log/aceproxy.log\nstdout_logfile_maxbytes=50MB\nstderr_logfile=/var/log/aceproxy.log\nstartsecs=20\nstopasgroup=true\nautostart=true\nautorestart=true' | sudo tee /etc/supervisor/conf.d/httpaceproxy.conf > /dev/null

# ... (Продолжение настройки Tor, cron и т.д. как в вашем оригинальном скрипте) ...

## Внесение изменений в конфигурационный файл torrc.
# (Эта часть остается без изменений)

## Перезапуск сервисов
sudo supervisorctl reread
sudo supervisorctl update
sudo systemctl restart supervisor

echo "Installation complete!"
exit
