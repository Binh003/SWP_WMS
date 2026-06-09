package controller;

import dao.RoleDAO;
import dao.UserDAO;
import model.Role;
import model.User;
import util.PasswordUtil;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserAdminServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        try {
            User currentUser = WebUtil.currentUser(request);
            request.setAttribute("currentUser", currentUser);
            WebUtil.consumeFlash(request);
            
            boolean canWrite = currentUser != null && (currentUser.hasRole("ADMIN") || currentUser.hasPermission("USER_WRITE"));
            
            if (!canWrite && ("create".equals(action) || "edit".equals(action))) {
                WebUtil.setFlashError(request, "Bạn không có quyền thực hiện thao tác này");
                WebUtil.redirect(request, response, "/admin/users");
                return;
            }

            switch (action) {
                case "create" -> showCreateForm(request, response);
                case "edit" -> showEditForm(request, response);
                case "detail" -> showDetail(request, response);
                default -> listUsers(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String role = request.getParameter("role");

        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException ignored) {}
        }

        int size = 10;
        String sizeStr = request.getParameter("size");
        if (sizeStr != null && !sizeStr.isEmpty()) {
            try {
                size = Integer.parseInt(sizeStr);
            } catch (NumberFormatException ignored) {}
        }

        int totalCount = userDAO.count(search, status, role);
        int totalPages = (int) Math.ceil((double) totalCount / size);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        if (page < 1) page = 1;

        int offset = (page - 1) * size;
        List<User> users = userDAO.findPaginated(search, status, role, offset, size);

        request.setAttribute("users", users);
        request.setAttribute("roles", roleDAO.findAll()); // for the filter dropdown
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("selectedRole", role);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", size);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("totalPages", totalPages);

        request.getRequestDispatcher("/jsp/admin/users.jsp").forward(request, response);
    }


    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("roles", roleDAO.findAll());
        request.getRequestDispatcher("/jsp/admin/user-create.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        User user = userDAO.findById(id);
        if (user != null && "admin".equalsIgnoreCase(user.getUsername())) {
            WebUtil.setFlashError(request, "Không thể chỉnh sửa tài khoản quản trị hệ thống");
            WebUtil.redirect(request, response, "/admin/users");
            return;
        }
        request.setAttribute("user", user);
        request.setAttribute("roles", roleDAO.findAll());
        request.getRequestDispatcher("/jsp/admin/user-edit.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String idStr = WebUtil.param(request, "id");
        if (idStr == null || idStr.isEmpty()) {
            WebUtil.redirect(request, response, "/admin/users");
            return;
        }
        long id = Long.parseLong(idStr);
        User user = userDAO.findById(id);
        if (user == null) {
            WebUtil.setFlashError(request, "Không tìm thấy tài khoản");
            WebUtil.redirect(request, response, "/admin/users");
            return;
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/jsp/admin/user-detail.jsp").forward(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        User currentUser = WebUtil.currentUser(request);
        boolean canWrite = currentUser != null && (currentUser.hasRole("ADMIN") || currentUser.hasPermission("USER_WRITE"));
        if (!canWrite) {
            WebUtil.setFlashError(request, "Bạn không có quyền thực hiện thao tác này");
            WebUtil.redirect(request, response, "/admin/users");
            return;
        }
        
        String action = WebUtil.param(request, "action");
        try {
            switch (action) {
                case "create" -> createUser(request, response);
                case "update" -> updateUser(request, response);
                case "toggle" -> toggleUser(request, response);
                case "roles" -> updateRoles(request, response);
                default -> WebUtil.redirect(request, response, "/admin/users");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/admin/users");
        }
    }

    private void createUser(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String username = WebUtil.param(request, "username");
        String fullName = WebUtil.param(request, "fullName");
        String email = WebUtil.param(request, "email");
        String password = WebUtil.param(request, "password");
        String confirmPassword = WebUtil.param(request, "confirmPassword");
        List<Role> selectedRoles = resolveRoles(request);

        // Keep values in request attributes to prepopulate form in case of error
        request.setAttribute("username", username);
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        List<String> roleCodes = selectedRoles.stream().map(Role::getCode).toList();
        request.setAttribute("roleCodes", roleCodes);

        if (!password.equals(confirmPassword)) {
            request.setAttribute("flashError", "Mật khẩu xác nhận không khớp.");
            showCreateForm(request, response);
            return;
        }

        if (password.length() < 8 || !password.matches(".*[a-z].*") || !password.matches(".*[A-Z].*") || !password.matches(".*\\d.*")) {
            request.setAttribute("flashError", "Mật khẩu phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số.");
            showCreateForm(request, response);
            return;
        }

        if (userDAO.existsByUsername(username)) {
            request.setAttribute("flashError", "Tài khoản đã tồn tại");
            showCreateForm(request, response);
            return;
        }

        User user = new User();
        user.setUsername(username);
        user.setFullName(fullName.isEmpty() ? username : fullName);
        user.setEmail(email);
        user.setPasswordHash(PasswordUtil.hash(password));
        user.setStatus("ACTIVE");
        user.setRoles(selectedRoles);

        userDAO.insert(user);
        WebUtil.setFlashSuccess(request, "Đã tạo tài khoản");
        WebUtil.redirect(request, response, "/admin/users");
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        User user = userDAO.findById(id);
        if (user != null && "admin".equalsIgnoreCase(user.getUsername())) {
            WebUtil.setFlashError(request, "Không thể chỉnh sửa tài khoản quản trị hệ thống");
            WebUtil.redirect(request, response, "/admin/users");
            return;
        }
        userDAO.updateProfile(id, WebUtil.param(request, "fullName"), WebUtil.param(request, "email"));
        String status = WebUtil.param(request, "status");
        if (status != null && !status.isEmpty()) {
            userDAO.setStatus(id, status);
        } else {
            boolean enabled = "on".equalsIgnoreCase(WebUtil.param(request, "enabled"))
                || "true".equalsIgnoreCase(WebUtil.param(request, "enabled"));
            userDAO.setEnabled(id, enabled);
        }
        userDAO.replaceRoles(id, resolveRoles(request));
        WebUtil.setFlashSuccess(request, "Đã cập nhật tài khoản");
        WebUtil.redirect(request, response, "/admin/users");
    }

    private void toggleUser(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        User user = userDAO.findById(id);
        if (user != null && "admin".equalsIgnoreCase(user.getUsername())) {
            WebUtil.setFlashError(request, "Không thể thay đổi trạng thái tài khoản quản trị hệ thống");
            WebUtil.redirect(request, response, "/admin/users");
            return;
        }
        String status = WebUtil.param(request, "status");
        if (status != null && !status.isEmpty()) {
            userDAO.setStatus(id, status);
            String displayStatus = "Đang hoạt động";
            if ("LOCKED".equalsIgnoreCase(status)) {
                displayStatus = "Bị khóa";
            } else if ("PENDING".equalsIgnoreCase(status)) {
                displayStatus = "Chờ phê duyệt";
            }
            WebUtil.setFlashSuccess(request, "Đã chuyển trạng thái sang " + displayStatus);
        } else {
            boolean enabled = Boolean.parseBoolean(WebUtil.param(request, "enabled"));
            userDAO.setEnabled(id, enabled);
            WebUtil.setFlashSuccess(request, enabled ? "Đã kích hoạt" : "Đã vô hiệu hóa");
        }
        WebUtil.redirect(request, response, "/admin/users");
    }

    private void updateRoles(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        User user = userDAO.findById(id);
        if (user != null && "admin".equalsIgnoreCase(user.getUsername())) {
            WebUtil.setFlashError(request, "Không thể thay đổi vai trò tài khoản quản trị hệ thống");
            WebUtil.redirect(request, response, "/admin/users");
            return;
        }
        userDAO.replaceRoles(id, resolveRoles(request));
        WebUtil.setFlashSuccess(request, "Đã cập nhật vai trò");
        WebUtil.redirect(request, response, "/admin/users");
    }

    private List<Role> resolveRoles(HttpServletRequest request) throws SQLException {
        String[] codes = request.getParameterValues("roleCodes");
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
