-- Dữ liệu quyền (Permissions) cho Phase 2 (Master Data)
INSERT IGNORE INTO permissions (code, name, description) VALUES
('BRAND_READ', 'Xem danh sách Hãng', 'Cho phép xem danh sách và chi tiết Hãng sản xuất'),
('BRAND_WRITE', 'Thêm/Sửa/Xóa Hãng', 'Cho phép thêm mới, cập nhật và xóa Hãng sản xuất'),
('SUPPLIER_READ', 'Xem danh sách Nhà cung cấp', 'Cho phép xem danh sách và chi tiết Nhà cung cấp'),
('SUPPLIER_WRITE', 'Thêm/Sửa/Xóa Nhà cung cấp', 'Cho phép thêm mới, cập nhật và xóa Nhà cung cấp'),
('PRODUCT_LINE_READ', 'Xem danh sách Dòng sản phẩm', 'Cho phép xem danh sách Dòng sản phẩm'),
('PRODUCT_LINE_WRITE', 'Thêm/Sửa/Xóa Dòng sản phẩm', 'Cho phép thêm mới, cập nhật và xóa Dòng sản phẩm');

-- Cấp toàn quyền cho ADMIN
SET @admin_role_id = (SELECT id FROM roles WHERE code = 'ADMIN');
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT @admin_role_id, id FROM permissions 
WHERE code IN ('BRAND_READ', 'BRAND_WRITE', 'SUPPLIER_READ', 'SUPPLIER_WRITE', 'PRODUCT_LINE_READ', 'PRODUCT_LINE_WRITE')
AND @admin_role_id IS NOT NULL;

-- Cấp quyền Đọc (READ) cho WAREHOUSE STAFF
-- Lưu ý: Bạn có thể điều chỉnh mã code 'WAREHOUSE STAFF' nếu trong DB dùng 'WAREHOUSE_STAFF' hoặc 'WAREHOUSE'
SET @staff_role_id = (SELECT id FROM roles WHERE code = 'WAREHOUSE STAFF');
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT @staff_role_id, id FROM permissions 
WHERE code IN ('BRAND_READ', 'SUPPLIER_READ', 'PRODUCT_LINE_READ')
AND @staff_role_id IS NOT NULL;

-- Cấp quyền Đọc (READ) cho VIEWER
SET @viewer_role_id = (SELECT id FROM roles WHERE code = 'VIEWER');
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT @viewer_role_id, id FROM permissions 
WHERE code IN ('BRAND_READ', 'SUPPLIER_READ', 'PRODUCT_LINE_READ')
AND @viewer_role_id IS NOT NULL;
