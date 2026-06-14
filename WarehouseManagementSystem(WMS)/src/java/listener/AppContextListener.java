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
        java.util.TimeZone.setDefault(java.util.TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
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
            stmt.execute("""
                CREATE TABLE IF NOT EXISTS receipt_history (
                  id BIGINT AUTO_INCREMENT PRIMARY KEY,
                  receipt_id BIGINT NOT NULL,
                  from_status VARCHAR(50),
                  to_status VARCHAR(50) NOT NULL,
                  changed_by BIGINT NOT NULL,
                  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                  notes TEXT,
                  CONSTRAINT fk_rh_receipt FOREIGN KEY (receipt_id) REFERENCES receipts(id) ON DELETE CASCADE,
                  CONSTRAINT fk_rh_user FOREIGN KEY (changed_by) REFERENCES users(id)
                )
            """);
            try {
                stmt.execute("SELECT status FROM users LIMIT 1");
            } catch (SQLException e) {
                stmt.execute("ALTER TABLE users ADD COLUMN status VARCHAR(50) NOT NULL DEFAULT 'PENDING'");
                stmt.execute("UPDATE users SET status = 'ACTIVE' WHERE enabled = 1");
                stmt.execute("UPDATE users SET status = 'LOCKED' WHERE enabled = 0");
            }
            try {
                stmt.execute("SELECT invoice_image FROM receipts LIMIT 1");
            } catch (SQLException e) {
                stmt.execute("ALTER TABLE receipts ADD COLUMN invoice_image VARCHAR(255) NULL");
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

        // Phase 3 & 4 Permissions
        long productRead = permissionDAO.ensurePermission("PRODUCT_READ", "Xem Sản phẩm");
        long productWrite = permissionDAO.ensurePermission("PRODUCT_WRITE", "Quản lý Sản phẩm");
        long inventoryRead = permissionDAO.ensurePermission("INVENTORY_READ", "Xem Tồn kho");
        long inventoryWrite = permissionDAO.ensurePermission("INVENTORY_WRITE", "Quản lý Tồn kho");
        long receiptRead = permissionDAO.ensurePermission("RECEIPT_READ", "Xem Phiếu Nhập");
        long receiptWrite = permissionDAO.ensurePermission("RECEIPT_WRITE", "Tạo Phiếu Nhập");
        long shipmentRead = permissionDAO.ensurePermission("SHIPMENT_READ", "Xem Phiếu Xuất");
        long shipmentWrite = permissionDAO.ensurePermission("SHIPMENT_WRITE", "Tạo Phiếu Xuất");
        long reportRead = permissionDAO.ensurePermission("REPORT_READ", "Xem Báo cáo");

        // 1. ADMIN
        long adminRoleId = permissionDAO.ensureRole("ADMIN", "Administrator");
        permissionDAO.linkRolePermission(adminRoleId, userRead);
        permissionDAO.linkRolePermission(adminRoleId, userWrite);
        permissionDAO.linkRolePermission(adminRoleId, roleRead);
        permissionDAO.linkRolePermission(adminRoleId, roleWrite);
        permissionDAO.linkRolePermission(adminRoleId, permRead);
        permissionDAO.linkRolePermission(adminRoleId, brandRead);
        permissionDAO.linkRolePermission(adminRoleId, brandWrite);
        permissionDAO.linkRolePermission(adminRoleId, supplierRead);
        permissionDAO.linkRolePermission(adminRoleId, supplierWrite);
        permissionDAO.linkRolePermission(adminRoleId, prodLineRead);
        permissionDAO.linkRolePermission(adminRoleId, prodLineWrite);
        permissionDAO.linkRolePermission(adminRoleId, productRead);
        permissionDAO.linkRolePermission(adminRoleId, productWrite);
        permissionDAO.linkRolePermission(adminRoleId, inventoryRead);
        permissionDAO.linkRolePermission(adminRoleId, inventoryWrite);
        permissionDAO.linkRolePermission(adminRoleId, receiptRead);
        permissionDAO.linkRolePermission(adminRoleId, receiptWrite);
        permissionDAO.linkRolePermission(adminRoleId, shipmentRead);
        permissionDAO.linkRolePermission(adminRoleId, shipmentWrite);
        permissionDAO.linkRolePermission(adminRoleId, reportRead);

        // 2. WAREHOUSE STAFF
        long warehouseRoleId = permissionDAO.ensureRole("WAREHOUSE STAFF", "Warehouse Staff");
        permissionDAO.linkRolePermission(warehouseRoleId, brandRead);
        permissionDAO.linkRolePermission(warehouseRoleId, supplierRead);
        permissionDAO.linkRolePermission(warehouseRoleId, prodLineRead);
        permissionDAO.linkRolePermission(warehouseRoleId, productRead);
        permissionDAO.linkRolePermission(warehouseRoleId, inventoryRead);
        permissionDAO.linkRolePermission(warehouseRoleId, receiptRead);
        permissionDAO.linkRolePermission(warehouseRoleId, receiptWrite);
        permissionDAO.linkRolePermission(warehouseRoleId, shipmentRead);
        permissionDAO.linkRolePermission(warehouseRoleId, shipmentWrite);

        // 3. WAREHOUSE MANAGER
        long managerRoleId = permissionDAO.ensureRole("WAREHOUSE MANAGER", "Warehouse Manager");
        permissionDAO.linkRolePermission(managerRoleId, brandRead);
        permissionDAO.linkRolePermission(managerRoleId, brandWrite);
        permissionDAO.linkRolePermission(managerRoleId, supplierRead);
        permissionDAO.linkRolePermission(managerRoleId, supplierWrite);
        permissionDAO.linkRolePermission(managerRoleId, prodLineRead);
        permissionDAO.linkRolePermission(managerRoleId, prodLineWrite);
        permissionDAO.linkRolePermission(managerRoleId, productRead);
        permissionDAO.linkRolePermission(managerRoleId, productWrite);
        permissionDAO.linkRolePermission(managerRoleId, inventoryRead);
        permissionDAO.linkRolePermission(managerRoleId, inventoryWrite);
        permissionDAO.linkRolePermission(managerRoleId, receiptRead);
        permissionDAO.linkRolePermission(managerRoleId, receiptWrite);
        permissionDAO.linkRolePermission(managerRoleId, shipmentRead);
        permissionDAO.linkRolePermission(managerRoleId, shipmentWrite);
        permissionDAO.linkRolePermission(managerRoleId, reportRead);

        // 4. PURCHASING STAFF
        long purchasingRoleId = permissionDAO.ensureRole("PURCHASING STAFF", "Purchasing Staff");
        permissionDAO.linkRolePermission(purchasingRoleId, brandRead);
        permissionDAO.linkRolePermission(purchasingRoleId, supplierRead);
        permissionDAO.linkRolePermission(purchasingRoleId, supplierWrite);
        permissionDAO.linkRolePermission(purchasingRoleId, prodLineRead);
        permissionDAO.linkRolePermission(purchasingRoleId, productRead);
        permissionDAO.linkRolePermission(purchasingRoleId, receiptRead);
        permissionDAO.linkRolePermission(purchasingRoleId, receiptWrite);

        // 5. SALES STAFF
        long salesRoleId = permissionDAO.ensureRole("SALES STAFF", "Sales Staff");
        permissionDAO.linkRolePermission(salesRoleId, brandRead);
        permissionDAO.linkRolePermission(salesRoleId, prodLineRead);
        permissionDAO.linkRolePermission(salesRoleId, productRead);
        permissionDAO.linkRolePermission(salesRoleId, shipmentRead);
        permissionDAO.linkRolePermission(salesRoleId, shipmentWrite);

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
