package controller;

import dao.UserDAO;
import dao.PasswordResetDAO;
import util.PasswordUtil;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

public class ResetPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetDAO passwordResetDAO = new PasswordResetDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String token = WebUtil.param(request, "token");

        if (token.isEmpty()) {
            WebUtil.setFlashError(request, "Mã xác minh (token) bị thiếu.");
            WebUtil.redirect(request, response, "/forgot-password");
            return;
        }

        try {
            Long userId = passwordResetDAO.getUserIdByValidToken(token);
            if (userId == null) {
                WebUtil.setFlashError(request, "Liên kết đã hết hạn, đã được sử dụng hoặc không hợp lệ.");
                WebUtil.redirect(request, response, "/forgot-password");
                return;
            }

            request.setAttribute("token", token);
            WebUtil.consumeFlash(request);
            request.getRequestDispatcher("/jsp/auth/reset-password.jsp").forward(request, response);
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            WebUtil.redirect(request, response, "/forgot-password");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String token = WebUtil.param(request, "token");
        String newPassword = WebUtil.param(request, "newPassword");
        String confirmPassword = WebUtil.param(request, "confirmPassword");

        if (token.isEmpty()) {
            WebUtil.setFlashError(request, "Mã xác minh (token) không hợp lệ.");
            WebUtil.redirect(request, response, "/forgot-password");
            return;
        }

        try {
            Long userId = passwordResetDAO.getUserIdByValidToken(token);
            if (userId == null) {
                WebUtil.setFlashError(request, "Liên kết khôi phục đã hết hạn hoặc không còn hiệu lực.");
                WebUtil.redirect(request, response, "/forgot-password");
                return;
            }

            if (newPassword.length() < 8 || !newPassword.matches(".*[a-z].*") || !newPassword.matches(".*[A-Z].*") || !newPassword.matches(".*\\d.*")) {
                request.setAttribute("flashError", "Mật khẩu mới phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số.");
                request.setAttribute("token", token);
                request.getRequestDispatcher("/jsp/auth/reset-password.jsp").forward(request, response);
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("flashError", "Mật khẩu xác nhận không khớp.");
                request.setAttribute("token", token);
                request.getRequestDispatcher("/jsp/auth/reset-password.jsp").forward(request, response);
                return;
            }

            // Update user password and invalidate token
            userDAO.updatePassword(userId, PasswordUtil.hash(newPassword));
            passwordResetDAO.markTokenAsUsed(token);

            // Invalidate current session (forces logout of this client if they were logged in)
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }

            WebUtil.setFlashSuccess(request, "Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại.");
            WebUtil.redirect(request, response, "/login");

        } catch (SQLException ex) {
            request.setAttribute("flashError", "Lỗi hệ thống: " + ex.getMessage());
            request.setAttribute("token", token);
            request.getRequestDispatcher("/jsp/auth/reset-password.jsp").forward(request, response);
        }
    }
}
