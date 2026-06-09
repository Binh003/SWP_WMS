package dao;

import config.DBConfig;
import model.Product;
import model.ProductLine;
import model.Brand;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public List<Product> getAll() throws SQLException {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, pl.name as product_line_name, pl.code as product_line_code, " +
                     "b.id as brand_id, b.name as brand_name, b.code as brand_code " +
                     "FROM products p " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id " +
                     "ORDER BY p.name ASC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        }
        return list;
    }

    public Product getById(long id) throws SQLException {
        String sql = "SELECT p.*, pl.name as product_line_name, pl.code as product_line_code, " +
                     "b.id as brand_id, b.name as brand_name, b.code as brand_code " +
                     "FROM products p " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id " +
                     "WHERE p.id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProduct(rs);
                }
            }
        }
        return null;
    }

    public Product getBySku(String sku) throws SQLException {
        String sql = "SELECT p.*, pl.name as product_line_name, pl.code as product_line_code, " +
                     "b.id as brand_id, b.name as brand_name, b.code as brand_code " +
                     "FROM products p " +
                     "INNER JOIN product_lines pl ON p.product_line_id = pl.id " +
                     "INNER JOIN brands b ON pl.brand_id = b.id " +
                     "WHERE p.sku = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sku);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProduct(rs);
                }
            }
        }
        return null;
    }

    public void insert(Product product) throws SQLException {
        String sql = "INSERT INTO products (product_line_id, sku, name, unit, price, description) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, product.getProductLineId());
            ps.setString(2, product.getSku());
            ps.setString(3, product.getName());
            ps.setString(4, product.getUnit());
            if (product.getPrice() != null) {
                ps.setDouble(5, product.getPrice());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }
            ps.setString(6, product.getDescription());
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    product.setId(rs.getLong(1));
                }
            }
        }
    }

    public void update(Product product) throws SQLException {
        String sql = "UPDATE products SET product_line_id = ?, sku = ?, name = ?, unit = ?, price = ?, description = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, product.getProductLineId());
            ps.setString(2, product.getSku());
            ps.setString(3, product.getName());
            ps.setString(4, product.getUnit());
            if (product.getPrice() != null) {
                ps.setDouble(5, product.getPrice());
            } else {
                ps.setNull(5, Types.DECIMAL);
            }
            ps.setString(6, product.getDescription());
            ps.setLong(7, product.getId());
            ps.executeUpdate();
        }
    }

    public void delete(long id) throws SQLException {
        String sql = "DELETE FROM products WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getLong("id"));
        p.setProductLineId(rs.getLong("product_line_id"));
        p.setSku(rs.getString("sku"));
        p.setName(rs.getString("name"));
        p.setUnit(rs.getString("unit"));
        p.setPrice(rs.getDouble("price"));
        p.setDescription(rs.getString("description"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));

        // Map ProductLine
        ProductLine pl = new ProductLine();
        pl.setId(rs.getLong("product_line_id"));
        pl.setCode(rs.getString("product_line_code"));
        pl.setName(rs.getString("product_line_name"));
        
        // Map Brand for ProductLine
        Brand brand = new Brand();
        brand.setId(rs.getLong("brand_id"));
        brand.setCode(rs.getString("brand_code"));
        brand.setName(rs.getString("brand_name"));
        pl.setBrand(brand);
        
        p.setProductLine(pl);

        return p;
    }
}
