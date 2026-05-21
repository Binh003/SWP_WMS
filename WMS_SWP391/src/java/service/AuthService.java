package service;

import dao.RoleDAO;
import dao.UserDAO;
import model.Role;
import model.User;
import util.PasswordUtil;

import java.sql.SQLException;
import java.util.List;

public class AuthService {
    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    public User login(String username, String password) throws SQLException {
        User user = userDAO.findByUsername(username);

        if (user == null) {
            return null;
        }

        if (!PasswordUtil.matches(password, user.getPasswordHash())) {
            return null;
        }

        if (!user.isEnabled()) {
            return null;
        }

        return user;
    }

    public boolean changePassword(long userId, String currentPassword, String newPassword) throws SQLException {
        User dbUser = userDAO.findById(userId);

        if (dbUser == null) {
            return false;
        }

        if (!PasswordUtil.matches(currentPassword, dbUser.getPasswordHash())) {
            return false;
        }

        userDAO.updatePassword(userId, PasswordUtil.hash(newPassword));
        return true;
    }

    public boolean register(User user) throws SQLException {
        if (userDAO.existsByUsername(user.getUsername())) {
            return false;
        }

        Role viewer = roleDAO.findByCode("VIEWER");

        if (viewer == null) {
            throw new SQLException("Role VIEWER chưa được seed");
        }

        user.setPasswordHash(PasswordUtil.hash(user.getPasswordHash()));
        user.setEnabled(false);
        user.setRoles(List.of(viewer));

        userDAO.insert(user);

        return true;
    }
}
