#!/bin/bash
set -e

echo "Starting MySQL..."
# Start MySQL in background using the official entrypoint
/docker-entrypoint.sh mysqld &

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
while ! mysqladmin ping -h localhost -u root -prootpassword --silent; do
  echo "MySQL not ready yet, waiting..."
  sleep 2
done

echo "MySQL is ready!"

# Start Apache
echo "Starting Apache..."
httpd -D FOREGROUND
