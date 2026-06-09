USE sku_inventory_db;

-- 1. Create Products Table
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_line_id BIGINT NOT NULL,
    sku VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    unit VARCHAR(50),
    price DECIMAL(15, 2),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uk_products_sku UNIQUE (sku),
    CONSTRAINT fk_products_product_line FOREIGN KEY (product_line_id) REFERENCES product_lines(id)
);

-- 2. Create Inventories Table
CREATE TABLE IF NOT EXISTS inventories (
    product_id BIGINT PRIMARY KEY,
    quantity_in_stock INT NOT NULL DEFAULT 0,
    min_stock_level INT NOT NULL DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventories_product FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 3. Add Permissions for Phase 3
INSERT IGNORE INTO permissions (code, name, description) VALUES 
('PRODUCT_READ', 'Xem Sản phẩm', 'Quyền xem danh sách và chi tiết sản phẩm'),
('PRODUCT_WRITE', 'Quản lý Sản phẩm', 'Quyền thêm, sửa, xóa sản phẩm'),
('INVENTORY_READ', 'Xem Tồn kho', 'Quyền xem số lượng tồn kho của các sản phẩm'),
('INVENTORY_WRITE', 'Quản lý Tồn kho', 'Quyền cập nhật cấu hình tồn kho ban đầu');

-- 4. Grant Permissions to ADMIN Role (Assumes ADMIN role has code 'ADMIN')
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.code = 'ADMIN' 
  AND p.code IN ('PRODUCT_READ', 'PRODUCT_WRITE', 'INVENTORY_READ', 'INVENTORY_WRITE');
