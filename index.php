<?php
// EcoBazaar Database API Service
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database configuration
$host = $_ENV['DB_HOST'] ?? 'localhost';
$port = $_ENV['DB_PORT'] ?? '3306';
$dbname = $_ENV['MYSQL_DATABASE'] ?? 'ecobazaar_db';
$username = $_ENV['MYSQL_USER'] ?? 'ecobazaar_user';
$password = $_ENV['MYSQL_PASSWORD'] ?? 'ecobazaar_password';

// Get the request path
$request_uri = $_SERVER['REQUEST_URI'];
$path = parse_url($request_uri, PHP_URL_PATH);

// Route handling
switch ($path) {
    case '/health':
        handleHealthCheck();
        break;
    case '/db/info':
        handleDbInfo();
        break;
    case '/db/tables':
        handleDbTables();
        break;
    case '/':
        handleRoot();
        break;
    default:
        handleNotFound();
        break;
}

function handleHealthCheck() {
    global $host, $port, $dbname, $username, $password;
    
    try {
        $pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        // Test the connection
        $stmt = $pdo->query("SELECT 1");
        
        http_response_code(200);
        echo json_encode([
            'status' => 'healthy',
            'database' => 'connected',
            'timestamp' => date('c'),
            'service' => 'EcoBazaar Database API'
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'status' => 'unhealthy',
            'database' => 'disconnected',
            'error' => $e->getMessage(),
            'timestamp' => date('c')
        ]);
    }
}

function handleDbInfo() {
    global $host, $port, $dbname, $username, $password;
    
    try {
        $pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        $stmt = $pdo->query("SELECT VERSION() as version, DATABASE() as database_name");
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'database' => $result['database_name'],
            'version' => $result['version'],
            'status' => 'connected'
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'error' => 'Database connection failed',
            'message' => $e->getMessage()
        ]);
    }
}

function handleDbTables() {
    global $host, $port, $dbname, $username, $password;
    
    try {
        $pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        $stmt = $pdo->query("SHOW TABLES");
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        echo json_encode([
            'tables' => $tables,
            'count' => count($tables)
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'error' => 'Failed to fetch tables',
            'message' => $e->getMessage()
        ]);
    }
}

function handleRoot() {
    echo json_encode([
        'message' => 'EcoBazaar Database API Service',
        'version' => '1.0.0',
        'endpoints' => [
            'health' => '/health',
            'database' => 'MySQL 8.0'
        ]
    ]);
}

function handleNotFound() {
    http_response_code(404);
    echo json_encode([
        'error' => 'Not Found',
        'message' => 'The requested endpoint was not found'
    ]);
}
?>
