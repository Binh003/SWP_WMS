package dao;

import config.DBConfig;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class PasswordResetDAO {

    public void createToken(long userId, String token, Timestamp expiryTime) throws SQLException {
        // First invalidate any existing unused tokens for this user
        String invalidateSql = "UPDATE password_resets SET used = 1 WHERE user_id = ? AND used = 0";
        String insertSql = """
            INSERT INTO password_resets (user_id, token, expiry_time, used)
            VALUES (?, ?, ?, 0)
            """;
        try (Connection conn = DBConfig.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(invalidateSql)) {
                    ps.setLong(1, userId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setLong(1, userId);
                    ps.setString(2, token);
                    ps.setTimestamp(3, expiryTime);
                    ps.executeUpdate();
                }
                conn.commit();
            } catch (SQLException ex) {
                conn.rollback();
                throw ex;
            }
        }
    }

    public Long getUserIdByValidToken(String token) throws SQLException {
        String sql = """
            SELECT user_id FROM password_resets
            WHERE token = ? AND used = 0 AND expiry_time > CURRENT_TIMESTAMP
            """;
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong("user_id");
                }
            }
        }
        return null;
    }

    public void markTokenAsUsed(String token) throws SQLException {
        String sql = "UPDATE password_resets SET used = 1 WHERE token = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        }
    }
}
