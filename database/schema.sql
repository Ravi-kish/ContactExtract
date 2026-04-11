-- ============================================================
-- CDR Intelligence Platform - MySQL Schema
-- Run this in your local MySQL: mysql -u root -p < schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS cdr_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cdr_db;

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id            VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
  email         VARCHAR(255)  NOT NULL UNIQUE,
  password_hash VARCHAR(255)  NOT NULL,
  name          VARCHAR(200)  NOT NULL,
  role          VARCHAR(50)   NOT NULL DEFAULT 'analyst',
  is_active     TINYINT(1)    NOT NULL DEFAULT 1,
  created_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login    DATETIME      NULL
);

-- ============================================================
-- UPLOADS
-- ============================================================
CREATE TABLE IF NOT EXISTS uploads (
  id           VARCHAR(36)   NOT NULL DEFAULT (UUID()) PRIMARY KEY,
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME      NULL,
  file_count   INT           NOT NULL DEFAULT 0,
  record_count BIGINT        NOT NULL DEFAULT 0,
  error_count  INT           NOT NULL DEFAULT 0,
  status       VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
  uploader_id  VARCHAR(100)  NOT NULL,
  notes        TEXT          NULL,
  is_deleted   TINYINT(1)    NOT NULL DEFAULT 0,
  deleted_at   DATETIME      NULL,
  file_names   JSON          NULL
);

-- ============================================================
-- CDR RECORDS
-- ============================================================
CREATE TABLE IF NOT EXISTS cdr_records (
  id                  BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY,
  upload_id           VARCHAR(36)   NOT NULL,

  -- Phone numbers
  cdr_number          VARCHAR(30)   NULL,
  cdr_number_e164     VARCHAR(20)   NULL,
  b_party             VARCHAR(30)   NULL,
  b_party_e164        VARCHAR(20)   NULL,

  -- Subscriber info
  name_b_party        VARCHAR(200)  NULL,
  father_name         VARCHAR(200)  NULL,
  permanent_address   TEXT          NULL,

  -- Call details
  call_date           DATE          NULL,
  call_time           TIME          NULL,
  call_datetime_utc   DATETIME      NULL,
  duration_seconds    INT           NULL,
  call_type           VARCHAR(50)   NULL,

  -- Cell tower
  first_cell_id       VARCHAR(50)   NULL,
  first_cell_address  TEXT          NULL,
  last_cell_id        VARCHAR(50)   NULL,
  last_cell_address   TEXT          NULL,

  -- Device
  imei                VARCHAR(20)   NULL,
  imsi                VARCHAR(20)   NULL,
  roaming             TINYINT(1)    NULL,

  -- Network
  circle              VARCHAR(100)  NULL,
  operator            VARCHAR(100)  NULL,

  -- Location
  main_city           VARCHAR(100)  NULL,
  sub_city            VARCHAR(100)  NULL,
  latitude            DECIMAL(10,7) NULL,
  longitude           DECIMAL(10,7) NULL,

  -- Device info
  device_type         VARCHAR(100)  NULL,
  device_manufacturer VARCHAR(100)  NULL,

  -- CDR file level
  cdr_name            VARCHAR(200)  NULL,
  cdr_address         TEXT          NULL,

  -- Audit
  raw_row_json        JSON          NULL,
  is_deleted          TINYINT(1)    NOT NULL DEFAULT 0,
  created_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_upload FOREIGN KEY (upload_id) REFERENCES uploads(id) ON DELETE CASCADE
);

-- Indexes for fast lookup
CREATE INDEX idx_cdr_upload_id       ON cdr_records(upload_id);
CREATE INDEX idx_cdr_number          ON cdr_records(cdr_number);
CREATE INDEX idx_cdr_number_e164     ON cdr_records(cdr_number_e164);
CREATE INDEX idx_b_party             ON cdr_records(b_party);
CREATE INDEX idx_b_party_e164        ON cdr_records(b_party_e164);
CREATE INDEX idx_call_date           ON cdr_records(call_date);
CREATE INDEX idx_call_datetime       ON cdr_records(call_datetime_utc);
CREATE INDEX idx_call_type           ON cdr_records(call_type);
CREATE INDEX idx_imei                ON cdr_records(imei);
CREATE INDEX idx_imsi                ON cdr_records(imsi);
CREATE INDEX idx_circle              ON cdr_records(circle);
CREATE INDEX idx_operator            ON cdr_records(operator);
CREATE INDEX idx_main_city           ON cdr_records(main_city);
CREATE INDEX idx_first_cell_id       ON cdr_records(first_cell_id);
CREATE INDEX idx_is_deleted          ON cdr_records(is_deleted);

-- Full-text search index on key text fields
ALTER TABLE cdr_records ADD FULLTEXT INDEX idx_cdr_fulltext (
  cdr_number, b_party, name_b_party, father_name,
  permanent_address, imei, imsi, main_city, sub_city,
  operator, circle, first_cell_address, last_cell_address,
  cdr_name, cdr_address, first_cell_id
);

-- ============================================================
-- AUDIT LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id           BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id      VARCHAR(100)  NOT NULL,
  action       VARCHAR(50)   NOT NULL,
  query_string TEXT          NULL,
  result_count INT           NULL,
  metadata     JSON          NULL,
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_audit_user    (user_id),
  INDEX idx_audit_action  (action),
  INDEX idx_audit_created (created_at)
);

-- ============================================================
-- DEFAULT USERS  (passwords: Admin@123 / Analyst@123)
-- Run seed separately via: cd backend && npm run seed
-- ============================================================
