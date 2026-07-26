package controller;

import model.Role;
import model.User;
import service.UserService;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class UserAdminServlet extends HttpServlet {

    private final UserService userService = new UserService();

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
                WebUtil.redirect(request, response, "/manage/users");
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

        UserService.UserPageResult result = userService.getUsersPaginated(search, status, role, page, size);

        request.setAttribute("users", result.getUsers());
        request.setAttribute("roles", result.getAllRoles());
        request.setAttribute("search", search);
        request.setAttribute("status", status);
        request.setAttribute("selectedRole", role);
        request.setAttribute("currentPage", result.getCurrentPage());
        request.setAttribute("pageSize", result.getPageSize());
        request.setAttribute("totalCount", result.getTotalCount());
        request.setAttribute("totalPages", result.getTotalPages());

        request.getRequestDispatcher("/jsp/manage/users.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("roles", userService.getAllRoles());
        request.getRequestDispatcher("/jsp/manage/user-create.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        User user = userService.getUserById(id);
        if (user != null && "admin".equalsIgnoreCase(user.getUsername())) {
            WebUtil.setFlashError(request, "Không thể chỉnh sửa tài khoản quản trị hệ thống");
            WebUtil.redirect(request, response, "/manage/users");
            return;
        }
        request.setAttribute("user", user);
        request.setAttribute("roles", userService.getAllRoles());
        request.getRequestDispatcher("/jsp/manage/user-edit.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String idStr = WebUtil.param(request, "id");
        if (idStr == null || idStr.isEmpty()) {
            WebUtil.redirect(request, response, "/manage/users");
            return;
        }
        long id = Long.parseLong(idStr);
        User user = userService.getUserById(id);
        if (user == null) {
            WebUtil.setFlashError(request, "Không tìm thấy tài khoản");
            WebUtil.redirect(request, response, "/manage/users");
            return;
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/jsp/manage/user-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        User currentUser = WebUtil.currentUser(request);
        boolean canWrite = currentUser != null && (currentUser.hasRole("ADMIN") || currentUser.hasPermission("USER_WRITE"));
        if (!canWrite) {
            WebUtil.setFlashError(request, "Bạn không có quyền thực hiện thao tác này");
            WebUtil.redirect(request, response, "/manage/users");
            return;
        }
        
        String action = WebUtil.param(request, "action");
        try {
            switch (action) {
                case "create" -> createUser(request, response);
                case "update" -> updateUser(request, response);
                case "toggle" -> toggleUser(request, response);
                case "roles" -> updateRoles(request, response);
                default -> WebUtil.redirect(request, response, "/manage/users");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/users");
        }
    }

    private void createUser(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String username = WebUtil.param(request, "username");
        String fullName = WebUtil.param(request, "fullName");
        String email = WebUtil.param(request, "email");
        String password = WebUtil.param(request, "password");
        String confirmPassword = WebUtil.param(request, "confirmPassword");
        String[] roleCodes = request.getParameterValues("roleCodes");

        // Keep values in request attributes to prepopulate form in case of error
        request.setAttribute("username", username);
        request.setAttribute("fullName", fullName);
        request.setAttribute("email", email);
        List<Role> selectedRoles = userService.resolveRoles(roleCodes);
        List<String> roleCodesList = selectedRoles.stream().map(Role::getCode).toList();
        request.setAttribute("roleCodes", roleCodesList);

        try {
            userService.createUser(username, fullName, email, password, confirmPassword, roleCodes);
            WebUtil.setFlashSuccess(request, "Đã tạo tài khoản");
            WebUtil.redirect(request, response, "/manage/users");
        } catch (IllegalArgumentException ex) {
            request.setAttribute("flashError", ex.getMessage());
            showCreateForm(request, response);
        }
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String password = WebUtil.param(request, "password");
        String confirmPassword = WebUtil.param(request, "confirmPassword");
        String fullName = WebUtil.param(request, "fullName");
        String email = WebUtil.param(request, "email");
        String status = WebUtil.param(request, "status");
        String enabled = WebUtil.param(request, "enabled");
        String[] roleCodes = request.getParameterValues("roleCodes");

        try {
            userService.updateUser(id, fullName, email, password, confirmPassword, status, enabled, roleCodes);
            WebUtil.setFlashSuccess(request, "Đã cập nhật tài khoản");
            WebUtil.redirect(request, response, "/manage/users");
        } catch (IllegalArgumentException ex) {
            request.setAttribute("flashError", ex.getMessage());
            showEditForm(request, response);
        }
    }

    private void toggleUser(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String status = WebUtil.param(request, "status");
        String enabled = WebUtil.param(request, "enabled");

        try {
            String message = userService.toggleUserStatus(id, status, enabled);
            WebUtil.setFlashSuccess(request, message);
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/users");
    }

    private void updateRoles(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String[] roleCodes = request.getParameterValues("roleCodes");

        try {
            userService.updateRoles(id, roleCodes);
            WebUtil.setFlashSuccess(request, "Đã cập nhật vai trò");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/users");
    }
}
