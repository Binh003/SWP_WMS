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
import java.util.List;

public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        if (WebUtil.currentUser(request) != null) {
            WebUtil.redirect(request, response, "/home");
            return;
        }
        WebUtil.consumeFlash(request);
        request.getRequestDispatcher("/jsp/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String username = WebUtil.param(request, "email");
        if (username.isEmpty()) {
            username = WebUtil.param(request, "username");
        }
        String fullName = WebUtil.param(request, "fullName");
        String password = WebUtil.param(request, "password");
        String confirmPassword = WebUtil.param(request, "confirmPassword");

        request.setAttribute("email", username);
        request.setAttribute("fullName", fullName);

        if (!password.equals(confirmPassword)) {
            request.setAttribute("flashError", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/jsp/auth/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 8 || !password.matches(".*[a-z].*") || !password.matches(".*[A-Z].*") || !password.matches(".*\\d.*")) {
            request.setAttribute("flashError", "Mật khẩu phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số.");
            request.getRequestDispatcher("/jsp/auth/register.jsp").forward(request, response);
            return;
        }

        try {
            if (userDAO.existsByUsername(username)) {
                request.setAttribute("flashError", "Tài khoản đã tồn tại");
                request.getRequestDispatcher("/jsp/auth/register.jsp").forward(request, response);
                return;
            }
            Role viewer = roleDAO.findByCode("VIEWER");
            if (viewer == null) {
                throw new SQLException("Role VIEWER chưa được seed");
            }

            User user = new User();
            user.setUsername(username);
            user.setFullName(fullName.isEmpty() ? username : fullName);
            user.setEmail(username);
            user.setPasswordHash(PasswordUtil.hash(password));
            user.setEnabled(false);
            user.setRoles(List.of(viewer));
            userDAO.insert(user);

            WebUtil.setFlashSuccess(request, "Đăng ký thành công. Chờ admin phê duyệt.");
            WebUtil.redirect(request, response, "/login");
        } catch (SQLException ex) {
            request.setAttribute("flashError", "Đăng ký thất bại: " + ex.getMessage());
            request.getRequestDispatcher("/jsp/auth/register.jsp").forward(request, response);
        }
    }
}
