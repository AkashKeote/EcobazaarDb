-- Initialize EcoBazaarX Database
-- This script runs when the MySQL container starts for the first time

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS ecobazaar_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Use the database
USE ecobazaar_db;

-- Create user if it doesn't exist
CREATE USER IF NOT EXISTS 'ecobazaar_user'@'%' IDENTIFIED BY 'ecobazaar_password';

-- Grant all privileges to the user
GRANT ALL PRIVILEGES ON ecobazaar_db.* TO 'ecobazaar_user'@'%';

-- Flush privileges
FLUSH PRIVILEGES;

-- Create initial admin user (optional - can be done through API)
-- INSERT INTO users (email, password, name, role, is_active, created_at, updated_at) 
-- VALUES ('admin@ecobazaar.com', '$2a$10$encrypted_password_here', 'Admin User', 'ADMIN', true, NOW(), NOW())
-- ON DUPLICATE KEY UPDATE email = email;
