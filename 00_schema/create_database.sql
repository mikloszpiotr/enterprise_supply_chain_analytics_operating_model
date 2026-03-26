-- ============================================================
-- FILE: create_database.sql
-- PURPOSE:
-- Create a dedicated database/schema for the portfolio project.
-- NOTE:
-- CREATE DATABASE syntax varies by platform. This version is
-- PostgreSQL-style and can be adapted for other engines.
-- ============================================================

-- Optional database creation
-- CREATE DATABASE supply_chain_analytics;

-- Optional schema creation
CREATE SCHEMA IF NOT EXISTS supply_chain_analytics;

-- Set active schema for session (PostgreSQL)
SET search_path TO supply_chain_analytics;
