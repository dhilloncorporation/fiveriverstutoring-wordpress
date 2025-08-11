-- Five Rivers Tutoring Database Initialization
-- WordPress core tables and custom configurations

-- Create database for WordPress
CREATE DATABASE IF NOT EXISTS fiveriverstutoring_db;

-- Use the database
USE fiveriverstutoring_db;

-- Create user if not exists
CREATE USER IF NOT EXISTS 'fiveriversadmin'@'%' IDENTIFIED BY 'Password@123';

-- Grant privileges
GRANT ALL PRIVILEGES ON fiveriverstutoring_db.* TO 'fiveriversadmin'@'%';

-- Flush privileges
FLUSH PRIVILEGES;

-- Show all users
SELECT user, host FROM mysql.user;

-- Check current user
SELECT CURRENT_USER();

-- Check user privileges
SHOW GRANTS FOR 'fiveriversadmin'@'%'; 
SHOW GRANTS FOR 'fiverriversadmin'@'%';  -- To be deleted or replaced.. extra R

-- Docker Internal User
CREATE USER 'fiveriversadmin'@'host.docker.internal' IDENTIFIED BY 'Password@123';
SELECT user, host FROM mysql.user;

-- Grant access to develop database
GRANT ALL PRIVILEGES ON fiveriverstutoring_db.* TO 'fiveriversadmin'@'%';
GRANT ALL PRIVILEGES ON fiveriverstutoring_db.* TO 'fiveriversadmin'@'host.docker.internal';

-- Grant access to staging database
GRANT ALL PRIVILEGES ON fiveriverstutoring_staging_db.* TO 'fiveriversadmin'@'%';
GRANT ALL PRIVILEGES ON fiveriverstutoring_staging_db.* TO 'fiveriversadmin'@'host.docker.internal';

-- Grant PROCESS privilege for mysqldump
GRANT PROCESS ON *.* TO 'fiveriversadmin'@'%';
GRANT PROCESS ON *.* TO 'fiveriversadmin'@'host.docker.internal';

FLUSH PRIVILEGES;

SELECT user, host FROM mysql.user WHERE user = 'fiveriversadmin';