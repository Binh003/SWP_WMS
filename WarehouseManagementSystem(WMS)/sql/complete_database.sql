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
  `batch_code` VARCHAR(100) NOT NULL DEFAULT '',
  `barcode` VARCHAR(100) NOT NULL DEFAULT '',
  `quantity_in_stock` INT NOT NULL DEFAULT '0',
  `min_stock_level` INT DEFAULT '10' COMMENT 'Mức tồn kho tối thiểu để cảnh báo',
  `last_updated` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_inventories_batch_barcode` (`product_id`, `batch_code`, `barcode`),
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
  `batch_code` VARCHAR(100) NOT NULL DEFAULT '',
  `barcode` VARCHAR(100) NOT NULL DEFAULT '',
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
  `batch_code` TEXT,
  `barcode` TEXT,
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
('SHIPMENT_WRITE', 'Tạo Yêu Cầu Xuất Kho', 'Quyền tạo mới và cập nhật trạng thái phiếu xuất kho'),
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
(6, 4, 'XPS', 'Dell XPS', 'Dòng máy tính xách tay cao cấp của Dell'),
(7, 1, 'IPAD', 'Apple iPad', 'Dòng máy tính bảng của Apple'),
(8, 1, 'AWATCH', 'Apple Watch', 'Dòng đồng hồ thông minh của Apple'),
(9, 2, 'GALAXY_A', 'Samsung Galaxy A', 'Dòng điện thoại phân khúc tầm trung của Samsung'),
(10, 2, 'GALAXY_BUDS', 'Samsung Galaxy Buds', 'Tai nghe không dây của Samsung'),
(11, 3, 'AUDIO', 'Sony Audio', 'Thiết bị âm thanh chuyên nghiệp của Sony'),
(12, 3, 'CAMERA', 'Sony Camera', 'Máy ảnh và phụ kiện chụp hình của Sony'),
(13, 4, 'INSPIRON', 'Dell Inspiron', 'Dòng máy tính xách tay phổ thông của Dell'),
(14, 4, 'MONITOR', 'Dell Monitor', 'Màn hình máy tính chuyên nghiệp của Dell');

-- Seed Sản phẩm (products)
INSERT INTO `products` (`id`, `product_line_id`, `sku`, `name`, `unit`, `price`, `description`, `image_url`) VALUES
(1, 1, 'IP-17-01', 'IPhone 17 Pro Max', 'Cái', 30000000.00, 'Iphone', 'https://smartviets.com/upload/iphone_17_series/IP_17_Pro_Max_Cam.png'),
(2, 7, 'LG-LST', 'LG Smart TV', 'Chiếc', 15000000.00, '', 'https://www.lg.com/content/dam/channel/wcms/ph/images/tvs/50ut8000psb_aph_eacm_ph_c/gallery/large_01.jpg/_jcr_content/renditions/thum-1600x1062.jpeg'),
-- Apple
(3, 2, 'APL-MB-AIR-M3', 'MacBook Air M3 13-inch', 'Chiếc', 27990000.00, 'Mỏng nhẹ, mạnh mẽ với chip M3', 'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=500'),
(4, 8, 'APL-IPAD-AIR-M2', 'iPad Air M2 11-inch Wifi', 'Chiếc', 16990000.00, 'iPad Air thế hệ mới chip M2', 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500'),
(5, 9, 'APL-WATCH-S9', 'Apple Watch Series 9 GPS 45mm', 'Chiếc', 10490000.00, 'Đồng hồ thông minh thế hệ 9', 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=500'),
(6, 10, 'APL-AIR-PRO-2', 'Apple AirPods Pro 2 USB-C', 'Hộp', 5990000.00, 'Tai nghe chống ồn chủ động đỉnh cao', 'https://images.unsplash.com/photo-1588449668338-d13a77f3f4d2?w=500'),
-- Samsung
(7, 3, 'SS-S24-ULTRA', 'Samsung Galaxy S24 Ultra 256GB', 'Cái', 29990000.00, 'Flagship đỉnh cao với Galaxy AI', 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=500'),
(8, 4, 'SS-TAB-S9', 'Samsung Galaxy Tab S9 128GB', 'Chiếc', 18990000.00, 'Máy tính bảng màn hình AMOLED siêu nét', 'https://images.unsplash.com/photo-1589739900243-4b52cd9b104e?w=500'),
(9, 11, 'SS-A55-5G', 'Samsung Galaxy A55 5G', 'Cái', 9990000.00, 'Điện thoại tầm trung bán chạy nhất', 'https://images.unsplash.com/photo-1565630916779-e303be97b6f5?w=500'),
(10, 12, 'SS-WATCH-6', 'Samsung Galaxy Watch 6 44mm', 'Chiếc', 6490000.00, 'Đồng hồ thông minh theo dõi sức khỏe chuyên sâu', 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=500'),
(11, 13, 'SS-BUDS2-PRO', 'Samsung Galaxy Buds 2 Pro', 'Hộp', 3490000.00, 'Tai nghe âm thanh 24-bit chất lượng cao', 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=500'),
-- Sony
(12, 5, 'SNY-PS5-SLIM', 'Sony PlayStation 5 Slim', 'Bộ', 14490000.00, 'Máy chơi game thế hệ mới bản Slim', 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=500'),
(13, 14, 'SNY-WH-1000XM5', 'Sony WH-1000XM5 Headphone', 'Chiếc', 8490000.00, 'Tai nghe chụp tai chống ồn tốt nhất', 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?w=500'),
(14, 15, 'SNY-A7M4-BODY', 'Sony Alpha 7 IV Body', 'Chiếc', 58900000.00, 'Máy ảnh mirrorless chuyên nghiệp 33MP', 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500'),
(15, 16, 'SNY-55X80L', 'Smart Tivi Sony 4K 55 inch 55X80L', 'Chiếc', 14900000.00, 'Hình ảnh chân thực, âm thanh vòm Dolby Atmos', 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=500'),
(16, 17, 'SNY-SRS-XE200', 'Loa Bluetooth di động Sony SRS-XE200', 'Chiếc', 2490000.00, 'Loa di động chống nước, chống bụi IP67', 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500'),
-- Dell
(17, 6, 'DELL-XPS-13', 'Dell XPS 13 9340', 'Chiếc', 45990000.00, 'Laptop doanh nhân cao cấp siêu mỏng', 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=500'),
(18, 18, 'DELL-INS-5630', 'Dell Inspiron 16 5630', 'Chiếc', 18490000.00, 'Laptop văn phòng học tập mạnh mẽ', 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=500'),
(19, 19, 'DELL-VOS-3430', 'Dell Vostro 14 3430', 'Chiếc', 12990000.00, 'Laptop làm việc văn phòng giá tốt', 'https://images.unsplash.com/photo-1496181130204-755241524eab?w=500'),
(20, 20, 'DELL-U2422H', 'Màn hình Dell UltraSharp U2422H 24 inch', 'Chiếc', 6200000.00, 'Màn hình chuẩn màu đồ họa chuyên nghiệp', 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500'),
(21, 21, 'DELL-AW-M16', 'Dell Alienware M16 R1', 'Chiếc', 54990000.00, 'Laptop gaming cấu hình khủng long', 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=500'),
-- LG
(22, 22, 'LG-FR-600L', 'Tủ lạnh LG Side by Side 600L', 'Chiếc', 22900000.00, 'Tủ lạnh dung tích lớn tiết kiệm điện', 'https://images.unsplash.com/photo-1571175432267-efb9214e2373?w=500'),
(23, 23, 'LG-WM-10KG', 'Máy giặt cửa trước LG Inverter 10kg', 'Chiếc', 9490000.00, 'Máy giặt thông minh AI DD bảo vệ sợi vải', 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=500'),
(24, 24, 'LG-AC-12000', 'Điều hòa LG Dual Inverter 1.5 HP', 'Bộ', 10990000.00, 'Làm lạnh nhanh, kháng khuẩn lọc khí', 'https://images.unsplash.com/photo-1621905252507-b354bc25edac?w=500'),
(25, 25, 'LG-MON-27UL550', 'Màn hình LG 27 inch 4K HDR 27UL550', 'Chiếc', 7290000.00, 'Độ phân giải 4K chuyên nghiệp giá tốt', 'https://images.unsplash.com/photo-1547082299-de196ea013d6?w=500'),
-- Panasonic
(26, 26, 'PAN-AC-9000', 'Điều hòa Panasonic Inverter 1.0 HP', 'Bộ', 9990000.00, 'Điều hòa kháng khuẩn Nanoe-G cao cấp', 'https://images.unsplash.com/photo-1621905252507-b354bc25edac?w=500'),
(27, 27, 'PAN-FR-322L', 'Tủ lạnh Panasonic Inverter 322L', 'Chiếc', 13490000.00, 'Ngăn đông mềm PrimeFresh+ giữ trọn dinh dưỡng', 'https://images.unsplash.com/photo-1571175432267-efb9214e2373?w=500'),
(28, 28, 'PAN-WM-9KG', 'Máy giặt Panasonic Inverter 9kg', 'Chiếc', 8290000.00, 'Giặt nước nóng StainMaster+ diệt khuẩn', 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=500'),
(29, 29, 'PAN-COOKER-18L', 'Nồi cơm điện cao tần Panasonic 1.8L', 'Chiếc', 4990000.00, 'Công nghệ nấu cao tần IH hạt cơm chín đều ngon', 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=500'),
(30, 30, 'PAN-BL-500W', 'Máy xay sinh tố Panasonic MX-EX1561', 'Chiếc', 1150000.00, 'Công suất mạnh mẽ, lưỡi dao thép không gỉ', 'https://images.unsplash.com/photo-1578643463396-0997cb5328c1?w=500'),
-- Daikin
(31, 31, 'DAI-AC-FTKF25', 'Điều hòa Daikin Inverter 1.0 HP', 'Bộ', 10990000.00, 'Phân phối gió 3D, mắt thần thông minh', 'https://images.unsplash.com/photo-1621905252507-b354bc25edac?w=500'),
(32, 32, 'DAI-AC-FCNQ18', 'Điều hòa âm trần Daikin 2.0 HP', 'Bộ', 24900000.00, 'Thiết kế âm trần sang trọng, gió thổi 360 độ', 'https://images.unsplash.com/photo-1621905252507-b354bc25edac?w=500'),
(33, 33, 'DAI-PUR-MC30Y', 'Máy lọc không khí Daikin MC30YVM7', 'Chiếc', 3990000.00, 'Phin lọc HEPA tĩnh điện kết hợp Streamer', 'https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?w=500'),
(34, 34, 'DAI-VRV-10HP', 'Dàn nóng trung tâm Daikin VRV A 10HP', 'Hệ', 150000000.00, 'Hệ thống điều hòa không khí trung tâm thông minh', 'https://images.unsplash.com/photo-1621905252507-b354bc25edac?w=500'),
-- Toshiba
(35, 35, 'TOS-WM-AW1000', 'Máy giặt Toshiba 9.0kg AW-M1000FV', 'Chiếc', 5490000.00, 'Máy giặt lồng đứng nắp kính cường lực', 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=500'),
(36, 36, 'TOS-FR-GR31AM', 'Tủ lạnh Toshiba Inverter 253L', 'Chiếc', 6990000.00, 'Hệ thống lọc khí khử mùi Ag+ Bio', 'https://images.unsplash.com/photo-1571175432267-efb9214e2373?w=500'),
(37, 37, 'TOS-CK-RC18IX', 'Nồi cơm điện cao tần Toshiba 1.8L', 'Chiếc', 2890000.00, 'Lòng nồi dày 7 lớp phủ chống dính Binchotan', 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=500'),
(38, 38, 'TOS-MW-MM20P', 'Lò vi sóng cơ Toshiba 20L', 'Chiếc', 1450000.00, 'Lò vi sóng cơ bền bỉ dễ sử dụng', 'https://images.unsplash.com/photo-1574269664686-8f43499d398d?w=500'),
(39, 39, 'TOS-WD-RWF1669', 'Cây nước nóng lạnh Toshiba', 'Chiếc', 3590000.00, 'Cây nước thiết kế bình âm sang trọng', 'https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?w=500'),
-- Electrolux
(40, 40, 'ELX-WM-EWF1024', 'Máy giặt Electrolux UltimateCare 10kg', 'Chiếc', 11490000.00, 'Giặt hơi nước Hygiene Care diệt khuẩn', 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=500'),
(41, 41, 'ELX-DRY-EDS854', 'Máy sấy thông hơi Electrolux 8.5kg', 'Chiếc', 10290000.00, 'Cảm biến Smart Sensor chống sấy khô quá mức', 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=500'),
(42, 42, 'ELX-FR-ETB2302', 'Tủ lạnh Electrolux Inverter 225L', 'Chiếc', 6490000.00, 'Hệ thống EvenTemp duy trì nhiệt độ ổn định', 'https://images.unsplash.com/photo-1571175432267-efb9214e2373?w=500'),
(43, 43, 'ELX-OV-EOT3805', 'Lò nướng Electrolux 38L', 'Chiếc', 2190000.00, 'Cửa kính 2 lớp cách nhiệt an toàn', 'https://images.unsplash.com/photo-1574269664686-8f43499d398d?w=500'),
(44, 44, 'ELX-HD-EFT6030', 'Máy hút mùi Electrolux 60cm', 'Chiếc', 3190000.00, 'Chất liệu thép không gỉ, hút mùi mạnh mẽ', 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500'),
-- Sharp
(45, 45, 'SHP-MW-R20A1', 'Lò vi sóng Sharp 20L', 'Chiếc', 1590000.00, 'Lò vi sóng cơ 5 mức công suất tiện lợi', 'https://images.unsplash.com/photo-1574269664686-8f43499d398d?w=500'),
(46, 46, 'SHP-PUR-FPJ30V', 'Máy lọc không khí Sharp', 'Chiếc', 2190000.00, 'Công nghệ Plasmacluster Ion mật độ cao', 'https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?w=500'),
(47, 47, 'SHP-FR-SJ-X281', 'Tủ lạnh Sharp Inverter 253L', 'Chiếc', 5990000.00, 'Công nghệ khử mùi phân tử bạc Nano Ag+ Cu', 'https://images.unsplash.com/photo-1571175432267-efb9214e2373?w=500'),
(48, 48, 'SHP-TV-C50EJ2', 'Smart Tivi Sharp 4K 50 inch', 'Chiếc', 7990000.00, 'Hệ điều hành Android TV kho ứng dụng khổng lồ', 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=500'),
(49, 49, 'SHP-FAN-PJL16', 'Quạt lửng Sharp', 'Chiếc', 990000.00, 'Động cơ đồng bền bỉ, 3 cánh quạt mát dịu', 'https://images.unsplash.com/photo-1618944847023-38aa001235f0?w=500'),
-- Sunhouse
(50, 50, 'SUN-CK-SHD8602', 'Nồi cơm điện Sunhouse 1.8L', 'Chiếc', 590000.00, 'Lòng nồi chống dính Whitford tiêu chuẩn Mỹ', 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=500'),
(51, 51, 'SUN-PAN-SHG1126', 'Chảo siêu bền đá Sunhouse 26cm', 'Cái', 180000.00, 'Nhôm tấm dày dặn, phủ lớp chống dính đá hoa cương', 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=500'),
(52, 52, 'SUN-KT-SHD1182', 'Ấm siêu tốc Sunhouse 1.8L', 'Chiếc', 250000.00, 'Thân ấm 2 lớp cách nhiệt, lòng bình inox 304', 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=500'),
(53, 53, 'SUN-ST-SHB3366', 'Bếp hồng ngoại đôi Sunhouse', 'Chiếc', 2190000.00, 'Mặt kính chịu lực chịu nhiệt tốt, phím cảm ứng', 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500'),
(54, 54, 'SUN-AF-SHD4026', 'Nồi chiên không dầu Sunhouse 6.0L', 'Chiếc', 1690000.00, 'Công nghệ Rapid Air giảm 80% dầu mỡ dư thừa', 'https://images.unsplash.com/photo-1621972750749-0fbb1abb7736?w=500'),
-- Kangaroo
(55, 55, 'KAN-PUR-KG10A3', 'Máy lọc nước RO Kangaroo 10 lõi', 'Chiếc', 5990000.00, 'Lọc nước tinh khiết uống tại vòi, 2 vòi nóng lạnh', 'https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?w=500'),
(56, 56, 'KAN-FN-KG725', 'Quạt cây có điều khiển Kangaroo', 'Chiếc', 1290000.00, '3 chế độ gió, hẹn giờ tắt lên đến 7.5 tiếng', 'https://images.unsplash.com/photo-1618944847023-38aa001235f0?w=500'),
(57, 57, 'KAN-CK-KG835', 'Nồi cơm điện lòng niêu Kangaroo 1.8L', 'Chiếc', 890000.00, 'Lòng niêu dày giữ nhiệt tốt, nấu cơm chín nục', 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=500'),
(58, 58, 'KAN-OV-KG197', 'Lò nướng thủy tinh Kangaroo', 'Chiếc', 990000.00, 'Công nghệ nướng đối lưu bằng đèn Halogen', 'https://images.unsplash.com/photo-1574269664686-8f43499d398d?w=500'),
(59, 59, 'KAN-HT-KG68A2', 'Bình nóng lạnh Kangaroo 22L', 'Chiếc', 2490000.00, 'Ruột bình tráng kim cương nhân tạo bền bỉ', 'https://images.unsplash.com/photo-1621905252507-b354bc25edac?w=500');

-- Seed Tồn kho ban đầu (inventories)
INSERT INTO `inventories` (`id`, `product_id`, `quantity_in_stock`, `min_stock_level`) VALUES
(1, 1, 50, 10),
(2, 2, 20, 5),
(3, 3, 40, 10),
(4, 4, 25, 5),
(5, 5, 30, 8),
(6, 6, 60, 15),
(7, 7, 50, 10),
(8, 8, 20, 5),
(9, 9, 35, 10),
(10, 10, 45, 10),
(11, 11, 80, 15),
(12, 12, 15, 5),
(13, 13, 25, 5),
(14, 14, 10, 2),
(15, 15, 20, 5),
(16, 16, 30, 5),
(17, 17, 15, 3),
(18, 18, 25, 5),
(19, 19, 35, 8),
(20, 20, 40, 10),
(21, 21, 10, 2),
(22, 22, 15, 4),
(23, 23, 20, 5),
(24, 24, 30, 5),
(25, 25, 25, 5),
(26, 26, 30, 5),
(27, 27, 18, 4),
(28, 28, 22, 5),
(29, 29, 40, 10),
(30, 30, 50, 10),
(31, 31, 35, 8),
(32, 32, 15, 3),
(33, 33, 25, 5),
(34, 34, 5, 1),
(35, 35, 30, 5),
(36, 36, 20, 5),
(37, 37, 45, 10),
(38, 38, 25, 5),
(39, 39, 15, 3),
(40, 40, 20, 5),
(41, 41, 15, 3),
(42, 42, 18, 4),
(43, 43, 25, 5),
(44, 44, 12, 3),
(45, 45, 30, 5),
(46, 46, 35, 8),
(47, 47, 20, 5),
(48, 48, 15, 3),
(49, 49, 45, 10),
(50, 50, 60, 15),
(51, 51, 100, 20),
(52, 52, 80, 15),
(53, 53, 30, 5),
(54, 54, 25, 5),
(55, 55, 20, 5),
(56, 56, 40, 10),
(57, 57, 55, 12),
(58, 58, 25, 5),
(59, 59, 30, 5);

COMMIT;
