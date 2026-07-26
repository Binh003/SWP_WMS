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

    public static class UserPageResult {
        private final List<User> users;
        private final List<Role> allRoles;
        private final int currentPage;
        private final int pageSize;
        private final int totalCount;
        private final int totalPages;

        public UserPageResult(List<User> users, List<Role> allRoles, int currentPage, int pageSize, int totalCount, int totalPages) {
            this.users = users;
            this.allRoles = allRoles;
            this.currentPage = currentPage;
            this.pageSize = pageSize;
            this.totalCount = totalCount;
            this.totalPages = totalPages;
        }

        public List<User> getUsers() { return users; }
        public List<Role> getAllRoles() { return allRoles; }
        public int getCurrentPage() { return currentPage; }
        public int getPageSize() { return pageSize; }
        public int getTotalCount() { return totalCount; }
        public int getTotalPages() { return totalPages; }
    }

    public UserPageResult getUsersPaginated(String search, String status, String role, int requestedPage, int requestedSize) throws SQLException {
        int page = requestedPage < 1 ? 1 : requestedPage;
        int size = requestedSize < 1 ? 10 : requestedSize;

        int totalCount = userDAO.count(search, status, role);
        int totalPages = (int) Math.ceil((double) totalCount / size);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * size;
        List<User> users = userDAO.findPaginated(search, status, role, offset, size);
        List<Role> roles = roleDAO.findAll();

        return new UserPageResult(users, roles, page, size, totalCount, totalPages);
    }

    public User getUserById(long id) throws SQLException {
        return userDAO.findById(id);
    }

    public List<Role> getAllRoles() throws SQLException {
        return roleDAO.findAll();
    }

    public void createUser(String username, String fullName, String email, String password, String confirmPassword, String[] roleCodes) throws SQLException, IllegalArgumentException {
        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên đăng nhập không được để trống.");
        }
        if (userDAO.existsByUsername(username.trim())) {
            throw new IllegalArgumentException("Tài khoản đã tồn tại");
        }

        if (password == null || !password.equals(confirmPassword)) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp.");
        }

        if (password.length() < 8 || !password.matches(".*[a-z].*") || !password.matches(".*[A-Z].*") || !password.matches(".*\\d.*")) {
            throw new IllegalArgumentException("Mật khẩu phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số.");
        }

        List<Role> selectedRoles = resolveRoles(roleCodes);

        User user = new User();
        user.setUsername(username.trim());
        user.setFullName(fullName == null || fullName.trim().isEmpty() ? username.trim() : fullName.trim());
        user.setEmail(email != null ? email.trim() : "");
        user.setPasswordHash(PasswordUtil.hash(password));
        user.setStatus("ACTIVE");
        user.setRoles(selectedRoles);

        userDAO.insert(user);
    }

    public void updateUser(long id, String fullName, String email, String password, String confirmPassword, String status, String enabledParam, String[] roleCodes) throws SQLException, IllegalArgumentException {
        User user = userDAO.findById(id);
        if (user != null && "admin".equalsIgnoreCase(user.getUsername())) {
            throw new IllegalArgumentException("Không thể chỉnh sửa tài khoản quản trị hệ thống");
        }

        if (password != null && !password.isEmpty()) {
            if (!password.equals(confirmPassword)) {
                throw new IllegalArgumentException("Mật khẩu xác nhận không khớp.");
            }
            if (password.length() < 8 || !password.matches(".*[a-z].*") || !password.matches(".*[A-Z].*") || !password.matches(".*\\d.*")) {
                throw new IllegalArgumentException("Mật khẩu phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số.");
            }
        }

        userDAO.updateProfile(id, fullName != null ? fullName.trim() : "", email != null ? email.trim() : "");

        if (password != null && !password.isEmpty()) {
            userDAO.updatePassword(id, PasswordUtil.hash(password));
        }

        if (status != null && !status.trim().isEmpty()) {
            userDAO.setStatus(id, status.trim());
        } else {
            boolean enabled = "on".equalsIgnoreCase(enabledParam) || "true".equalsIgnoreCase(enabledParam);
            userDAO.setEnabled(id, enabled);
        }

        userDAO.replaceRoles(id, resolveRoles(roleCodes));
    }

    public String toggleUserStatus(long id, String status, String enabledParam) throws SQLException, IllegalArgumentException {
        User user = userDAO.findById(id);
        if (user != null && "admin".equalsIgnoreCase(user.getUsername())) {
            throw new IllegalArgumentException("Không thể thay đổi trạng thái tài khoản quản trị hệ thống");
        }

        if (status != null && !status.trim().isEmpty()) {
            userDAO.setStatus(id, status.trim());
            String displayStatus = "Đang hoạt động";
            if ("LOCKED".equalsIgnoreCase(status)) {
                displayStatus = "Bị khóa";
            } else if ("PENDING".equalsIgnoreCase(status)) {
                displayStatus = "Chờ phê duyệt";
            }
            return "Đã chuyển trạng thái sang " + displayStatus;
        } else {
            boolean enabled = Boolean.parseBoolean(enabledParam);
            userDAO.setEnabled(id, enabled);
            return enabled ? "Đã kích hoạt" : "Đã vô hiệu hóa";
        }
    }

    public void updateRoles(long id, String[] roleCodes) throws SQLException, IllegalArgumentException {
        User user = userDAO.findById(id);
        if (user != null && "admin".equalsIgnoreCase(user.getUsername())) {
            throw new IllegalArgumentException("Không thể thay đổi vai trò tài khoản quản trị hệ thống");
        }
        userDAO.replaceRoles(id, resolveRoles(roleCodes));
    }

    public List<Role> resolveRoles(String[] codes) throws SQLException {
        if (codes == null || codes.length == 0) {
            Role defaultRole = roleDAO.findByCode("WAREHOUSE STAFF");
            return defaultRole == null ? List.of() : List.of(defaultRole);
        }
        List<Role> roles = new ArrayList<>();
        for (String code : codes) {
            if ("ADMIN".equalsIgnoreCase(code)) {
                continue;
            }
            Role role = roleDAO.findByCode(code);
            if (role != null) {
                roles.add(role);
            }
        }
        if (roles.isEmpty()) {
            Role defaultRole = roleDAO.findByCode("WAREHOUSE STAFF");
            if (defaultRole != null) {
                roles.add(defaultRole);
            }
        }
        return roles;
    }
}
