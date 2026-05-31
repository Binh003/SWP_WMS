CREATE DATABASE IF NOT EXISTS sku_inventory_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sku_inventory_db;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  full_name VARCHAR(200) NOT NULL,
  email VARCHAR(200) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  enabled BIT(1) NOT NULL DEFAULT 1,
  CONSTRAINT uk_users_username UNIQUE (username)
);

CREATE TABLE IF NOT EXISTS roles (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL,
  name VARCHAR(200) NOT NULL,
  description VARCHAR(500),
  enabled BIT(1) NOT NULL DEFAULT 1,
  CONSTRAINT uk_roles_code UNIQUE (code)
);

CREATE TABLE IF NOT EXISTS permissions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(100) NOT NULL,
  name VARCHAR(200) NOT NULL,
  description VARCHAR(500),
  CONSTRAINT uk_permissions_code UNIQUE (code)
);

CREATE TABLE IF NOT EXISTS user_roles (
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE IF NOT EXISTS role_permissions (
  role_id BIGINT NOT NULL,
  permission_id BIGINT NOT NULL,
  PRIMARY KEY (role_id, permission_id),
  CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_id) REFERENCES roles(id),
  CONSTRAINT fk_role_permissions_permission FOREIGN KEY (permission_id) REFERENCES permissions(id)
);
