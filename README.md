# EcoBazaarDb - MySQL Database Service

This is a separate MySQL database service for the EcoBazaarX application.

## 📁 Project Structure

```
EcobazaarDb/
├── Dockerfile              # MySQL container configuration
├── docker-compose.yml      # Local development setup
├── init.sql               # Database initialization script
├── render.yaml            # Render deployment configuration
├── deploy.bat             # Windows deployment script
├── deploy.ps1             # PowerShell deployment script
└── README.md              # This file
```

## 🚀 Local Development

### Prerequisites
- Docker
- Docker Compose

### Start MySQL Database
```bash
# Start the database
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs mysql
```

### Stop MySQL Database
```bash
docker-compose down
```

## 🌐 Deployment to Render

### Step 1: Test Locally
```bash
# Run deployment script
.\deploy.ps1
```

### Step 2: Deploy to Render
1. Push to GitHub:
   ```bash
   git add .
   git commit -m "Deploy MySQL Database"
   git push origin main
   ```

2. Deploy on Render:
   - Go to [render.com](https://render.com)
   - Create new Web Service
   - Connect your GitHub repository
   - Render will detect `render.yaml` and deploy MySQL

## 🔧 Configuration

### Environment Variables
- `MYSQL_ROOT_PASSWORD`: rootpassword
- `MYSQL_DATABASE`: ecobazaar_db
- `MYSQL_USER`: ecobazaar_user
- `MYSQL_PASSWORD`: ecobazaar_password

### Ports
- **Local**: 3306
- **Render**: 3306

### Health Check
- **Path**: /health
- **Interval**: 30s

## 📊 Database Schema

The database includes the following tables:
- `users` - User accounts
- `products` - Product catalog
- `stores` - Store information
- `wishlists` - User wishlists
- `wishlist_items` - Wishlist items
- `carts` - Shopping carts
- `eco_challenges` - Eco challenges
- `payment_transactions` - Payment records
- `user_orders` - User orders
- `user_settings` - User preferences

## 🔗 Connection Details

### Local Development
```yaml
Host: localhost
Port: 3306
Database: ecobazaar_db
Username: ecobazaar_user
Password: ecobazaar_password
```

### Render Production
```yaml
Host: ecobazaar-mysql-db.onrender.com
Port: 3306
Database: ecobazaar_db
Username: ecobazaar_user
Password: ecobazaar_password
```

## 🛠️ Troubleshooting

### Common Issues

1. **Port already in use:**
   ```bash
   # Check what's using port 3306
   netstat -ano | findstr :3306
   ```

2. **Container won't start:**
   ```bash
   # Check logs
   docker-compose logs mysql
   ```

3. **Connection refused:**
   ```bash
   # Check if container is running
   docker-compose ps
   ```

## 📝 Next Steps

1. Deploy this MySQL service to Render
2. Note the service URL
3. Update backend configuration with MySQL URL
4. Deploy the Spring Boot backend
5. Run data migration

## 🔒 Security Notes

- Change default passwords in production
- Use environment variables for sensitive data
- Enable SSL for database connections
- Configure proper firewall rules
