const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.MYSQL_USER || 'ecobazaar_user',
  password: process.env.MYSQL_PASSWORD || 'ecobazaar_password',
  database: process.env.MYSQL_DATABASE || 'ecobazaar_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

// Create connection pool
const pool = mysql.createPool(dbConfig);

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    await connection.ping();
    connection.release();
    
    res.status(200).json({
      status: 'healthy',
      database: 'connected',
      timestamp: new Date().toISOString(),
      service: 'EcoBazaar Database API'
    });
  } catch (error) {
    res.status(500).json({
      status: 'unhealthy',
      database: 'disconnected',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'EcoBazaar Database API Service',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      database: 'MySQL 8.0'
    }
  });
});

// Database info endpoint
app.get('/db/info', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [rows] = await connection.execute('SELECT VERSION() as version, DATABASE() as database_name');
    connection.release();
    
    res.json({
      database: rows[0].database_name,
      version: rows[0].version,
      status: 'connected'
    });
  } catch (error) {
    res.status(500).json({
      error: 'Database connection failed',
      message: error.message
    });
  }
});

// Test database tables endpoint
app.get('/db/tables', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [rows] = await connection.execute('SHOW TABLES');
    connection.release();
    
    res.json({
      tables: rows.map(row => Object.values(row)[0]),
      count: rows.length
    });
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch tables',
      message: error.message
    });
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`EcoBazaar Database API running on port ${PORT}`);
  console.log(`Health check available at: http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  pool.end();
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  pool.end();
  process.exit(0);
});
