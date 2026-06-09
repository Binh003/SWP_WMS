USE sku_inventory_db;

-- ==========================================
-- 1. DỮ LIỆU MẪU: HÃNG (BRANDS)
-- ==========================================
INSERT IGNORE INTO brands (code, name, description) VALUES 
('APL', 'Apple', 'Tập đoàn công nghệ đa quốc gia của Mỹ chuyên thiết kế, phát triển và bán thiết bị điện tử tiêu dùng.'),
('SS', 'Samsung', 'Tập đoàn tài phiệt đa quốc gia khổng lồ của Hàn Quốc.'),
('SNY', 'Sony', 'Tập đoàn đa quốc gia của Nhật Bản, nổi tiếng với thiết bị điện tử, máy ảnh và máy chơi game.'),
('DELL', 'Dell', 'Công ty đa quốc gia của Hoa Kỳ chuyên phát triển và thương mại hóa công nghệ máy tính.');

-- ==========================================
-- 2. DỮ LIỆU MẪU: NHÀ CUNG CẤP (SUPPLIERS)
-- ==========================================
INSERT IGNORE INTO suppliers (code, name, phone, email, address) VALUES 
('DGW', 'Công ty CP Thế Giới Số (Digiworld)', '02839290059', 'contact@digiworld.com.vn', 'Số 201-203 Cách Mạng Tháng Tám, Quận 3, TP.HCM'),
('SYN', 'Synnex FPT', '02473006666', 'info@synnexfpt.com', 'Tòa nhà FPT, Số 17 Duy Tân, Cầu Giấy, Hà Nội'),
('PET', 'Petrosetco', '02838222222', 'info@petrosetco.com.vn', 'Số 1-5 Lê Duẩn, Quận 1, TP.HCM');

-- ==========================================
-- 3. DỮ LIỆU MẪU: DÒNG SẢN PHẨM (PRODUCT LINES)
-- Lưu ý: brand_id tương ứng với các ID vừa được tạo ở bảng brands (1: Apple, 2: Samsung, 3: Sony, 4: Dell)
-- ==========================================
INSERT IGNORE INTO product_lines (brand_id, code, name, description) VALUES 
(1, 'IPHONE', 'Apple iPhone', 'Dòng điện thoại thông minh cao cấp của Apple'),
(1, 'MACBOOK', 'Apple MacBook', 'Dòng máy tính xách tay của Apple'),
(2, 'GALAXY_S', 'Samsung Galaxy S', 'Dòng điện thoại Flagship của Samsung'),
(2, 'GALAXY_TAB', 'Samsung Galaxy Tab', 'Dòng máy tính bảng của Samsung'),
(3, 'PS', 'Sony PlayStation', 'Dòng máy chơi game Console của Sony'),
(4, 'XPS', 'Dell XPS', 'Dòng máy tính xách tay cao cấp của Dell');

-- ==========================================
-- 4. DỮ LIỆU MẪU: SẢN PHẨM (PRODUCTS) - (Bonus thêm vài SKU để chuẩn bị cho phần 5.4)
-- ==========================================
INSERT IGNORE INTO products (product_line_id, sku, name, unit, price, description) VALUES 
(1, 'IP15-PM-256-NAT', 'iPhone 15 Pro Max 256GB Titan Tự Nhiên', 'Chiếc', 34990000, 'Màn hình 6.7 inch, Chip A17 Pro'),
(1, 'MAC-AIR-M3-8-256', 'MacBook Air M3 8-Core CPU 8GB 256GB', 'Chiếc', 27990000, 'Chip M3 mới nhất, siêu mỏng nhẹ'),
(3, 'SS-S24-ULT-512', 'Samsung Galaxy S24 Ultra 512GB', 'Chiếc', 37490000, 'Có AI, Bút S-Pen tích hợp'),
(5, 'SONY-PS5-SLIM', 'Sony PlayStation 5 Slim Standard', 'Bộ', 14490000, 'Phiên bản có ổ đĩa quang');

-- ==========================================
-- 5. DỮ LIỆU MẪU: TỒN KHO BAN ĐẦU (INVENTORY) 
-- ==========================================
INSERT IGNORE INTO inventories (product_id, quantity_in_stock, min_stock_level) VALUES 
(1, 50, 10), -- Tồn 50 iPhone, báo động nếu dưới 10
(2, 20, 5),  -- Tồn 20 Macbook, báo động nếu dưới 5
(3, 30, 10), 
(4, 15, 5);
