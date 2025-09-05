# Dockerfile for EcoBazaar Database API Service
FROM php:8.0-apache

# Set environment variables for MySQL
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=ecobazaar_db
ENV MYSQL_USER=ecobazaar_user
ENV MYSQL_PASSWORD=ecobazaar_password

# Install MySQL client and other dependencies
RUN apt-get update && \
    apt-get install -y \
    default-mysql-client \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite

# Copy PHP application
COPY index.php /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html/
RUN chmod 644 /var/www/html/index.php

# Expose port 80 (Apache)
EXPOSE 80

# Health check for the API
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Start Apache
CMD ["apache2-foreground"]
