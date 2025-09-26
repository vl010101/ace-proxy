# Use Ubuntu 20.04, which has the required legacy libraries
FROM ubuntu:20.04

# Set environment variables for non-interactive installation
ENV TZ=Europe/Moscow \
    DEBIAN_FRONTEND=noninteractive

# Expose the necessary ports
EXPOSE 8081 62062 6878 8621

# Create a volume for media files
VOLUME /mnt/films

# Update, install dependencies, and clean up in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # System utilities
    wget \
    unzip \
    ca-certificates \
    # The required legacy Python 2.7 library
    libpython2.7 \
    # Dependencies for the Python 3 proxy
    python3 \
    python3-psutil \
    python3-gevent \
    python3-setuptools \
    python3-m2crypto \
    python3-apsw \
    python3-lxml && \
    # Download and extract AceStream
    echo "Downloading AceStream..." && \
    wget -O /tmp/acestream.zip https://github.com/vl010101/httpaceproxy/blob/master/add/acestream_3.1.49_ubuntu_18.04_x86_64.zip?raw=true && \
    unzip /tmp/acestream.zip -d /opt/ && \
    # Download and extract HTTPAceProxy
    echo "Downloading HTTPAceProxy..." && \
    wget -O /tmp/aceproxy.zip https://github.com/pepsik-kiev/HTTPAceProxy/archive/master.zip && \
    unzip /tmp/aceproxy.zip -d /opt/ && \
    # Clean up temporary files and apt cache
    rm -rf /tmp/*.zip && \
    apt-get purge -y --auto-remove wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Add local configuration files
ADD add/torrenttv.py /opt/HTTPAceProxy-master/plugins/config/torrenttv.py
ADD add/aceconfig.py /opt/HTTPAceProxy-master/aceconfig.py
ADD add/start.sh /opt/start.sh

# Set executable permissions
RUN chmod +x /opt/acestream.engine/start-engine && \
    chmod +x /opt/acestream.engine/acestreamengine && \
    chmod +x /opt/HTTPAceProxy-master/acehttp.py && \
    chmod +x /opt/start.sh

# Set the command to run on container start
CMD ["/opt/start.sh"]
