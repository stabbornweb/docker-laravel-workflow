FROM nginx:latest

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    rm -rf /etc/nginx/conf.d/*

# install openssl
RUN apt-get update && \
    apt-get install -y openssl && \
    rm -rf /var/lib/apt/lists/*

# Ensure necessary directories for Supervisor, Nginx certificates
RUN mkdir -p /etc/nginx/certificates \
             /var/www/html/storage/logs

# generate certificates
# TODO: change it and make additional logic for production environment
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certificates/key.pem -out /etc/nginx/certificates/cert.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

# put nginx config
COPY docker/infrastructure/dev/nginx/config/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/infrastructure/dev/php/sepervisord/sepervisord.conf /etc/
