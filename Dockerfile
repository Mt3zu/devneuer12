FROM php:7.4-cli

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libonig-dev \
        pkg-config \
    && docker-php-ext-install curl mbstring \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . /app

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/app"]
