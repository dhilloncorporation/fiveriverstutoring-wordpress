-- Five Rivers Tutoring Staging Database Initialization
-- WordPress core tables and custom configurations for staging environment

-- Create staging database for WordPress
CREATE DATABASE IF NOT EXISTS fiveriverstutoring_staging_db;

-- Use the staging database

-- Create user if not exists (same user as production for consistency)
CREATE USER IF NOT EXISTS 'fiveriversadmin'@'%' IDENTIFIED BY 'Password@123';

SELECT user, host FROM mysql.user WHERE user = 'fiveriversadmin';

-- Grant privileges to staging database
GRANT ALL PRIVILEGES ON fiveriverstutoring_staging_db.* TO 'fiveriversadmin'@'%';


-- Flush privileges
FLUSH PRIVILEGES;

-- Show all users
SELECT user, host FROM mysql.user;

-- Check current us
-- Check user privileges for staging database
SHOW GRANTS FOR 'fiveriversadmin'@'%';

-- Verify staging database creation
SHOW DATABASES LIKE 'fiveriverstutoring_staging_db';
Connect fiveriverstutoring_staging_db -- from Root login

SELECT DATABASE();

-- Show staging database tables (will be empty initially)
SHOW TABLES;