FROM php:7.4-cli

WORKDIR /app

# Extensions used by neuer.php: curl_* and mb_*
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libonig-dev \
    && docker-php-ext-install -j"$(nproc)" curl mbstring \
    && rm -rf /var/lib/apt/lists/*

# Copy the whole project (neuer.php + any other files/folders it needs).
COPY . /app

# Runtime command:
# - reads the Telegram token from the Fly secret BOT_TOKEN
# - generates info.php because the PHP source expects it
# - keeps file-based bot data on the mounted persistent volume
# - starts PHP's built-in HTTP server on Fly's internal port
CMD ["sh", "-c", "set -eu; : \"${BOT_TOKEN:?BOT_TOKEN secret is required}\"; mkdir -p /app/persist/data /app/persist/SudoOrders /app/persist/statistics /app/persist/root; if [ ! -f /app/persist/.initialized ]; then cp -a /app/data/. /app/persist/data/ 2>/dev/null || true; cp -a /app/SudoOrders/. /app/persist/SudoOrders/ 2>/dev/null || true; cp -a /app/statistics/. /app/persist/statistics/ 2>/dev/null || true; for f in game.json gamess.txt game.txt groupslink.txt msgs.json; do [ -e \"/app/$f\" ] && cp -a \"/app/$f\" \"/app/persist/root/$f\" || true; done; touch /app/persist/.initialized; fi; rm -rf /app/data /app/SudoOrders /app/statistics; ln -s /app/persist/data /app/data; ln -s /app/persist/SudoOrders /app/SudoOrders; ln -s /app/persist/statistics /app/statistics; for f in game.json gamess.txt game.txt groupslink.txt msgs.json; do rm -f \"/app/$f\"; touch \"/app/persist/root/$f\"; ln -s \"/app/persist/root/$f\" \"/app/$f\"; done; printf '%s\\n' \"$BOT_TOKEN\" > /app/info.php; sed -i 's|^\\$API_KEY = \".*\";|\\$API_KEY = getenv(\"BOT_TOKEN\");|' /app/neuer.php; exec php -S 0.0.0.0:${PORT:-8080} -t /app"]
