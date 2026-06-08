package dao;

import config.DBConfig;
import model.Role;
import model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public User findByUsernameAndEmail(String username, String email) throws SQLException {
        String sql = """
            SELECT id, username, full_name, email, password_hash, enabled, status
            FROM users WHERE username = ? AND LOWER(email) = LOWER(?)
            """;
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return mapUser(rs);
            }
        }
    }

    public User findByUsername(String username) throws SQLException {
        String sql = """
            SELECT id, username, full_name, email, password_hash, enabled, status
            FROM users WHERE username = ?
            """;
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                User user = mapUser(rs);
                user.setRoles(findRolesForUser(conn, user.getId()));
                return user;
            }
        }
    }

    public User findByEmail(String email) throws SQLException {
        String sql = """
            SELECT id, username, full_name, email, password_hash, enabled, status
            FROM users WHERE LOWER(email) = LOWER(?)
            """;
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                User user = mapUser(rs);
                user.setRoles(findRolesForUser(conn, user.getId()));
                return user;
            }
        }
    }

    public User findById(long id) throws SQLException {
        String sql = """
            SELECT id, username, full_name, email, password_hash, enabled, status
            FROM users WHERE id = ?
            """;
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                User user = mapUser(rs);
                user.setRoles(findRolesForUser(conn, user.getId()));
                return user;
            }
        }
    }

    public List<User> findAll() throws SQLException {
        String sql = """
            SELECT id, username, full_name, email, password_hash, enabled, status
            FROM users ORDER BY id
            """;
        List<User> users = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User user = mapUser(rs);
                user.setRoles(findRolesForUser(conn, user.getId()));
                users.add(user);
            }
        }
        return users;
    }

    public boolean existsByUsername(String username) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE username = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long insert(User user) throws SQLException {
        String sql = """
            INSERT INTO users (username, full_name, email, password_hash, enabled, status)
            VALUES (?, ?, ?, ?, ?, ?)
            """;
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPasswordHash());
            ps.setBoolean(5, user.isEnabled());
            ps.setString(6, user.getStatus());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    long id = keys.getLong(1);
                    replaceRoles(conn, id, user.getRoles());
                    return id;
                }
            }
        }
        throw new SQLException("Insert user failed");
    }

    public void updateProfile(long userId, String fullName, String email) throws SQLException {
        String sql = "UPDATE users SET full_name = ?, email = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setLong(3, userId);
            ps.executeUpdate();
        }
    }

    public void updatePassword(long userId, String passwordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public void setEnabled(long userId, boolean enabled) throws SQLException {
        String sql = "UPDATE users SET enabled = ?, status = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, enabled);
            ps.setString(2, enabled ? "ACTIVE" : "LOCKED");
            ps.setLong(3, userId);
            ps.executeUpdate();
        }
    }

    public void setStatus(long userId, String status) throws SQLException {
        String sql = "UPDATE users SET status = ?, enabled = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setBoolean(2, "ACTIVE".equalsIgnoreCase(status));
            ps.setLong(3, userId);
            ps.executeUpdate();
        }
    }

    public void replaceRoles(long userId, List<Role> roles) throws SQLException {
        try (Connection conn = DBConfig.getConnection()) {
            replaceRoles(conn, userId, roles);
        }
    }

    private void replaceRoles(Connection conn, long userId, List<Role> roles) throws SQLException {
        try (PreparedStatement del = conn.prepareStatement("DELETE FROM user_roles WHERE user_id = ?")) {
            del.setLong(1, userId);
            del.executeUpdate();
        }
        if (roles == null || roles.isEmpty()) {
            return;
        }
        String sql = "INSERT INTO user_roles (user_id, role_id) VALUES (?, ?)";
        try (PreparedStatement ins = conn.prepareStatement(sql)) {
            for (Role role : roles) {
                ins.setLong(1, userId);
                ins.setLong(2, role.getId());
                ins.addBatch();
            }
            ins.executeBatch();
        }
    }

    private List<Role> findRolesForUser(Connection conn, long userId) throws SQLException {
        String sql = """
            SELECT r.id, r.code, r.name, r.description, r.enabled
            FROM roles r
            INNER JOIN user_roles ur ON ur.role_id = r.id
            WHERE ur.user_id = ?
            ORDER BY r.code
            """;
        List<Role> roles = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Role role = mapRole(rs);
                    role.setPermissionCodes(findPermissionsForRole(conn, role.getId()));
                    roles.add(role);
                }
            }
        }
        return roles;
    }

    private List<String> findPermissionsForRole(Connection conn, long roleId) throws SQLException {
        String sql = """
            SELECT p.code 
            FROM permissions p
            INNER JOIN role_permissions rp ON rp.permission_id = p.id
            WHERE rp.role_id = ?
            """;
        List<String> perms = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    perms.add(rs.getString("code"));
                }
            }
        }
        return perms;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getLong("id"));
        user.setUsername(rs.getString("username"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setEnabled(rs.getBoolean("enabled"));
        user.setStatus(rs.getString("status"));
        return user;
    }

    private Role mapRole(ResultSet rs) throws SQLException {
        Role role = new Role();
        role.setId(rs.getLong("id"));
        role.setCode(rs.getString("code"));
        role.setName(rs.getString("name"));
        role.setDescription(rs.getString("description"));
        role.setEnabled(rs.getBoolean("enabled"));
        return role;
    }
}
