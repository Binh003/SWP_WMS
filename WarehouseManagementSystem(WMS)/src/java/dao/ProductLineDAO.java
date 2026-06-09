package dao;

import config.DBConfig;
import model.Brand;
import model.ProductLine;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductLineDAO {

    public List<ProductLine> getAll() throws SQLException {
        List<ProductLine> list = new ArrayList<>();
        // Join with brands table to get brand name
        String sql = "SELECT p.*, b.name as brand_name, b.code as brand_code " +
                     "FROM product_lines p " +
                     "INNER JOIN brands b ON p.brand_id = b.id " +
                     "ORDER BY p.name ASC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapProductLineWithBrand(rs));
            }
        }
        return list;
    }

    public ProductLine getById(long id) throws SQLException {
        String sql = "SELECT p.*, b.name as brand_name, b.code as brand_code " +
                     "FROM product_lines p " +
                     "INNER JOIN brands b ON p.brand_id = b.id " +
                     "WHERE p.id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProductLineWithBrand(rs);
                }
            }
        }
        return null;
    }
    
    public List<ProductLine> getByBrandId(long brandId) throws SQLException {
        List<ProductLine> list = new ArrayList<>();
        String sql = "SELECT p.*, b.name as brand_name, b.code as brand_code " +
                     "FROM product_lines p " +
                     "INNER JOIN brands b ON p.brand_id = b.id " +
                     "WHERE p.brand_id = ? " +
                     "ORDER BY p.name ASC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, brandId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProductLineWithBrand(rs));
                }
            }
        }
        return list;
    }

    public void insert(ProductLine productLine) throws SQLException {
        String sql = "INSERT INTO product_lines (brand_id, code, name, description) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productLine.getBrandId());
            ps.setString(2, productLine.getCode());
            ps.setString(3, productLine.getName());
            ps.setString(4, productLine.getDescription());
            ps.executeUpdate();
        }
    }

    public void update(ProductLine productLine) throws SQLException {
        String sql = "UPDATE product_lines SET brand_id = ?, code = ?, name = ?, description = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, productLine.getBrandId());
            ps.setString(2, productLine.getCode());
            ps.setString(3, productLine.getName());
            ps.setString(4, productLine.getDescription());
            ps.setLong(5, productLine.getId());
            ps.executeUpdate();
        }
    }

    public void delete(long id) throws SQLException {
        String sql = "DELETE FROM product_lines WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    public List<ProductLine> findPaginated(String search, int offset, int limit) throws SQLException {
        List<ProductLine> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.*, b.name as brand_name, b.code as brand_code " +
            "FROM product_lines p " +
            "INNER JOIN brands b ON p.brand_id = b.id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(p.code) LIKE ? OR LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ? OR LOWER(b.name) LIKE ?)");
            String pattern = "%" + search.trim().toLowerCase() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        sql.append(" ORDER BY p.name ASC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapProductLineWithBrand(rs));
                }
            }
        }
        return list;
    }

    public int count(String search) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) " +
            "FROM product_lines p " +
            "INNER JOIN brands b ON p.brand_id = b.id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(p.code) LIKE ? OR LOWER(p.name) LIKE ? OR LOWER(p.description) LIKE ? OR LOWER(b.name) LIKE ?)");
            String pattern = "%" + search.trim().toLowerCase() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private ProductLine mapProductLineWithBrand(ResultSet rs) throws SQLException {
        ProductLine pl = new ProductLine();
        pl.setId(rs.getLong("id"));
        pl.setBrandId(rs.getLong("brand_id"));
        pl.setCode(rs.getString("code"));
        pl.setName(rs.getString("name"));
        pl.setDescription(rs.getString("description"));
        pl.setCreatedAt(rs.getTimestamp("created_at"));
        pl.setUpdatedAt(rs.getTimestamp("updated_at"));

        // Map Brand
        Brand brand = new Brand();
        brand.setId(rs.getLong("brand_id"));
        brand.setCode(rs.getString("brand_code"));
        brand.setName(rs.getString("brand_name"));
        pl.setBrand(brand);

        return pl;
    }
}
