#!/bin/sh

# Change directory to the application root
cd /var/www/html || exit

# Check if Laravel is already installed by checking the presence of composer.json
if [ ! -f /var/www/html/composer.json ]; then
  echo "Installing Laravel..."
  composer create-project --prefer-dist laravel/laravel:11.* /var/www/html
else
  echo "Laravel is already installed."
fi

# Install Composer dependencies if the autoload file is missing
if [ ! -f "vendor/autoload.php" ]; then
    composer install --no-progress --no-interaction
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating env file for env"
    cp .env.example .env
else
    echo "env file exists."
fi

#role=${CONTAINER_ROLE:-app}

#if [ "$role" = "app" ]; then
#    php artisan migrate
#    php artisan key:generate
#    php artisan cache:clear
#    php artisan config:clear
#    php artisan route:clear
#    php artisan serve --port=$PORT --host=0.0.0.0 --env=.env
#    exec docker-php-entrypoint "$@"
#elif [ "$role" = "queue" ]; then
#    echo "Running the queue ... "
#    php /var/www/artisan queue:work --verbose --tries=3 --timeout=180
#fi

# Start PHP-FPM to keep the container running
echo "Starting PHP-FPM..."
exec php-fpm
