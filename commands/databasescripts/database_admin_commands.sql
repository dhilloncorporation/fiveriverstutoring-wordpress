-- Database Administrative Commands
-- Five Rivers Tutoring - Database Management Script
-- Use this file for root-level database administration tasks

-- =====================================================
-- 1. CONNECTING AS ROOT
-- =====================================================
-- Command line: mysql -h 192.168.50.158 -u root -p
-- Enter your root password when prompted

-- =====================================================
-- 2. SHOW ALL DATABASES
-- =====================================================
SHOW DATABASES;

-- Show databases with more details
SELECT 
    SCHEMA_NAME AS 'Database',
    DEFAULT_CHARACTER_SET_NAME AS 'Charset',
    DEFAULT_COLLATION_NAME AS 'Collation'
FROM information_schema.SCHEMATA
ORDER BY SCHEMA_NAME;

-- =====================================================
-- 3. CHECK TABLES IN SPECIFIC DATABASE
-- =====================================================

-- First, select the database to work with
USE fiveriverstutoring_staging_db;

-- Show all tables in the current database
SHOW TABLES;

-- Show tables with more details
SELECT 
    TABLE_NAME AS 'Table',
    TABLE_ROWS AS 'Rows',
    DATA_LENGTH AS 'Data Size (bytes)',
    INDEX_LENGTH AS 'Index Size (bytes)',
    (DATA_LENGTH + INDEX_LENGTH) AS 'Total Size (bytes)',
    TABLE_COLLATION AS 'Collation'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'fiveriverstutoring_staging_db'
ORDER BY TABLE_NAME;

-- Show table status (detailed information)
SHOW TABLE STATUS;

-- =====================================================
-- 4. ADDITIONAL USEFUL ADMIN COMMANDS
-- =====================================================

-- Check current user and host
SELECT USER(), CURRENT_USER();

-- Check current database
SELECT DATABASE();

-- Show all users and their hosts
SELECT User, Host FROM mysql.user;

-- Show user privileges
SHOW GRANTS FOR 'fiveriversadmin'@'%';

-- Show process list (active connections)
SHOW PROCESSLIST;

-- Show server status
SHOW STATUS LIKE 'Connections';
SHOW STATUS LIKE 'Threads_connected';
SHOW STATUS LIKE 'Uptime';

-- Show server variables
SHOW VARIABLES LIKE 'max_connections';
SHOW VARIABLES LIKE 'wait_timeout';
SHOW VARIABLES LIKE 'max_allowed_packet';

-- =====================================================
-- 5. DATABASE SIZE INFORMATION
-- =====================================================

-- Show database sizes
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables 
GROUP BY table_schema
ORDER BY SUM(data_length + index_length) DESC;

-- Show table sizes within specific database
SELECT 
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)',
    table_rows AS 'Rows'
FROM information_schema.tables 
WHERE table_schema = 'fiveriverstutoring_staging_db'
ORDER BY (data_length + index_length) DESC;

-- =====================================================
-- 6. TROUBLESHOOTING COMMANDS
-- =====================================================

-- Check for slow queries
SHOW VARIABLES LIKE 'slow_query_log';
SHOW VARIABLES LIKE 'long_query_time';

-- Check error log location
SHOW VARIABLES LIKE 'log_error';

-- Check binary log status
SHOW VARIABLES LIKE 'log_bin';
SHOW BINARY LOGS;

-- =====================================================
-- 7. SECURITY AND PERMISSIONS
-- =====================================================

-- Show all users with their authentication methods
SELECT 
    User, 
    Host, 
    plugin AS 'Authentication Method'
FROM mysql.user;

-- Check if any users have no password
SELECT User, Host 
FROM mysql.user 
WHERE authentication_string = '' OR authentication_string IS NULL;

-- Show global privileges
SHOW GRANTS FOR 'root'@'localhost';

-- =====================================================
-- 8. PERFORMANCE MONITORING
-- =====================================================

-- Show current connections by user
SELECT 
    User, 
    COUNT(*) AS 'Connections'
FROM information_schema.processlist 
GROUP BY User;

-- Show table statistics
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    UPDATE_TIME,
    CHECK_TIME
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'fiveriverstutoring_staging_db'
ORDER BY UPDATE_TIME DESC;

-- =====================================================
-- END OF ADMIN COMMANDS
-- =====================================================
-- Remember to use these commands responsibly and only on databases you own
-- Always backup before making structural changes 