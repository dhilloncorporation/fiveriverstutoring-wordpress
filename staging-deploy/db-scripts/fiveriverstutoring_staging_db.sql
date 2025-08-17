-- Five Rivers Tutoring Staging Database Initialization
-- WordPress core tables and custom configurations for staging environment

-- Create staging database for WordPress
CREATE DATABASE IF NOT EXISTS fiveriverstutoring_staging_db;

-- Use the staging database

-- Create users if not exists (same user as production for consistency)
CREATE USER IF NOT EXISTS 'fiveriversadmin'@'%' IDENTIFIED BY 'Password@123';
CREATE USER IF NOT EXISTS 'fiveriversadmin'@'host.docker.internal' IDENTIFIED BY 'Password@123';

SELECT user, host FROM mysql.user WHERE user = 'fiveriversadmin';

-- Grant privileges to staging database for both users
GRANT ALL PRIVILEGES ON fiveriverstutoring_staging_db.* TO 'fiveriversadmin'@'%';
GRANT ALL PRIVILEGES ON fiveriverstutoring_staging_db.* TO 'fiveriversadmin'@'host.docker.internal';


-- Flush privileges
FLUSH PRIVILEGES;

-- Show all users
SELECT user, host FROM mysql.user;

-- Check current us
-- Check user privileges for staging database
SHOW GRANTS FOR 'fiveriversadmin'@'%';
SHOW GRANTS FOR 'fiveriversadmin'@'host.docker.internal';

-- Verify staging database creation
SHOW DATABASES LIKE 'fiveriverstutoring_staging_db';

-- Switch to staging database
USE fiveriverstutoring_staging_db;
SELECT DATABASE();

-- Show staging database tables (will be empty initially)
SHOW TABLES;