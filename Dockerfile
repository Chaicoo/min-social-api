# Base image for PHP with Apache
FROM php:8.1-apache

# Enable Apache modules
RUN a2enmod rewrite headers

# Update package manager and install required dependencies
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    vim \
    git \
    unzip \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install gd pdo pdo_mysql zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy project files to the working directory
COPY . /var/www/html

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Copy the Laravel default Apache configuration
COPY ./docker/apache/laravel.conf /etc/apache2/sites-available/000-default.conf

# Set file permissions for Laravel
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
