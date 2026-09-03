FROM php:7.4-cli

WORKDIR /app

COPY neuer.php .

RUN mkdir -p /app/data \
    && echo '{"userlist":[],"grouplist":[]}' > /app/data/user.json

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/app"]
