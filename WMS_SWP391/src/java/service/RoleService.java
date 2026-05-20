package service;

import dao.PermissionDAO;
import dao.RoleDAO;
import model.Role;

import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

public class RoleService {
    private final RoleDAO roleDAO = new RoleDAO();
    private final PermissionDAO permissionDAO = new PermissionDAO();

    public List<Role> getAllRoles() throws SQLException {
        return roleDAO.findAll();
    }

    public Role getRoleWithPermissions(long id) throws SQLException {
        return roleDAO.findByIdWithPermissions(id);
    }

    public List<String[]> getAllPermissions() throws SQLException {
        return permissionDAO.findAll();
    }

    public boolean updateRole(long id, String name, String description, boolean enabled, String[] codes) throws SQLException {
        roleDAO.updateRole(id, name, description);
        roleDAO.setEnabled(id, enabled);

        List<String> permissionCodes = codes == null ? List.of() : Arrays.asList(codes);
        roleDAO.replacePermissions(id, permissionCodes);

        return true;
    }
}
