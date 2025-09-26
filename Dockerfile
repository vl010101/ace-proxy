# 1. Используем современную LTS-версию Ubuntu
FROM ubuntu:22.04

# Устанавливаем переменные для неинтерактивной установки
ENV TZ=Europe/Moscow \
    DEBIAN_FRONTEND=noninteractive

# Открываем порты
EXPOSE 8081 62062 6878 8621

# Создаем том для медиафайлов
VOLUME /mnt/films

# 2. Объединяем установку пакетов в один слой
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Утилиты
    wget \
    unzip \
    ca-certificates \
    tzdata \
    # Зависимости Python 3
    python3 \
    python3-psutil \
    python3-gevent \
    python3-setuptools \
    python3-m2crypto \
    python3-apsw \
    python3-lxml && \
    # Создаем директорию
    mkdir -p /mnt/films && \
    # 3. Скачиваем архивы с чистыми именами с помощью `wget -O`
    echo "Downloading AceStream..." && \
    wget -O /tmp/acestream.zip https://github.com/vl010101/httpaceproxy/blob/master/add/acestream_3.1.49_ubuntu_18.04_x86_64.zip?raw=true && \
    echo "Downloading HTTPAceProxy..." && \
    wget -O /tmp/aceproxy.zip https://github.com/pepsik-kiev/HTTPAceProxy/archive/master.zip && \
    # Распаковываем
    unzip /tmp/acestream.zip -d /opt/ && \
    unzip /tmp/aceproxy.zip -d /opt/ && \
    # Очищаем кэш и временные файлы
    rm -rf /tmp/acestream.zip /tmp/aceproxy.zip && \
    apt-get purge -y --auto-remove wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Копируем локальные файлы конфигурации
# Убедитесь, что рядом с Dockerfile есть папка `add` с этими файлами
ADD add/torrenttv.py /opt/HTTPAceProxy-master/plugins/config/torrenttv.py
ADD add/aceconfig.py /opt/HTTPAceProxy-master/aceconfig.py
ADD add/start.sh /opt/start.sh

# 4. Устанавливаем права на исполнение
RUN chmod +x /opt/acestream.engine/start-engine && \
    chmod +x /opt/acestream.engine/acestreamengine && \
    chmod +x /opt/HTTPAceProxy-master/acehttp.py && \
    chmod +x /opt/start.sh

# Команда для запуска контейнера
CMD ["/opt/start.sh"]
