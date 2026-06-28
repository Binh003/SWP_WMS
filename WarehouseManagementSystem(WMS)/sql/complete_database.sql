-- ============================================================================
-- WAREHOUSE MANAGEMENT SYSTEM (WMS) DATABASE INITIALIZATION SCRIPT
-- Synthesized from Phase 1 to Phase 4
-- Target Database: MySQL 8.0+
-- Múi giờ mặc định: Asia/Ho_Chi_Minh
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `sku_inventory_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `sku_inventory_db`;

-- Tắt kiểm tra khóa ngoại tạm thời để xóa bảng nếu cần thiết lập lại từ đầu
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `shipment_history`;
DROP TABLE IF EXISTS `receipt_history`;
DROP TABLE IF EXISTS `shipment_details`;
DROP TABLE IF EXISTS `shipments`;
DROP TABLE IF EXISTS `receipt_details`;
DROP TABLE IF EXISTS `receipts`;
DROP TABLE IF EXISTS `inventories`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `product_lines`;
DROP TABLE IF EXISTS `suppliers`;
DROP TABLE IF EXISTS `brands`;
DROP TABLE IF EXISTS `password_resets`;
DROP TABLE IF EXISTS `role_permissions`;
DROP TABLE IF EXISTS `user_roles`;
DROP TABLE IF EXISTS `permissions`;
DROP TABLE IF EXISTS `roles`;
DROP TABLE IF EXISTS `users`;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- 1. BẢNG HỆ THỐNG & PHÂN QUYỀN (PHASE 1)
-- ============================================================================

-- Bảng Người dùng (users)
CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `full_name` VARCHAR(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` VARCHAR(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` BIT(1) NOT NULL DEFAULT b'1',
  `status` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_users_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Vai trò (roles)
CREATE TABLE `roles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` VARCHAR(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` VARCHAR(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enabled` BIT(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_roles_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Quyền hạn (permissions)
CREATE TABLE `permissions` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` VARCHAR(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` VARCHAR(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_permissions_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng liên kết Người dùng - Vai trò (user_roles)
CREATE TABLE `user_roles` (
  `user_id` BIGINT NOT NULL,
  `role_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  CONSTRAINT `fk_user_roles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_roles_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng liên kết Vai trò - Quyền hạn (role_permissions)
CREATE TABLE `role_permissions` (
  `role_id` BIGINT NOT NULL,
  `permission_id` BIGINT NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  CONSTRAINT `fk_role_permissions_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_role_permissions_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Yêu cầu Khôi phục mật khẩu (password_resets)
CREATE TABLE `password_resets` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `token` VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiry_time` TIMESTAMP NOT NULL,
  `used` BIT(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_password_resets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- 2. BẢNG DANH MỤC SẢN PHẨM & ĐỐI TÁC (PHASE 2 & 3)
-- ============================================================================

-- Bảng Hãng sản xuất (brands)
CREATE TABLE `brands` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` VARCHAR(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` TEXT COLLATE utf8mb4_unicode_ci,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_brands_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Nhà cung cấp (suppliers)
CREATE TABLE `suppliers` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` VARCHAR(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` VARCHAR(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` VARCHAR(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` VARCHAR(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_suppliers_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Dòng sản phẩm (product_lines)
CREATE TABLE `product_lines` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `brand_id` BIGINT NOT NULL,
  `code` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` VARCHAR(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` TEXT COLLATE utf8mb4_unicode_ci,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_lines_code` (`code`),
  CONSTRAINT `fk_product_lines_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Sản phẩm (products)
CREATE TABLE `products` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `product_line_id` BIGINT NOT NULL,
  `sku` VARCHAR(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `unit` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Đơn vị tính (Cái, Chiếc, Bộ, Hộp...)',
  `price` DECIMAL(15,2) DEFAULT '0.00',
  `description` TEXT COLLATE utf8mb4_unicode_ci,
  `image_url` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_products_sku` (`sku`),
  CONSTRAINT `fk_products_product_line` FOREIGN KEY (`product_line_id`) REFERENCES `product_lines` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Quản lý Tồn kho (inventories)
CREATE TABLE `inventories` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `product_id` BIGINT NOT NULL,
  `quantity_in_stock` INT NOT NULL DEFAULT '0',
  `min_stock_level` INT DEFAULT '10' COMMENT 'Mức tồn kho tối thiểu để cảnh báo',
  `last_updated` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_inventories_product` (`product_id`),
  CONSTRAINT `fk_inventories_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- 3. BẢNG NGHIỆP VỤ NHẬP XUẤT KHO & LỊCH SỬ (PHASE 4)
-- ============================================================================

-- Bảng Phiếu Nhập Kho (receipts)
CREATE TABLE `receipts` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `receipt_code` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `supplier_id` BIGINT NOT NULL,
  `created_by` BIGINT NOT NULL,
  `status` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT', -- DRAFT, PENDING, APPROVED, RECEIVING, COMPLETED, CANCELLED
  `notes` TEXT COLLATE utf8mb4_unicode_ci,
  `invoice_image` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receiving_images` VARCHAR(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_wms_receipts_code` (`receipt_code`),
  CONSTRAINT `fk_wms_receipts_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_wms_receipts_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Chi tiết Phiếu Nhập Kho (receipt_details)
CREATE TABLE `receipt_details` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `receipt_id` BIGINT NOT NULL,
  `product_id` BIGINT NOT NULL,
  `quantity` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_wms_rd_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_wms_rd_receipt` FOREIGN KEY (`receipt_id`) REFERENCES `receipts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Lịch sử cập nhật Phiếu Nhập (receipt_history)
CREATE TABLE `receipt_history` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `receipt_id` BIGINT NOT NULL,
  `from_status` VARCHAR(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `to_status` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `changed_by` BIGINT NOT NULL,
  `changed_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `notes` TEXT COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_rh_receipt` FOREIGN KEY (`receipt_id`) REFERENCES `receipts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rh_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Phiếu Xuất Kho (shipments)
CREATE TABLE `shipments` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `shipment_code` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `destination` VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` BIGINT NOT NULL,
  `status` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT', -- DRAFT, PENDING, APPROVED, PICKING, COMPLETED, CANCELLED
  `notes` TEXT COLLATE utf8mb4_unicode_ci,
  `delivery_note_image` VARCHAR(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `shipping_images` TEXT COLLATE utf8mb4_unicode_ci,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_wms_shipments_code` (`shipment_code`),
  CONSTRAINT `fk_wms_shipments_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Chi tiết Phiếu Xuất Kho (shipment_details)
CREATE TABLE `shipment_details` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `shipment_id` BIGINT NOT NULL,
  `product_id` BIGINT NOT NULL,
  `quantity` INT NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_wms_sd_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_wms_sd_shipment` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng Lịch sử cập nhật Phiếu Xuất (shipment_history)
CREATE TABLE `shipment_history` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `shipment_id` BIGINT NOT NULL,
  `from_status` VARCHAR(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `to_status` VARCHAR(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `changed_by` BIGINT NOT NULL,
  `changed_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `notes` TEXT COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_sh_shipment` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sh_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- 4. DỮ LIỆU CẤU HÌNH HỆ THỐNG MẪU (ROLES, PERMISSIONS & SEEDS)
-- ============================================================================

-- Seed Quyền hạn (Permissions)
INSERT INTO `permissions` (`code`, `name`, `description`) VALUES
('USER_READ', 'Xem người dùng', 'Cho phép xem danh sách người dùng'),
('USER_WRITE', 'Quản lý người dùng', 'Cho phép thêm mới, kích hoạt, vô hiệu hóa tài khoản người dùng'),
('ROLE_READ', 'Xem vai trò', 'Cho phép xem vai trò phân quyền'),
('ROLE_WRITE', 'Quản lý vai trò', 'Cho phép thêm mới và cấu hình vai trò'),
('PERMISSION_READ', 'Xem quyền', 'Cho phép xem danh sách quyền hệ thống'),
('BRAND_READ', 'Xem danh sách Hãng', 'Cho phép xem danh sách và chi tiết Hãng sản xuất'),
('BRAND_WRITE', 'Thêm/Sửa/Xóa Hãng', 'Cho phép thêm mới, cập nhật và xóa Hãng sản xuất'),
('SUPPLIER_READ', 'Xem danh sách Nhà cung cấp', 'Cho phép xem danh sách và chi tiết Nhà cung cấp'),
('SUPPLIER_WRITE', 'Thêm/Sửa/Xóa Nhà cung cấp', 'Cho phép thêm mới, cập nhật và xóa Nhà cung cấp'),
('PRODUCT_LINE_READ', 'Xem danh sách Dòng sản phẩm', 'Cho phép xem danh sách Dòng sản phẩm'),
('PRODUCT_LINE_WRITE', 'Thêm/Sửa/Xóa Dòng sản phẩm', 'Cho phép thêm mới, cập nhật và xóa Dòng sản phẩm'),
('PRODUCT_READ', 'Xem Sản phẩm', 'Quyền xem danh sách và chi tiết sản phẩm'),
('PRODUCT_WRITE', 'Quản lý Sản phẩm', 'Quyền thêm, sửa, xóa sản phẩm'),
('INVENTORY_READ', 'Xem Tồn kho', 'Quyền xem số lượng tồn kho của các sản phẩm'),
('INVENTORY_WRITE', 'Quản lý Tồn kho', 'Quyền cập nhật cấu hình tồn kho ban đầu'),
('RECEIPT_READ', 'Xem Phiếu Nhập', 'Quyền xem danh sách và chi tiết phiếu nhập kho'),
('RECEIPT_WRITE', 'Tạo Phiếu Nhập', 'Quyền tạo mới và cập nhật trạng thái phiếu nhập kho'),
('SHIPMENT_READ', 'Xem Phiếu Xuất', 'Quyền xem danh sách và chi tiết phiếu xuất kho'),
('SHIPMENT_WRITE', 'Tạo Phiếu Xuất', 'Quyền tạo mới và cập nhật trạng thái phiếu xuất kho'),
('REPORT_READ', 'Xem Báo cáo', 'Quyền xem thống kê báo cáo kho hàng');

-- Seed Vai trò (Roles)
INSERT INTO `roles` (`id`, `code`, `name`, `description`) VALUES
(1, 'ADMIN', 'Administrator', 'Quản trị viên toàn quyền hệ thống'),
(2, 'WAREHOUSE STAFF', 'Warehouse Staff', 'Nhân viên thủ kho (quản lý nhập, xuất và kiểm kê)'),
(3, 'WAREHOUSE MANAGER', 'Warehouse Manager', 'Quản lý kho hàng (phê duyệt phiếu và xem báo cáo)'),
(4, 'DIRECTOR', 'Director', 'Giám đốc (phê duyệt yêu cầu nhập xuất kho và xem báo cáo)'),
(5, 'SALES STAFF', 'Sales Staff', 'Nhân viên kinh doanh (tạo yêu cầu nhập, xuất kho)');

-- Liên kết Vai trò - Quyền hạn (role_permissions)
-- Admin: Toàn quyền
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 1, `id` FROM `permissions`;

-- Warehouse Staff: Đọc danh mục, tạo phiếu nhập/xuất
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 2, `id` FROM `permissions` WHERE `code` IN (
  'BRAND_READ', 'SUPPLIER_READ', 'PRODUCT_LINE_READ', 'PRODUCT_READ', 
  'INVENTORY_READ', 'RECEIPT_READ', 'RECEIPT_WRITE', 'SHIPMENT_READ', 'SHIPMENT_WRITE'
);

-- Warehouse Manager: Quản lý danh mục, phê duyệt phiếu nhập/xuất, xem báo cáo
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 3, `id` FROM `permissions` WHERE `code` IN (
  'BRAND_READ', 'BRAND_WRITE', 'SUPPLIER_READ', 'SUPPLIER_WRITE', 'PRODUCT_LINE_READ', 'PRODUCT_LINE_WRITE', 
  'PRODUCT_READ', 'PRODUCT_WRITE', 'INVENTORY_READ', 'INVENTORY_WRITE', 
  'RECEIPT_READ', 'RECEIPT_WRITE', 'SHIPMENT_READ', 'SHIPMENT_WRITE', 'REPORT_READ'
);

-- Director: Đọc danh mục, phê duyệt phiếu nhập/xuất, xem báo cáo
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 4, `id` FROM `permissions` WHERE `code` IN (
  'BRAND_READ', 'SUPPLIER_READ', 'SUPPLIER_WRITE', 'PRODUCT_LINE_READ', 
  'PRODUCT_READ', 'RECEIPT_READ', 'RECEIPT_WRITE', 'REPORT_READ'
);

-- Sales Staff: Đọc danh mục, tạo phiếu nhập/xuất
INSERT INTO `role_permissions` (`role_id`, `permission_id`)
SELECT 5, `id` FROM `permissions` WHERE `code` IN (
  'BRAND_READ', 'PRODUCT_LINE_READ', 'PRODUCT_READ', 
  'RECEIPT_READ', 'RECEIPT_WRITE', 'SHIPMENT_READ', 'SHIPMENT_WRITE'
);

-- Seed Tài khoản Quản trị mặc định (admin / admin123)
-- Password hash: $2a$10$S/G1p58s.LpI93g7d1q6veZ.6z8bM7p1OQ6p1e.w2.b63v.3o2j0u (bcrypt của admin123)
INSERT INTO `users` (`id`, `username`, `full_name`, `email`, `password_hash`, `enabled`, `status`) VALUES
(1, 'admin', 'Administrator', 'admin@inventory.local', '$2a$10$S/G1p58s.LpI93g7d1q6veZ.6z8bM7p1OQ6p1e.w2.b63v.3o2j0u', b'1', 'ACTIVE');

-- Gán vai trò ADMIN cho tài khoản admin
INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES (1, 1);


-- ============================================================================
-- 5. DỮ LIỆU NGHIỆP VỤ MẪU (DEMO BUSINESS DATA)
-- ============================================================================

-- Seed Hãng (brands)
INSERT INTO `brands` (`id`, `code`, `name`, `description`) VALUES
(1, 'APL', 'Apple', 'Tập đoàn công nghệ đa quốc gia của Mỹ chuyên thiết kế, phát triển và bán thiết bị điện tử tiêu dùng.'),
(2, 'SS', 'Samsung', 'Tập đoàn tài phiệt đa quốc gia khổng lồ của Hàn Quốc.'),
(3, 'SNY', 'Sony', 'Tập đoàn đa quốc gia của Nhật Bản, nổi tiếng với thiết bị điện tử, máy ảnh và máy chơi game.'),
(4, 'DELL', 'Dell', 'Công ty đa quốc gia của Hoa Kỳ chuyên phát triển và thương mại hóa công nghệ máy tính.');

-- Seed Nhà cung cấp (suppliers)
INSERT INTO `suppliers` (`id`, `code`, `name`, `phone`, `email`, `address`) VALUES
(1, 'DGW', 'Công ty CP Thế Giới Số (Digiworld)', '02839290059', 'contact@digiworld.com.vn', 'Số 201-203 Cách Mạng Tháng Tám, Quận 3, TP.HCM'),
(2, 'SYN', 'Synnex FPT', '02473006666', 'info@synnexfpt.com', 'Tòa nhà FPT, Số 17 Duy Tân, Cầu Giấy, Hà Nội'),
(3, 'PET', 'Petrosetco', '02838222222', 'info@petrosetco.com.vn', 'Số 1-5 Lê Duẩn, Quận 1, TP.HCM');

-- Seed Dòng sản phẩm (product_lines)
INSERT INTO `product_lines` (`id`, `brand_id`, `code`, `name`, `description`) VALUES
(1, 1, 'IPHONE', 'Apple iPhone', 'Dòng điện thoại thông minh cao cấp của Apple'),
(2, 1, 'MACBOOK', 'Apple MacBook', 'Dòng máy tính xách tay của Apple'),
(3, 2, 'GALAXY_S', 'Samsung Galaxy S', 'Dòng điện thoại Flagship của Samsung'),
(4, 2, 'GALAXY_TAB', 'Samsung Galaxy Tab', 'Dòng máy tính bảng của Samsung'),
(5, 3, 'PS', 'Sony PlayStation', 'Dòng máy chơi game Console của Sony'),
(6, 4, 'XPS', 'Dell XPS', 'Dòng máy tính xách tay cao cấp của Dell');

-- Seed Sản phẩm (products)
INSERT INTO `products` (`id`, `product_line_id`, `sku`, `name`, `unit`, `price`, `description`) VALUES
(1, 1, 'IP15-PM-256-NAT', 'iPhone 15 Pro Max 256GB Titan Tự Nhiên', 'Chiếc', 34990000.00, 'Màn hình 6.7 inch, Chip A17 Pro', NULL),
(2, 2, 'MAC-AIR-M3-8-256', 'MacBook Air M3 8-Core CPU 8GB 256GB', 'Chiếc', 27990000.00, 'Chip M3 mới nhất, siêu mỏng nhẹ', NULL),
(3, 3, 'SS-S24-ULT-512', 'Samsung Galaxy S24 Ultra 512GB', 'Chiếc', 37490000.00, 'Có AI, Bút S-Pen tích hợp', NULL),
(4, 5, 'SONY-PS5-SLIM', 'Sony PlayStation 5 Slim Standard', 'Bộ', 14490000.00, 'Phiên bản có ổ đĩa quang', NULL);

-- Seed Tồn kho ban đầu (inventories)
INSERT INTO `inventories` (`id`, `product_id`, `quantity_in_stock`, `min_stock_level`) VALUES
(1, 1, 50, 10),
(2, 2, 20, 5),
(3, 3, 30, 10),
(4, 4, 15, 5);

COMMIT;
