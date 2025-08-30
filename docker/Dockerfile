# Five Rivers Tutoring - Custom WordPress Docker Image
# This image packages WordPress + wp-content for staging and production

FROM wordpress:latest

# Build arguments for environment-specific builds
ARG ENVIRONMENT=staging
ARG INCLUDE_DEBUG=true
ARG OPTIMIZE_FOR_PRODUCTION=false

# Set metadata
LABEL maintainer="Five Rivers Tutoring"
LABEL description="Custom WordPress image for Five Rivers Tutoring website"
LABEL version="1.0"

# Environment-specific package installation
RUN if [ "$ENVIRONMENT" = "production" ]; then \
        echo "Production build: Installing minimal packages..." && \
        apt-get update && apt-get install -y ca-certificates && \
        rm -rf /var/lib/apt/lists/* && apt-get clean; \
    else \
        echo "Staging build: Installing development packages..." && \
        apt-get update && apt-get install -y unzip wget curl gnupg lsb-release git ca-certificates && \
        rm -rf /var/lib/apt/lists/*; \
    fi

# Install Composer (staging only)
RUN if [ "$ENVIRONMENT" != "production" ]; then \
        echo "Installing Composer for development..." && \
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    else \
        echo "Skipping Composer for production..."; \
    fi

# Install MySQL client and WP-CLI (staging only)
RUN if [ "$ENVIRONMENT" != "production" ]; then \
        echo "Installing development tools for staging..." && \
        apt-get update && apt-get install -y default-mysql-client && \
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
        chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp && \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Skipping development tools for production..."; \
    fi

# Install additional PHP extensions if needed
RUN docker-php-ext-install \
    mysqli \
    pdo_mysql

# Set working directory
WORKDIR /var/www/html



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
COPY fiverivertutoring_wordpress/wp-content/plugins ./wp-content/plugins
COPY fiverivertutoring_wordpress/wp-content/themes ./wp-content/themes
RUN mkdir -p ./wp-content/mu-plugins
# Copy mu-plugins if they exist (optional directory)
COPY fiverivertutoring_wordpress/wp-content/mu-plugins ./wp-content/mu-plugins

# Copy uploads (will be mounted at runtime for production)
COPY fiverivertutoring_wordpress/wp-content/uploads ./wp-content/uploads

# Copy composer files and install dependencies
COPY fiverivertutoring_wordpress/composer.json ./
COPY fiverivertutoring_wordpress/composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --no-progress --optimize-autoloader

# Copy custom configuration files
COPY fiverivertutoring_wordpress/config/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Set proper permissions for wp-content
RUN chown -R www-data:www-data /var/www/html/wp-content \
    && chmod -R 755 /var/www/html/wp-content

# PHP optimizations for all environments
RUN echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.max_accelerated_files=4000" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "realpath_cache_size=4096K" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "realpath_cache_ttl=600" >> /usr/local/etc/php/conf.d/opcache.ini

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

# Display build information
RUN echo "=== Build Information ===" && \
    echo "Environment: $ENVIRONMENT" && \
    echo "Debug: $INCLUDE_DEBUG" && \
    echo "Production Optimized: $OPTIMIZE_FOR_PRODUCTION" && \
    echo "Build completed at: $(date)" && \
    echo "========================="

# Expose port
EXPOSE 80

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"] 