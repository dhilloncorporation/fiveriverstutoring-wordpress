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
    && rm -rf /var/lib/apt/lists/*

# Install MySQL client (try multiple package names for compatibility)
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    || apt-get install -y mariadb-client \
    || apt-get install -y mysql-client \
    || (echo "Installing MySQL client from official repository..." && \
        wget -O mysql-apt-config.deb https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb && \
        apt-get install -y ./mysql-apt-config.deb && \
        apt-get update && \
        apt-get install -y mysql-client && \
        rm mysql-apt-config.deb) \
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

# Copy custom configuration files
COPY fiverivertutoring_wordpress/config/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Set proper permissions for wp-content
RUN chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# Copy custom entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

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
ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"] 