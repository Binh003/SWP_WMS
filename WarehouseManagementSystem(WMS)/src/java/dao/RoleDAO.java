package dao;

import config.DBConfig;
import model.Role;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO {

    public List<Role> findAll() throws SQLException {
        String sql = "SELECT id, code, name, description, enabled FROM roles ORDER BY code";
        List<Role> roles = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role r = mapRole(rs);
                r.setPermissionCodes(findPermissionCodes(conn, r.getId()));
                roles.add(r);
            }
        }
        return roles;
    }

    public List<Role> findPaginated(String search, String status, int offset, int limit) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT DISTINCT r.id, r.code, r.name, r.description, r.enabled 
            FROM roles r
            LEFT JOIN role_permissions rp ON rp.role_id = r.id
            LEFT JOIN permissions p ON rp.permission_id = p.id
            WHERE 1=1
            """);
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(r.code) LIKE ? OR LOWER(r.name) LIKE ? OR LOWER(r.description) LIKE ? OR LOWER(p.code) LIKE ?)");
            String searchPattern = "%" + search.trim().toLowerCase() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        if (status != null && !status.trim().isEmpty()) {
            boolean enabled = "active".equalsIgnoreCase(status);
            sql.append(" AND r.enabled = ?");
            params.add(enabled);
        }
        sql.append(" ORDER BY r.code LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        List<Role> roles = new ArrayList<>();
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Role r = mapRole(rs);
                    r.setPermissionCodes(findPermissionCodes(conn, r.getId()));
                    roles.add(r);
                }
            }
        }
        return roles;
    }

    public int count(String search, String status) throws SQLException {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(DISTINCT r.id) 
            FROM roles r
            LEFT JOIN role_permissions rp ON rp.role_id = r.id
            LEFT JOIN permissions p ON rp.permission_id = p.id
            WHERE 1=1
            """);
        List<Object> params = new ArrayList<>();
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (LOWER(r.code) LIKE ? OR LOWER(r.name) LIKE ? OR LOWER(r.description) LIKE ? OR LOWER(p.code) LIKE ?)");
            String searchPattern = "%" + search.trim().toLowerCase() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        if (status != null && !status.trim().isEmpty()) {
            boolean enabled = "active".equalsIgnoreCase(status);
            sql.append(" AND r.enabled = ?");
            params.add(enabled);
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


    public Role findByCode(String code) throws SQLException {
        String sql = "SELECT id, code, name, description, enabled FROM roles WHERE code = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return mapRole(rs);
            }
        }
    }

    public Role findByIdWithPermissions(long id) throws SQLException {
        String sql = "SELECT id, code, name, description, enabled FROM roles WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Role role = mapRole(rs);
                role.setPermissionCodes(findPermissionCodes(conn, id));
                return role;
            }
        }
    }

    public void updateRole(long id, String name, String description) throws SQLException {
        String sql = "UPDATE roles SET name = ?, description = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setLong(3, id);
            ps.executeUpdate();
        }
    }

    public boolean existsByCode(String code) throws SQLException {
        String sql = "SELECT 1 FROM roles WHERE code = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long insertRole(Role role) throws SQLException {
        String sql = "INSERT INTO roles (code, name, description, enabled) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, role.getCode());
            ps.setString(2, role.getName());
            ps.setString(3, role.getDescription());
            ps.setBoolean(4, role.isEnabled());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        throw new SQLException("Insert role failed");
    }

    public void deleteRole(long id) throws SQLException {
        try (Connection conn = DBConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM user_roles WHERE role_id = ?")) {
                    ps.setLong(1, id);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM role_permissions WHERE role_id = ?")) {
                    ps.setLong(1, id);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM roles WHERE id = ?")) {
                    ps.setLong(1, id);
                    ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public void setEnabled(long id, boolean enabled) throws SQLException {
        String sql = "UPDATE roles SET enabled = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, enabled);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void replacePermissions(long roleId, List<String> permissionCodes) throws SQLException {
        try (Connection conn = DBConfig.getConnection()) {
            try (PreparedStatement del = conn.prepareStatement("DELETE FROM role_permissions WHERE role_id = ?")) {
                del.setLong(1, roleId);
                del.executeUpdate();
            }
            if (permissionCodes == null || permissionCodes.isEmpty()) {
                return;
            }
            String sql = """
                INSERT INTO role_permissions (role_id, permission_id)
                SELECT ?, p.id FROM permissions p WHERE p.code = ?
                """;
            try (PreparedStatement ins = conn.prepareStatement(sql)) {
                for (String code : permissionCodes) {
                    ins.setLong(1, roleId);
                    ins.setString(2, code);
                    ins.addBatch();
                }
                ins.executeBatch();
            }
        }
    }

    private List<String> findPermissionCodes(Connection conn, long roleId) throws SQLException {
        String sql = """
            SELECT p.code FROM permissions p
            INNER JOIN role_permissions rp ON rp.permission_id = p.id
            WHERE rp.role_id = ?
            ORDER BY p.code
            """;
        List<String> codes = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    codes.add(rs.getString("code"));
                }
            }
        }
        return codes;
    }

    public int countUsersWithRole(long roleId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM user_roles WHERE role_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
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
