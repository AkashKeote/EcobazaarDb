# Dockerfile for EcoBazaar Database API Service with MySQL
FROM php:8.0-apache

# Set environment variables for MySQL
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=ecobazaar_db
ENV MYSQL_USER=ecobazaar_user
ENV MYSQL_PASSWORD=ecobazaar_password

# Install MySQL server, client and other dependencies
RUN apt-get update && \
    apt-get install -y \
    default-mysql-server \
    default-mysql-client \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Initialize MySQL data directory
RUN mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

# Create MySQL directories and set permissions
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql

# Enable Apache modules
RUN a2enmod rewrite

# Copy PHP application
COPY index.php /var/www/html/

# Copy database initialization script
COPY init.sql /docker-entrypoint-initdb.d/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html/
RUN chmod 644 /var/www/html/index.php

# Expose port 80 (Apache)
EXPOSE 80

# Create startup script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "Starting MySQL..."\n\
# Start MySQL using mysqld directly\n\
mysqld --user=mysql --datadir=/var/lib/mysql --pid-file=/var/run/mysqld/mysqld.pid --socket=/var/run/mysqld/mysqld.sock --port=3306 &\n\
MYSQL_PID=$!\n\
\n\
# Wait for MySQL to be ready\n\
echo "Waiting for MySQL to be ready..."\n\
while ! mysqladmin ping -h localhost -u root --silent 2>/dev/null; do\n\
  echo "MySQL not ready yet, waiting..."\n\
  sleep 2\n\
done\n\
\n\
echo "MySQL is ready!"\n\
\n\
# Set root password and initialize database\n\
mysql -u root -e "ALTER USER '\''root'\''@'\''localhost'\'' IDENTIFIED BY '\''rootpassword'\'';"\n\
mysql -u root -prootpassword -e "CREATE DATABASE IF NOT EXISTS ecobazaar_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"\n\
mysql -u root -prootpassword -e "CREATE USER IF NOT EXISTS '\''ecobazaar_user'\''@'\''localhost'\'' IDENTIFIED BY '\''ecobazaar_password'\'';"\n\
mysql -u root -prootpassword -e "GRANT ALL PRIVILEGES ON ecobazaar_db.* TO '\''ecobazaar_user'\''@'\''localhost'\'';"\n\
mysql -u root -prootpassword -e "FLUSH PRIVILEGES;"\n\
\n\
# Start Apache in foreground\n\
echo "Starting Apache..."\n\
exec apache2-foreground' > /start.sh && chmod +x /start.sh

# Health check for the API
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Start both services
CMD ["/start.sh"]
