package dao;

import config.DBConfig;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PermissionDAO {

    public List<String[]> findAll() throws SQLException {
        String sql = "SELECT id, code, name FROM permissions ORDER BY code";
        List<String[]> rows = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(new String[] {
                    String.valueOf(rs.getLong("id")),
                    rs.getString("code"),
                    rs.getString("name")
                });
            }
        }
        return rows;
    }

    public boolean existsByCode(String code) throws SQLException {
        String sql = "SELECT 1 FROM permissions WHERE code = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long ensurePermission(String code, String name) throws SQLException {
        if (existsByCode(code)) {
            return findIdByCode(code);
        }
        String sql = "INSERT INTO permissions (code, name) VALUES (?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, code);
            ps.setString(2, name);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        throw new SQLException("Insert permission failed");
    }

    public long findIdByCode(String code) throws SQLException {
        String sql = "SELECT id FROM permissions WHERE code = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        throw new SQLException("Permission not found: " + code);
    }

    public long ensureRole(String code, String name) throws SQLException {
        String sql = "SELECT id FROM roles WHERE code = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    long id = rs.getLong(1);
                    try (PreparedStatement upd = conn.prepareStatement("UPDATE roles SET name = ? WHERE id = ?")) {
                        upd.setString(1, name);
                        upd.setLong(2, id);
                        upd.executeUpdate();
                    }
                    return id;
                }
            }
        }
        String insert = "INSERT INTO roles (code, name, enabled) VALUES (?, ?, true)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, code);
            ps.setString(2, name);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
        }
        throw new SQLException("Insert role failed");
    }

    public void linkRolePermission(long roleId, long permissionId) throws SQLException {
        String sql = """
            INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES (?, ?)
            """;
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, roleId);
            ps.setLong(2, permissionId);
            ps.executeUpdate();
        }
    }

    public void linkUserRole(long userId, long roleId) throws SQLException {
        String sql = """
            INSERT IGNORE INTO user_roles (user_id, role_id) VALUES (?, ?)
            """;
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, roleId);
            ps.executeUpdate();
        }
    }
}
