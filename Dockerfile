# БАЗА: актуальная Ubuntu 22.04 (jammy)
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >/etc/timezone

# Порты (как в оригинале)
EXPOSE 8081 62062 6878 8621

# Тома
VOLUME /mnt/films

# Базовые пакеты и Python3-зависимости
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl unzip wget tzdata \
    python3 python3-pip python3-setuptools python3-psutil python3-gevent \
    python3-m2crypto python3-apsw python3-lxml \
 && rm -rf /var/lib/apt/lists/*

# Каталог для фильмов
RUN mkdir -p /mnt/films

# --- URLs (использую твой форк — при желании поправь на другой) ---
# AceStream ZIP лежит в твоём/чужом репо. ВАЖНО: брать raw-ссылку и явно задавать имя файла.
ARG ACE_URL="https://raw.githubusercontent.com/vl010101/httpaceproxy/master/add/acestream_3.1.49_ubuntu_18.04_x86_64.zip"
ARG PROXY_URL="https://github.com/pepsik-kiev/HTTPAceProxy/archive/master.zip"

# Установка AceStream Engine
RUN mkdir -p /opt && \
    curl -L "$ACE_URL" -o /tmp/acestream.zip && \
    unzip /tmp/acestream.zip -d /opt/ && \
    rm -f /tmp/acestream.zip

# Установка HTTPAceProxy
RUN curl -L "$PROXY_URL" -o /tmp/aceproxy.zip && \
    unzip /tmp/aceproxy.zip -d /opt/ && \
    rm -f /tmp/aceproxy.zip

# Локальные файлы из твоего репозитория (пути как у тебя)
# Если сборка идёт прямо “по URL”, замените ADD на загрузку raw-ссылок
ADD add/torrenttv.py /opt/HTTPAceProxy-master/plugins/config/torrenttv.py
ADD add/aceconfig.py  /opt/HTTPAceProxy-master/aceconfig.py
ADD add/start.sh      /opt/start.sh

# Права
RUN chmod +x /opt/acestream.engine/start-engine || true && \
    chmod +x /opt/acestream.engine/acestreamengine || true && \
    chmod +x /opt/HTTPAceProxy-master/acehttp.py && \
    chmod +x /opt/start.sh

# Старт
CMD ["/opt/start.sh"]
