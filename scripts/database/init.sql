-- init.sql - Safe initialization script
CREATE USER IF NOT EXISTS ecommerce_user WITH PASSWORD 'ecommerce_password';
CREATE DATABASE IF NOT EXISTS ecommerce_db OWNER ecommerce_user;
GRANT ALL PRIVILEGES ON DATABASE ecommerce_db TO ecommerce_user;

-- Connect to the database
\c ecommerce_db;

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Grant additional permissions
GRANT ALL ON SCHEMA public TO ecommerce_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO ecommerce_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO ecommerce_user;