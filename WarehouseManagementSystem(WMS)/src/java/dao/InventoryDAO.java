package dao;

import config.DBConfig;
import model.Inventory;
import model.Product;
import model.ProductLine;
import model.Brand;
import model.InventoryHistory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventoryDAO {

    public List<Inventory> getAll() throws SQLException {
        List<Inventory> list = new ArrayList<>();
        String sql = "SELECT i.*, p.sku, p.name as product_name, p.unit, p.price, p.image_url, " +
                     "pl.id as product_line_id, pl.name as product_line_name, " +
                     "b.id as brand_id, b.name as brand_name " +
                     "FROM inventories i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id " +
                     "ORDER BY p.name ASC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapInventory(rs));
            }
        }
        return list;
    }

    public Inventory getByProductId(long productId) throws SQLException {
        String sql = "SELECT i.*, p.sku, p.name as product_name, p.unit, p.price, p.image_url, " +
                     "pl.id as product_line_id, pl.name as product_line_name, " +
                     "b.id as brand_id, b.name as brand_name " +
                     "FROM inventories i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id " +
                     "WHERE i.product_id = ? " +
                     "LIMIT 1";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapInventory(rs);
                }
            }
        }
        return null;
    }

    public Inventory getById(long id) throws SQLException {
        String sql = "SELECT i.*, p.sku, p.name as product_name, p.unit, p.price, p.image_url, " +
                     "pl.id as product_line_id, pl.name as product_line_name, " +
                     "b.id as brand_id, b.name as brand_name " +
                     "FROM inventories i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id " +
                     "WHERE i.id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapInventory(rs);
                }
            }
        }
        return null;
    }



    public void insert(Inventory inventory) throws SQLException {
        String sql = "INSERT INTO inventories (product_id, batch_code, barcode, quantity_in_stock, min_stock_level) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, inventory.getProductId());
            ps.setString(2, inventory.getBatchCode() == null ? "" : inventory.getBatchCode());
            ps.setString(3, inventory.getBarcode() == null ? "" : inventory.getBarcode());
            ps.setInt(4, inventory.getQuantityInStock());
            ps.setInt(5, inventory.getMinStockLevel());
            ps.executeUpdate();
        }
    }

    public void update(Inventory inventory) throws SQLException {
        String sql = "UPDATE inventories SET batch_code = ?, barcode = ?, quantity_in_stock = ?, min_stock_level = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, inventory.getBatchCode() == null ? "" : inventory.getBatchCode());
            ps.setString(2, inventory.getBarcode() == null ? "" : inventory.getBarcode());
            ps.setInt(3, inventory.getQuantityInStock());
            ps.setInt(4, inventory.getMinStockLevel());
            ps.setLong(5, inventory.getId());
            ps.executeUpdate();
        }
    }

    private Inventory mapInventory(ResultSet rs) throws SQLException {
        Inventory i = new Inventory();
        i.setId(rs.getLong("id"));
        i.setProductId(rs.getLong("product_id"));
        i.setBatchCode(rs.getString("batch_code"));
        i.setBarcode(rs.getString("barcode"));
        i.setQuantityInStock(rs.getInt("quantity_in_stock"));
        i.setMinStockLevel(rs.getInt("min_stock_level"));
        i.setLastUpdated(rs.getTimestamp("last_updated"));

        // Map Product
        Product p = new Product();
        p.setId(rs.getLong("product_id"));
        p.setSku(rs.getString("sku"));
        p.setName(rs.getString("product_name"));
        p.setUnit(rs.getString("unit"));
        p.setPrice(rs.getDouble("price"));
        p.setImageUrl(rs.getString("image_url"));
        
        ProductLine pl = new ProductLine();
        pl.setId(rs.getLong("product_line_id"));
        pl.setName(rs.getString("product_line_name"));
        
        Brand b = new Brand();
        b.setId(rs.getLong("brand_id"));
        b.setName(rs.getString("brand_name"));
        pl.setBrand(b);
        
        p.setProductLine(pl);
        
        i.setProduct(p);

        return i;
    }

    private Inventory mapGroupedInventory(ResultSet rs) throws SQLException {
        Inventory i = new Inventory();
        i.setId(rs.getLong("id"));
        i.setProductId(rs.getLong("product_id"));
        i.setBatchCode(rs.getString("batch_code"));
        
        String minBarcode = rs.getString("min_barcode");
        String maxBarcode = rs.getString("max_barcode");
        int count = rs.getInt("barcode_count");
        if (count > 1 && minBarcode != null && maxBarcode != null && !minBarcode.equals(maxBarcode)) {
            int lastDashMin = minBarcode.lastIndexOf("-");
            int lastDashMax = maxBarcode.lastIndexOf("-");
            if (lastDashMin != -1 && lastDashMax != -1) {
                String prefix = minBarcode.substring(0, lastDashMin);
                String suffixMin = minBarcode.substring(lastDashMin + 1);
                String suffixMax = maxBarcode.substring(lastDashMax + 1);
                try {
                    Integer.parseInt(suffixMin);
                    Integer.parseInt(suffixMax);
                    i.setBarcode(prefix + "-[" + suffixMin + "~" + suffixMax + "]");
                } catch (NumberFormatException e) {
                    i.setBarcode(minBarcode + " ~ " + maxBarcode);
                }
            } else {
                i.setBarcode(minBarcode + " ~ " + maxBarcode);
            }
        } else {
            i.setBarcode(minBarcode);
        }
        
        i.setQuantityInStock(rs.getInt("quantity_in_stock"));
        i.setMinStockLevel(rs.getInt("min_stock_level"));
        i.setLastUpdated(rs.getTimestamp("last_updated"));

        // Map Product
        Product p = new Product();
        p.setId(rs.getLong("product_id"));
        p.setSku(rs.getString("sku"));
        p.setName(rs.getString("product_name"));
        p.setUnit(rs.getString("unit"));
        p.setPrice(rs.getDouble("price"));
        p.setImageUrl(rs.getString("image_url"));
        
        ProductLine pl = new ProductLine();
        pl.setId(rs.getLong("product_line_id"));
        pl.setName(rs.getString("product_line_name"));
        
        Brand b = new Brand();
        b.setId(rs.getLong("brand_id"));
        b.setName(rs.getString("brand_name"));
        pl.setBrand(b);
        
        p.setProductLine(pl);
        
        i.setProduct(p);

        return i;
    }

    public List<Inventory> findPaginated(int page, int limit, String sku, Long brandId, Long productLineId) throws SQLException {
        return findPaginated(page, limit, sku, brandId, productLineId, null, null);
    }

    public List<Inventory> findPaginated(int page, int limit, String sku, Long brandId, Long productLineId, String batchCode, String barcode) throws SQLException {
        List<Inventory> list = new ArrayList<>();
        int offset = (page - 1) * limit;
        String sql = "SELECT MIN(i.id) as id, i.product_id, i.batch_code, " +
                     "MIN(i.barcode) as min_barcode, " +
                     "CASE WHEN MIN(i.barcode) LIKE '%-%-%-%' THEN CONCAT(SUBSTRING_INDEX(MIN(i.barcode), '-', 3), '-', MAX(CAST(SUBSTRING_INDEX(i.barcode, '-', -1) AS UNSIGNED))) ELSE MAX(i.barcode) END as max_barcode, " +
                     "COUNT(i.barcode) as barcode_count, " +
                     "SUM(i.quantity_in_stock) as quantity_in_stock, MAX(i.min_stock_level) as min_stock_level, " +
                     "MAX(i.last_updated) as last_updated, " +
                     "p.sku, p.name as product_name, p.unit, p.price, p.image_url, " +
                     "pl.id as product_line_id, pl.name as product_line_name, " +
                     "b.id as brand_id, b.name as brand_name " +
                     "FROM inventories i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id " +
                     "WHERE 1=1 " +
                     "AND NOT (i.batch_code = '' AND i.quantity_in_stock = 0 AND EXISTS (SELECT 1 FROM inventories i2 WHERE i2.product_id = i.product_id AND i2.batch_code <> '')) ";
        
        if (sku != null && !sku.trim().isEmpty()) {
            sql += "AND p.sku LIKE ? ";
        }
        if (brandId != null) {
            sql += "AND pl.brand_id = ? ";
        }
        if (productLineId != null) {
            sql += "AND p.product_line_id = ? ";
        }
        if (batchCode != null && !batchCode.trim().isEmpty()) {
            sql += "AND i.batch_code LIKE ? ";
        }
        if (barcode != null && !barcode.trim().isEmpty()) {
            sql += "AND i.barcode LIKE ? ";
        }
        
        sql += "GROUP BY i.product_id, i.batch_code ORDER BY p.name ASC LIMIT ? OFFSET ?";
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int paramIndex = 1;
            if (sku != null && !sku.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + sku.trim() + "%");
            }
            if (brandId != null) {
                ps.setLong(paramIndex++, brandId);
            }
            if (productLineId != null) {
                ps.setLong(paramIndex++, productLineId);
            }
            if (batchCode != null && !batchCode.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + batchCode.trim() + "%");
            }
            if (barcode != null && !barcode.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + barcode.trim() + "%");
            }
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapGroupedInventory(rs));
                }
            }
        }
        return list;
    }

    public int count(String sku, Long brandId, Long productLineId) throws SQLException {
        return count(sku, brandId, productLineId, null, null);
    }

    public int count(String sku, Long brandId, Long productLineId, String batchCode, String barcode) throws SQLException {
        String sql = "SELECT COUNT(DISTINCT i.product_id, i.batch_code) " +
                     "FROM inventories i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id " +
                     "WHERE 1=1 " +
                     "AND NOT (i.batch_code = '' AND i.quantity_in_stock = 0 AND EXISTS (SELECT 1 FROM inventories i2 WHERE i2.product_id = i.product_id AND i2.batch_code <> '')) ";
        
        if (sku != null && !sku.trim().isEmpty()) {
            sql += "AND p.sku LIKE ? ";
        }
        if (brandId != null) {
            sql += "AND pl.brand_id = ? ";
        }
        if (productLineId != null) {
            sql += "AND p.product_line_id = ? ";
        }
        if (batchCode != null && !batchCode.trim().isEmpty()) {
            sql += "AND i.batch_code LIKE ? ";
        }
        if (barcode != null && !barcode.trim().isEmpty()) {
            sql += "AND i.barcode LIKE ? ";
        }
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int paramIndex = 1;
            if (sku != null && !sku.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + sku.trim() + "%");
            }
            if (brandId != null) {
                ps.setLong(paramIndex++, brandId);
            }
            if (productLineId != null) {
                ps.setLong(paramIndex++, productLineId);
            }
            if (batchCode != null && !batchCode.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + batchCode.trim() + "%");
            }
            if (barcode != null && !barcode.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + barcode.trim() + "%");
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public int getQuantityByProductAndBatch(long productId, String batchCode) throws SQLException {
        String sql = "SELECT SUM(quantity_in_stock) FROM inventories WHERE product_id = ? AND batch_code = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.setString(2, batchCode == null ? "" : batchCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
     }

    public List<Inventory> getItemizedListByProductAndBatch(long productId, String batchCode) throws SQLException {
        List<Inventory> list = new ArrayList<>();
        String sql = "SELECT i.*, p.sku, p.name as product_name, p.unit, p.price, p.image_url, " +
                     "pl.id as product_line_id, pl.name as product_line_name, " +
                     "b.id as brand_id, b.name as brand_name " +
                     "FROM inventories i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id " +
                     "WHERE i.product_id = ? AND i.batch_code = ? " +
                     "ORDER BY i.barcode ASC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.setString(2, batchCode == null ? "" : batchCode);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapInventory(rs));
                }
            }
        }
        
        // Sắp xếp tự nhiên (natural sort) theo mã vạch
        list.sort((inv1, inv2) -> {
            String b1 = inv1.getBarcode();
            String b2 = inv2.getBarcode();
            if (b1 == null || b1.isEmpty()) return (b2 == null || b2.isEmpty()) ? 0 : 1;
            if (b2 == null || b2.isEmpty()) return -1;
            
            String[] parts1 = b1.split("-");
            String[] parts2 = b2.split("-");
            int minLen = Math.min(parts1.length, parts2.length);
            for (int i = 0; i < minLen; i++) {
                String p1 = parts1[i];
                String p2 = parts2[i];
                if (!p1.equals(p2)) {
                    try {
                        int num1 = Integer.parseInt(p1);
                        int num2 = Integer.parseInt(p2);
                        return Integer.compare(num1, num2);
                    } catch (NumberFormatException e) {
                        return p1.compareTo(p2);
                    }
                }
            }
            return Integer.compare(parts1.length, parts2.length);
        });
        
        return list;
    }

    public List<InventoryHistory> getUpdateHistoryByProductId(long productId) throws SQLException {
        List<InventoryHistory> historyList = new ArrayList<>();
        String sql = "SELECT " +
                     "    'IMPORT' as transaction_type, " +
                     "    r.id as transaction_id, " +
                     "    r.receipt_code as transaction_code, " +
                     "    r.created_at as transaction_date, " +
                     "    rd.quantity as quantity, " +
                     "    s.name as partner_name, " +
                     "    u.full_name as creator_name, " +
                     "    r.notes as notes " +
                     "FROM receipt_details rd " +
                     "INNER JOIN receipts r ON rd.receipt_id = r.id " +
                     "INNER JOIN suppliers s ON r.supplier_id = s.id " +
                     "INNER JOIN users u ON r.created_by = u.id " +
                     "WHERE rd.product_id = ? AND r.status = 'COMPLETED' " +
                     "UNION ALL " +
                     "SELECT " +
                     "    'EXPORT' as transaction_type, " +
                     "    sh.id as transaction_id, " +
                     "    sh.shipment_code as transaction_code, " +
                     "    sh.created_at as transaction_date, " +
                     "    sd.quantity as quantity, " +
                     "    sh.destination as partner_name, " +
                     "    u.full_name as creator_name, " +
                     "    sh.notes as notes " +
                     "FROM shipment_details sd " +
                     "INNER JOIN shipments sh ON sd.shipment_id = sh.id " +
                     "INNER JOIN users u ON sh.created_by = u.id " +
                     "WHERE sd.product_id = ? AND sh.status = 'COMPLETED' " +
                     "ORDER BY transaction_date DESC";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productId);
            ps.setLong(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InventoryHistory h = new InventoryHistory();
                    h.setTransactionType(rs.getString("transaction_type"));
                    h.setTransactionId(rs.getLong("transaction_id"));
                    h.setTransactionCode(rs.getString("transaction_code"));
                    h.setTransactionDate(rs.getTimestamp("transaction_date"));
                    h.setQuantity(rs.getInt("quantity"));
                    h.setPartnerName(rs.getString("partner_name"));
                    h.setCreatorName(rs.getString("creator_name"));
                    h.setNotes(rs.getString("notes"));
                    historyList.add(h);
                }
            }
        }
        return historyList;
    }

    public void updateMinStockLevelForProductAndBatch(long productId, String batchCode, int minStockLevel) throws SQLException {
        String sql = "UPDATE inventories SET min_stock_level = ? WHERE product_id = ? AND batch_code = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, minStockLevel);
            ps.setLong(2, productId);
            ps.setString(3, batchCode == null ? "" : batchCode);
            ps.executeUpdate();
        }
    }
}
