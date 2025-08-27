# Five Rivers Tutoring - Custom WordPress Docker Image
# This image packages WordPress + wp-content for staging and production

FROM wordpress:latest

# Set metadata
LABEL maintainer="Five Rivers Tutoring"
LABEL description="Custom WordPress image for Five Rivers Tutoring website"
LABEL version="1.0"

# Install additional packages and PHP extensions
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    curl \
    gnupg \
    lsb-release \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install MySQL client (use default for now)
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Verify MySQL client installation
RUN mysql --version || echo "MySQL client installation verification failed"

# Install WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Install additional PHP extensions if needed
RUN docker-php-ext-install \
    mysqli \
    pdo_mysql

# Set working directory
WORKDIR /var/www/html

# Debug: Check what's in the container before copying
RUN ls -la /var/www/html/ && echo "=== Contents of /var/www/html/ ==="

# Ensure WordPress core files exist - use wget instead of wp core download
RUN if [ ! -f "wp-config-sample.php" ]; then \
        echo "WordPress core files missing, downloading with wget..." && \
        wget https://wordpress.org/latest.zip && \
        unzip latest.zip && \
        cp -r wordpress/* . && \
        rm -rf wordpress latest.zip; \
    else \
        echo "WordPress core files found"; \
    fi

# Copy custom wp-content directory (themes, plugins, etc.)
COPY fiverivertutoring_wordpress/wp-content ./wp-content/

# Copy composer files and install Google API Client
COPY fiverivertutoring_wordpress/composer.json ./
COPY fiverivertutoring_wordpress/composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader

# Copy custom configuration files
COPY fiverivertutoring_wordpress/config/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Set proper permissions for wp-content
RUN chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# Copy custom entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && chmod +x /usr/local/bin/entrypoint.sh

# Create directories for persistent data
RUN mkdir -p /var/www/html/wp-content/uploads \
    && mkdir -p /var/www/html/wp-content/cache \
    && chown -R www-data:www-data /var/www/html/wp-content/uploads \
    && chown -R www-data:www-data /var/www/html/wp-content/cache

# Debug: Check final contents
RUN ls -la /var/www/html/ && echo "=== Final contents of /var/www/html/ ==="

# Expose port
EXPOSE 80

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"] 