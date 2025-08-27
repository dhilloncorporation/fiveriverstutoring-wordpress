## root
mysql -u root -p -h localhost


-- Five Rivers Tutoring Staging Database Initialization
-- WordPress core tables and custom configurations for staging environment

-- DROP  database fiveriverstutoring_staging_db

-- Create staging database for WordPress
CREATE DATABASE IF NOT EXISTS fiveriverstutoring_staging_db;

-- Use the staging database
USE fiveriverstutoring_staging_db;

-- Create user if not exists (won't error if user already exists)
CREATE USER IF NOT EXISTS 'fiveriversadmin'@'%' IDENTIFIED BY 'Password@123';
CREATE USER IF NOT EXISTS 'fiveriversadmin'@'host.docker.internal' IDENTIFIED BY 'Password@123';
CREATE USER IF NOT EXISTS 'fiveriversadmin'@'localhost' IDENTIFIED BY 'Password@123';
CREATE USER IF NOT EXISTS 'fiveriversadmin'@'127.0.0.1' IDENTIFIED BY 'Password@123';
CREATE USER IF NOT EXISTS 'fiveriversadmin'@'::1' IDENTIFIED BY 'Password@123';

-- Note: Users should already exist from production setup
-- This script only creates the database and grants database-level privileges

-- Grant full privileges to staging database for existing admin users
-- (Users must already exist with appropriate system privileges)
GRANT ALL PRIVILEGES ON fiveriverstutoring_staging_db.* TO 'fiveriversadmin'@'%';
GRANT ALL PRIVILEGES ON fiveriverstutoring_staging_db.* TO 'fiveriversadmin'@'host.docker.internal';
GRANT ALL PRIVILEGES ON fiveriverstutoring_staging_db.* TO 'fiveriversadmin'@'localhost';
GRANT ALL PRIVILEGES ON fiveriverstutoring_staging_db.* TO 'fiveriversadmin'@'127.0.0.1';
GRANT ALL PRIVILEGES ON fiveriverstutoring_staging_db.* TO 'fiveriversadmin'@'::1';

-- Grant system privileges for users that need them (127.0.0.1 and ::1)
GRANT RELOAD, SHUTDOWN, PROCESS, SUPER ON *.* TO 'fiveriversadmin'@'127.0.0.1';
GRANT RELOAD, SHUTDOWN, PROCESS, SUPER ON *.* TO 'fiveriversadmin'@'::1';

-- Ensure all users don't require SSL connections (fixes Docker TLS/SSL issues)
ALTER USER 'fiveriversadmin'@'%' REQUIRE NONE;
ALTER USER 'fiveriversadmin'@'host.docker.internal' REQUIRE NONE;
ALTER USER 'fiveriversadmin'@'localhost' REQUIRE NONE;
ALTER USER 'fiveriversadmin'@'127.0.0.1' REQUIRE NONE;
ALTER USER 'fiveriversadmin'@'::1' REQUIRE NONE;

SELECT user, host FROM mysql.user WHERE user = 'fiveriversadmin';

-- Flush privileges
FLUSH PRIVILEGES;

-- Verify staging database creation
SHOW DATABASES LIKE 'fiveriverstutoring_staging_db';

-- Switch to staging database
USE fiveriverstutoring_staging_db;
SELECT DATABASE();

-- Show staging database tables (will be empty initially)
SHOW TABLES;