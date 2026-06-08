package listener;

import config.DBConfig;
import dao.PermissionDAO;
import dao.UserDAO;
import model.Role;
import model.User;
import util.PasswordUtil;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.sql.SQLException;
import java.util.List;

@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            seedRbac();
        } catch (SQLException ex) {
            sce.getServletContext().log("RBAC seed failed: " + ex.getMessage(), ex);
        }
    }

    private void seedRbac() throws SQLException {
        try (java.sql.Connection conn = config.DBConfig.getConnection();
             java.sql.Statement stmt = conn.createStatement()) {
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS password_resets (
                  id BIGINT AUTO_INCREMENT PRIMARY KEY,
                  user_id BIGINT NOT NULL,
                  token VARCHAR(255) NOT NULL,
                  expiry_time TIMESTAMP NOT NULL,
                  used BIT(1) NOT NULL DEFAULT 0,
                  CONSTRAINT fk_password_resets_user FOREIGN KEY (user_id) REFERENCES users(id)
                )
            """);
            try {
                stmt.execute("SELECT status FROM users LIMIT 1");
            } catch (SQLException e) {
                stmt.execute("ALTER TABLE users ADD COLUMN status VARCHAR(50) NOT NULL DEFAULT 'PENDING'");
                stmt.execute("UPDATE users SET status = 'ACTIVE' WHERE enabled = 1");
                stmt.execute("UPDATE users SET status = 'LOCKED' WHERE enabled = 0");
            }
        }

        PermissionDAO permissionDAO = new PermissionDAO();
        UserDAO userDAO = new UserDAO();

        long userRead = permissionDAO.ensurePermission("USER_READ", "Xem người dùng");
        long userWrite = permissionDAO.ensurePermission("USER_WRITE", "Quản lý người dùng");
        long roleRead = permissionDAO.ensurePermission("ROLE_READ", "Xem vai trò");
        long roleWrite = permissionDAO.ensurePermission("ROLE_WRITE", "Quản lý vai trò");
        long permRead = permissionDAO.ensurePermission("PERMISSION_READ", "Xem quyền");

        // Phase 2 (Master Data) Permissions
        long brandRead = permissionDAO.ensurePermission("BRAND_READ", "Xem danh sách Hãng");
        long brandWrite = permissionDAO.ensurePermission("BRAND_WRITE", "Thêm/Sửa/Xóa Hãng");
        long supplierRead = permissionDAO.ensurePermission("SUPPLIER_READ", "Xem danh sách Nhà cung cấp");
        long supplierWrite = permissionDAO.ensurePermission("SUPPLIER_WRITE", "Thêm/Sửa/Xóa Nhà cung cấp");
        long prodLineRead = permissionDAO.ensurePermission("PRODUCT_LINE_READ", "Xem danh sách Dòng sản phẩm");
        long prodLineWrite = permissionDAO.ensurePermission("PRODUCT_LINE_WRITE", "Thêm/Sửa/Xóa Dòng sản phẩm");

        long adminRoleId = permissionDAO.ensureRole("ADMIN", "Administrator");
        permissionDAO.linkRolePermission(adminRoleId, userRead);
        permissionDAO.linkRolePermission(adminRoleId, userWrite);
        permissionDAO.linkRolePermission(adminRoleId, roleRead);
        permissionDAO.linkRolePermission(adminRoleId, roleWrite);
        permissionDAO.linkRolePermission(adminRoleId, permRead);
        
        // Link Phase 2 Permissions to ADMIN
        permissionDAO.linkRolePermission(adminRoleId, brandRead);
        permissionDAO.linkRolePermission(adminRoleId, brandWrite);
        permissionDAO.linkRolePermission(adminRoleId, supplierRead);
        permissionDAO.linkRolePermission(adminRoleId, supplierWrite);
        permissionDAO.linkRolePermission(adminRoleId, prodLineRead);
        permissionDAO.linkRolePermission(adminRoleId, prodLineWrite);

        long warehouseRoleId = permissionDAO.ensureRole("WAREHOUSE STAFF", "Warehouse Staff");
        // Warehouse Staff only needs READ access for master data
        permissionDAO.linkRolePermission(warehouseRoleId, brandRead);
        permissionDAO.linkRolePermission(warehouseRoleId, supplierRead);
        permissionDAO.linkRolePermission(warehouseRoleId, prodLineRead);

        long viewerRoleId = permissionDAO.ensureRole("VIEWER", "Viewer");
        // Viewer only needs READ access for master data
        permissionDAO.linkRolePermission(viewerRoleId, brandRead);
        permissionDAO.linkRolePermission(viewerRoleId, supplierRead);
        permissionDAO.linkRolePermission(viewerRoleId, prodLineRead);

        String adminUsername = DBConfig.get("admin.username");
        if (userDAO.findByUsername(adminUsername) == null) {
            User admin = new User();
            admin.setUsername(adminUsername);
            admin.setFullName("Administrator");
            admin.setEmail("admin@inventory.local");
            admin.setPasswordHash(PasswordUtil.hash(DBConfig.get("admin.password")));
            admin.setEnabled(true);
            Role adminRole = new Role();
            adminRole.setId(adminRoleId);
            adminRole.setCode("ADMIN");
            admin.getRoles().add(adminRole);
            userDAO.insert(admin);
        } else {
            User admin = userDAO.findByUsername(adminUsername);
            if (admin != null && !admin.hasRole("ADMIN")) {
                Role adminRole = new Role();
                adminRole.setId(adminRoleId);
                adminRole.setCode("ADMIN");
                admin.getRoles().add(adminRole);
                userDAO.replaceRoles(admin.getId(), admin.getRoles());
            }
        }
    }
}
