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

    public List<Brand> findPaginated(String search, int offset, int limit) throws SQLException {
        List<Brand> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT id, code, name, description, created_at, updated_at FROM brands WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(code) LIKE ? OR LOWER(name) LIKE ? OR LOWER(description) LIKE ?)");
            String pattern = "%" + search.trim().toLowerCase() + "%";
            params.add(pattern);
            params.add(pattern);
            params.add(pattern);
        }
        sql.append(" ORDER BY name ASC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapBrand(rs));
                }
            }
        }
        return list;
    }

    public int count(String search) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM brands WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(code) LIKE ? OR LOWER(name) LIKE ? OR LOWER(description) LIKE ?)");
            String pattern = "%" + search.trim().toLowerCase() + "%";
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
