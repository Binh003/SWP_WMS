package dao;

import config.DBConfig;
import model.Brand;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BrandDAO {
    public List<Brand> getAll() throws SQLException {
        List<Brand> list = new ArrayList<>();
        String sql = "SELECT id, code, name, description, created_at, updated_at FROM brands ORDER BY name ASC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapBrand(rs));
            }
        }
        return list;
    }

    public Brand getById(long id) throws SQLException {
        String sql = "SELECT id, code, name, description, created_at, updated_at FROM brands WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapBrand(rs);
                }
            }
        }
        return null;
    }

    public void insert(Brand brand) throws SQLException {
        String sql = "INSERT INTO brands (code, name, description) VALUES (?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, brand.getCode());
            ps.setString(2, brand.getName());
            ps.setString(3, brand.getDescription());
            ps.executeUpdate();
        }
    }

    public void update(Brand brand) throws SQLException {
        String sql = "UPDATE brands SET code = ?, name = ?, description = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, brand.getCode());
            ps.setString(2, brand.getName());
            ps.setString(3, brand.getDescription());
            ps.setLong(4, brand.getId());
            ps.executeUpdate();
        }
    }

    public void delete(long id) throws SQLException {
        String sql = "DELETE FROM brands WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    private Brand mapBrand(ResultSet rs) throws SQLException {
        Brand brand = new Brand();
        brand.setId(rs.getLong("id"));
        brand.setCode(rs.getString("code"));
        brand.setName(rs.getString("name"));
        brand.setDescription(rs.getString("description"));
        brand.setCreatedAt(rs.getTimestamp("created_at"));
        brand.setUpdatedAt(rs.getTimestamp("updated_at"));
        return brand;
    }
}
