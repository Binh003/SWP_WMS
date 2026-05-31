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
        PermissionDAO permissionDAO = new PermissionDAO();
        UserDAO userDAO = new UserDAO();

        long userRead = permissionDAO.ensurePermission("USER_READ", "Xem người dùng");
        long userWrite = permissionDAO.ensurePermission("USER_WRITE", "Quản lý người dùng");
        long roleRead = permissionDAO.ensurePermission("ROLE_READ", "Xem vai trò");
        long roleWrite = permissionDAO.ensurePermission("ROLE_WRITE", "Quản lý vai trò");
        long permRead = permissionDAO.ensurePermission("PERMISSION_READ", "Xem quyền");

        long adminRoleId = permissionDAO.ensureRole("ADMIN", "Administrator");
        permissionDAO.linkRolePermission(adminRoleId, userRead);
        permissionDAO.linkRolePermission(adminRoleId, userWrite);
        permissionDAO.linkRolePermission(adminRoleId, roleRead);
        permissionDAO.linkRolePermission(adminRoleId, roleWrite);
        permissionDAO.linkRolePermission(adminRoleId, permRead);

        permissionDAO.ensureRole("WAREHOUSE", "Warehouse");
        permissionDAO.ensureRole("VIEWER", "Viewer");

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
