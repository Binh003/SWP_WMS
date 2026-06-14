package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Ket noi MySQL kieu JDBC thong thuong (giong cach ket noi SQL Server trong mon hoc).
 * Sua cac hang so ben duoi tren NetBeans: Source Packages -> config -> DBConfig.java
 */
public final class DBConfig {

    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String URL =
        "jdbc:mysql://localhost:3306/sku_inventory_db"
            + "?useSSL=false&allowPublicKeyRetrieval=true&connectionTimeZone=Asia/Ho_Chi_Minh&forceConnectionTimeZoneToSession=true";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "123456";

    private static final String ADMIN_USERNAME = "admin";
    private static final String ADMIN_PASSWORD = "admin123";

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException ex) {
            throw new ExceptionInInitializerError(ex);
        }
    }

    private DBConfig() {}

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    public static String get(String key) {
        return switch (key) {
            case "admin.username" -> ADMIN_USERNAME;
            case "admin.password" -> ADMIN_PASSWORD;
            default -> throw new IllegalArgumentException("Unknown config key: " + key);
        };
    }
}
