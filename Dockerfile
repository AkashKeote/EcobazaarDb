# Dockerfile for EcoBazaar Database API Service
FROM mysql:8.0

# Set environment variables for MySQL
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=ecobazaar_db
ENV MYSQL_USER=ecobazaar_user
ENV MYSQL_PASSWORD=ecobazaar_password

# Install PHP, Apache, and curl (MySQL image uses microdnf)
RUN microdnf update -y && \
    microdnf install -y \
    httpd \
    php \
    php-mysqlnd \
    php-pdo \
    curl \
    && microdnf clean all

# Copy initialization script
COPY init.sql /docker-entrypoint-initdb.d/

# Configure Apache (httpd on RHEL/CentOS)
RUN echo 'ServerName localhost' >> /etc/httpd/conf/httpd.conf
RUN echo 'LoadModule rewrite_module modules/mod_rewrite.so' >> /etc/httpd/conf/httpd.conf

# Copy PHP application
COPY index.php /var/www/html/

# Set proper permissions
RUN chown -R apache:apache /var/www/html/
RUN chmod 644 /var/www/html/index.php

# Expose port 80 (Apache)
EXPOSE 80

# Create startup script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "Starting MySQL..."\n\
# Start MySQL in background using the official entrypoint\n\
/docker-entrypoint.sh mysqld &\n\
\n\
# Wait for MySQL to be ready\n\
echo "Waiting for MySQL to be ready..."\n\
while ! mysqladmin ping -h localhost -u root -prootpassword --silent; do\n\
  echo "MySQL not ready yet, waiting..."\n\
  sleep 2\n\
done\n\
\n\
echo "MySQL is ready!"\n\
\n\
# Start Apache\n\
echo "Starting Apache..."\n\
httpd -D FOREGROUND' > /start.sh && chmod +x /start.sh

# Health check for the API
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

# Start both services
CMD ["/start.sh"]
