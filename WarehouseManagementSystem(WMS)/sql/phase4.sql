USE sku_inventory_db;

-- ==========================================
-- 1. Phiếu Nhập Kho (Receipts)
-- ==========================================
CREATE TABLE IF NOT EXISTS receipts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    receipt_code VARCHAR(50) NOT NULL,
    supplier_id BIGINT NOT NULL,
    created_by BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED', -- DRAFT, COMPLETED, CANCELLED
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_wms_receipts_code UNIQUE (receipt_code),
    CONSTRAINT fk_wms_receipts_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    CONSTRAINT fk_wms_receipts_user FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS receipt_details (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    receipt_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT fk_wms_rd_receipt FOREIGN KEY (receipt_id) REFERENCES receipts(id) ON DELETE CASCADE,
    CONSTRAINT fk_wms_rd_product FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 2. Phiếu Xuất Kho (Shipments)
-- ==========================================
CREATE TABLE IF NOT EXISTS shipments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    shipment_code VARCHAR(50) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    created_by BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED', -- DRAFT, COMPLETED, CANCELLED
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_wms_shipments_code UNIQUE (shipment_code),
    CONSTRAINT fk_wms_shipments_user FOREIGN KEY (created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS shipment_details (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    shipment_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT fk_wms_sd_shipment FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE,
    CONSTRAINT fk_wms_sd_product FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ==========================================
-- 3. Quyền hạn (Permissions)
-- ==========================================
INSERT IGNORE INTO permissions (code, name, description) VALUES 
('RECEIPT_READ', 'Xem Phiếu Nhập', 'Quyền xem danh sách và chi tiết phiếu nhập kho'),
('RECEIPT_WRITE', 'Tạo Phiếu Nhập', 'Quyền tạo mới phiếu nhập kho'),
('SHIPMENT_READ', 'Xem Phiếu Xuất', 'Quyền xem danh sách và chi tiết phiếu xuất kho'),
('SHIPMENT_WRITE', 'Tạo Phiếu Xuất', 'Quyền tạo mới phiếu xuất kho');

-- Cấp quyền cho ADMIN
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.code = 'ADMIN' 
  AND p.code IN ('RECEIPT_READ', 'RECEIPT_WRITE', 'SHIPMENT_READ', 'SHIPMENT_WRITE');
