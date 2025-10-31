# Copyright (C) 2017-2023 Smart code 203358507

# Use a modern Node version supported by Render
FROM node:20-bullseye

ARG VERSION=master
ARG BUILD=desktop

LABEL com.stremio.vendor="Smart Code Ltd."
LABEL version=${VERSION}
LABEL description="Stremio's streaming Server"

# Set working directory
WORKDIR /app

# Install ffmpeg from Debian repos (stable, no archived mirrors)
RUN apt-get update \
    && apt-get install -y ffmpeg wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download server build
COPY download_server.sh .
RUN chmod +x download_server.sh && ./download_server.sh

# Allow overriding server.js if present in repo
COPY . .

# Persist user data
VOLUME ["/root/.stremio-server"]

# Expose Render’s dynamic port
EXPOSE $PORT

# Environment variables
ENV FFMPEG_BIN=/usr/bin/ffmpeg
ENV FFPROBE_BIN=/usr/bin/ffprobe
ENV APP_PATH=/app
ENV NO_CORS=
ENV CASTING_DISABLED=1

# Start the server binding to Render’s injected port
CMD ["node", "server.js", "--port", "$PORT", "--host", "0.0.0.0"]
