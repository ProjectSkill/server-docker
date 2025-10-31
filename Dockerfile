FROM node:20-bullseye

WORKDIR /app

# Install ffmpeg from Debian repos
RUN apt-get update \
    && apt-get install -y ffmpeg wget ca-certificates unzip \
    && rm -rf /var/lib/apt/lists/*

# Download latest stable server build directly
RUN wget -O stremio-server.zip https://dl.strem.io/server/v4.20.8/server.linux.zip \
    && unzip stremio-server.zip -d /app \
    && rm stremio-server.zip

# Copy any local overrides (optional)
COPY . .

VOLUME ["/root/.stremio-server"]

EXPOSE $PORT

ENV FFMPEG_BIN=/usr/bin/ffmpeg
ENV FFPROBE_BIN=/usr/bin/ffprobe
ENV APP_PATH=/app
ENV NO_CORS=
ENV CASTING_DISABLED=1

CMD ["node", "server.js", "--port", "$PORT", "--host", "0.0.0.0"]
