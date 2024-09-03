FROM php:8.3.9-fpm

# Set ARGs for user and UID
ARG UID
ARG GID
ARG USER

# Set environment variables for UID and GID
ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}

# Create a group with the specified GID
RUN groupadd -g ${GID} ${USER}

# Create a user and group
RUN mkdir -p /home && \
    useradd -u ${UID} -g ${USER} -G www-data,root -m -d /home/${USER} ${USER}

# Install necessary packages
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    git \
    curl \
    zip \
    unzip \
    supervisor \
    default-mysql-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Copy the Laravel installation script and set permissions for the script
COPY docker/infrastructure/dev/scripts/laravel-create-project-script.sh /usr/local/bin/laravel-create-project-script.sh
COPY docker/infrastructure/dev/scripts/verify-php-extension-script.sh /usr/local/bin/verify-php-extension-script.sh
RUN chmod 755 /usr/local/bin/laravel-create-project-script.sh && \
    chmod 755 /usr/local/bin/verify-php-extension-script.sh

# Ensure necessary directories exist and set permissions
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache && \
    chown -R ${USER}:${USER} /var/www/html/storage /var/www/html/bootstrap/cache

# Copy application sources into the container.
COPY /backend /var/www/html

# Change ownership of the /var/www/html directory and adjust permissions for new user
RUN mkdir -p /home/${USER}/.composer && \
    chown -R ${USER}:${USER} /home/${USER} && \
    chown -R ${USER}:${USER} /var/www/html && \
    chmod -R 755 /var/www/html

# Copy PHP configuration files from local
COPY docker/infrastructure/dev/php/config/php.ini-development /usr/local/etc/php/php.ini
COPY docker/infrastructure/dev/php/config/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/infrastructure/dev/php/sepervisord/sepervisord.conf /etc/

# Set the working directory
WORKDIR "/var/www/html"

# Use the specified user for running the application
USER ${USER}

# Expose port/s Nginx will listen - Add more as required: (9003 - Xdebug)
EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/laravel-create-project-script.sh", "sepervisord", "--nodaemon", "--configuration", "/etc/sepervisord.conf"]
