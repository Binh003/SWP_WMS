package controller;

import service.AuthService;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

public class ResetPasswordServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String token = WebUtil.param(request, "token");

        try {
            Long userId = authService.validateResetToken(token);
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

        try {
            authService.resetPassword(token, newPassword, confirmPassword);

            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }

            WebUtil.setFlashSuccess(request, "Đặt lại mật khẩu thành công. Vui lòng đăng nhập lại.");
            WebUtil.redirect(request, response, "/login");

        } catch (IllegalArgumentException ex) {
            request.setAttribute("flashError", ex.getMessage());
            request.setAttribute("token", token);
            request.getRequestDispatcher("/jsp/auth/reset-password.jsp").forward(request, response);
        } catch (SQLException ex) {
            request.setAttribute("flashError", "Lỗi hệ thống: " + ex.getMessage());
            request.setAttribute("token", token);
            request.getRequestDispatcher("/jsp/auth/reset-password.jsp").forward(request, response);
        }
    }
}
