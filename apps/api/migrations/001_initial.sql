-- apps/api/migrations/001_initial.sql
-- Initial database schema for TMA Studio
-- Requirements: 10.5

-- Users table
-- Stores Telegram user information
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    telegram_id BIGINT UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255),
    username VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Index on telegram_id for fast lookups during authentication
CREATE INDEX IF NOT EXISTS idx_users_telegram_id ON users(telegram_id);

-- User preferences table
-- Stores user-specific preferences (theme, accessibility)
CREATE TABLE IF NOT EXISTS user_preferences (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    theme_mode VARCHAR(20) DEFAULT 'premium' CHECK (theme_mode IN ('native', 'premium', 'mixed')),
    reduced_motion BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Index on user_id for fast preference lookups
CREATE INDEX IF NOT EXISTS idx_user_preferences_user_id ON user_preferences(user_id);
