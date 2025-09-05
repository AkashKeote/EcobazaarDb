# Dockerfile for EcoBazaar Database API Service
FROM mysql:8.0

# Set environment variables for MySQL
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=ecobazaar_db
ENV MYSQL_USER=ecobazaar_user
ENV MYSQL_PASSWORD=ecobazaar_password

# Install Node.js and curl
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy initialization script
COPY init.sql /docker-entrypoint-initdb.d/

# Set working directory for API
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy API server
COPY server.js ./

# Expose API port (Render will use this)
EXPOSE 3000

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
# Start the API server\n\
echo "Starting API server..."\n\
exec node server.js' > /start.sh && chmod +x /start.sh

# Health check for the API
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start both services
CMD ["/start.sh"]
