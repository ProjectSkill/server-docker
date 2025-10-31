# Copyright (C) 2017-2023 Smart code 203358507

# Use a modern Node version (Render supports 18/20; 14 is EOL)
ARG NODE_VERSION=20
FROM node:${NODE_VERSION}

ARG VERSION=master
ARG BUILD=desktop

LABEL com.stremio.vendor="Smart Code Ltd."
LABEL version=${VERSION}
LABEL description="Stremio's streaming Server"

WORKDIR /stremio

# Install ffmpeg (Jellyfin build)
ARG JELLYFIN_VERSION=4.4.1-4
RUN sed -ie 's/deb\.debian/archive.debian/g' /etc/apt/sources.list \
    && apt -y update && apt -y install wget \
    && wget https://repo.jellyfin.org/archive/ffmpeg/debian/${JELLYFIN_VERSION}/jellyfin-ffmpeg_${JELLYFIN_VERSION}-buster_$(dpkg --print-architecture).deb -O jellyfin-ffmpeg.deb \
    && apt -y install ./jellyfin-ffmpeg.deb \
    && rm jellyfin-ffmpeg.deb

# Download server build
COPY download_server.sh download_server.sh
RUN ./download_server.sh

# Allow overriding server.js if present in repo
COPY . .

VOLUME ["/root/.stremio-server"]

# Expose Render’s dynamic port (not hardcoded 11470/12470)
EXPOSE $PORT

# Environment variables
ENV FFMPEG_BIN=/usr/bin/ffmpeg
ENV FFPROBE_BIN=
ENV APP_PATH=/app
ENV NO_CORS=
ENV CASTING_DISABLED=1

# Start the server binding to Render’s injected port
CMD ["node", "server.js", "--port", "$PORT", "--host", "0.0.0.0"]
