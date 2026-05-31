package service;

import dao.RoleDAO;
import dao.UserDAO;
import model.Role;
import model.User;
import util.PasswordUtil;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserService {
    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    public List<User> getAllUsers() throws SQLException {
        return userDAO.findAll();
    }

    public boolean createUser(User user) throws SQLException {
        user.setPasswordHash(PasswordUtil.hash(user.getPasswordHash()));
        userDAO.insert(user);
        return true;
    }

    public boolean updateUser(long id, String fullName, String email, boolean enabled, List<Role> roles) throws SQLException {
        userDAO.updateProfile(id, fullName, email);
        userDAO.setEnabled(id, enabled);
        userDAO.replaceRoles(id, roles);
        return true;
    }

    public boolean toggleUser(long id, boolean enabled) throws SQLException {
        userDAO.setEnabled(id, enabled);
        return true;
    }

    public boolean updateRoles(long id, List<Role> roles) throws SQLException {
        userDAO.replaceRoles(id, roles);
        return true;
    }

    public List<Role> resolveRoles(String[] codes) throws SQLException {
        if (codes == null || codes.length == 0) {
            Role viewer = roleDAO.findByCode("VIEWER");
            return viewer == null ? List.of() : List.of(viewer);
        }

        List<Role> roles = new ArrayList<>();

        for (String code : codes) {
            Role role = roleDAO.findByCode(code);

            if (role != null) {
                roles.add(role);
            }
        }

        return roles;
    }
}
