FROM php:7.4-cli

WORKDIR /app

RUN docker-php-ext-install curl mbstring

COPY . /app

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/app"]
