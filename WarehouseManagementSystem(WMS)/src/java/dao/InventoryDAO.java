package dao;

import config.DBConfig;
import model.Inventory;
import model.Product;
import model.ProductLine;
import model.Brand;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventoryDAO {

    public List<Inventory> getAll() throws SQLException {
        List<Inventory> list = new ArrayList<>();
        String sql = "SELECT i.*, p.sku, p.name as product_name, p.unit, p.price, " +
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
        String sql = "SELECT i.*, p.sku, p.name as product_name, p.unit, p.price, " +
                     "pl.id as product_line_id, pl.name as product_line_name, " +
                     "b.id as brand_id, b.name as brand_name " +
                     "FROM inventories i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id " +
                     "WHERE i.product_id = ?";
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

    public void insert(Inventory inventory) throws SQLException {
        String sql = "INSERT INTO inventories (product_id, quantity_in_stock, min_stock_level) VALUES (?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, inventory.getProductId());
            ps.setInt(2, inventory.getQuantityInStock());
            ps.setInt(3, inventory.getMinStockLevel());
            ps.executeUpdate();
        }
    }

    public void update(Inventory inventory) throws SQLException {
        String sql = "UPDATE inventories SET quantity_in_stock = ?, min_stock_level = ? WHERE product_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, inventory.getQuantityInStock());
            ps.setInt(2, inventory.getMinStockLevel());
            ps.setLong(3, inventory.getProductId());
            ps.executeUpdate();
        }
    }

    private Inventory mapInventory(ResultSet rs) throws SQLException {
        Inventory i = new Inventory();
        i.setProductId(rs.getLong("product_id"));
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
        List<Inventory> list = new ArrayList<>();
        int offset = (page - 1) * limit;
        String sql = "SELECT i.*, p.sku, p.name as product_name, p.unit, p.price, " +
                     "pl.id as product_line_id, pl.name as product_line_name, " +
                     "b.id as brand_id, b.name as brand_name " +
                     "FROM inventories i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id WHERE 1=1 ";
        
        if (sku != null && !sku.trim().isEmpty()) {
            sql += "AND p.sku LIKE ? ";
        }
        if (brandId != null) {
            sql += "AND pl.brand_id = ? ";
        }
        if (productLineId != null) {
            sql += "AND p.product_line_id = ? ";
        }
        
        sql += "ORDER BY p.name ASC LIMIT ? OFFSET ?";
        
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
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapInventory(rs));
                }
            }
        }
        return list;
    }

    public int count(String sku, Long brandId, Long productLineId) throws SQLException {
        String sql = "SELECT COUNT(*) " +
                     "FROM inventories i " +
                     "INNER JOIN products p ON i.product_id = p.id " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id WHERE 1=1 ";
        
        if (sku != null && !sku.trim().isEmpty()) {
            sql += "AND p.sku LIKE ? ";
        }
        if (brandId != null) {
            sql += "AND pl.brand_id = ? ";
        }
        if (productLineId != null) {
            sql += "AND p.product_line_id = ? ";
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
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
}
