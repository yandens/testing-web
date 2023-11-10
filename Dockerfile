FROM php:8.2-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    zip \
    unzip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    libpq-dev

# Configure pqsql
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

# Install extension
RUN docker-php-ext-install pdo pdo_pgsql pgsql mbstring

# Install latest Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy existing application directory contents
COPY . .

# Set document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite headers

# Ensure PHP logs are captured by the container
ENV LOG_CHANNEL=stderr

# Give permission to append to logs
RUN chown -R www-data:www-data /var/www/html

# Run composer install
RUN composer install --no-interaction --no-scripts --no-progress --prefer-dist

# Expose port
EXPOSE 80

# Run apache
CMD ["apache2-foreground"]
