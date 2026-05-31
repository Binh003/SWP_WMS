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
            request.setAttribute("currentUser", WebUtil.currentUser(request));
            WebUtil.consumeFlash(request);
            switch (action) {
                case "create" -> showCreateForm(request, response);
                case "edit" -> showEditForm(request, response);
                default -> listUsers(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("users", userDAO.findAll());
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
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
        throws SQLException, IOException {
        User user = new User();
        user.setUsername(WebUtil.param(request, "username"));
        user.setFullName(WebUtil.param(request, "fullName"));
        user.setEmail(WebUtil.param(request, "email"));
        user.setPasswordHash(PasswordUtil.hash(WebUtil.param(request, "password")));
        user.setEnabled(true);
        user.setRoles(resolveRoles(request));
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
        boolean enabled = "on".equalsIgnoreCase(WebUtil.param(request, "enabled"))
            || "true".equalsIgnoreCase(WebUtil.param(request, "enabled"));
        userDAO.setEnabled(id, enabled);
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
        boolean enabled = Boolean.parseBoolean(WebUtil.param(request, "enabled"));
        userDAO.setEnabled(id, enabled);
        WebUtil.setFlashSuccess(request, enabled ? "Đã kích hoạt" : "Đã vô hiệu hóa");
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
