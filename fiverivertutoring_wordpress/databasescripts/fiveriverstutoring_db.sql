-- Five Rivers Tutoring Database Initialization
-- WordPress core tables and custom configurations

-- Create database for WordPress
CREATE DATABASE IF NOT EXISTS fiveriverstutoring_db;

-- Use the database
USE fiveriverstutoring_db;

-- Create user if not exists
CREATE USER IF NOT EXISTS 'fiverriversadmin'@'%' IDENTIFIED BY 'Password@123';

-- Grant privileges
GRANT ALL PRIVILEGES ON fiveriverstutoring_db.* TO 'fiverriversadmin'@'%';

-- Flush privileges
FLUSH PRIVILEGES;

-- Show all users
SELECT user, host FROM mysql.user;

-- Check current user
SELECT CURRENT_USER();

-- Check user privileges
SHOW GRANTS FOR 'fiverriversadmin'@'%'; 