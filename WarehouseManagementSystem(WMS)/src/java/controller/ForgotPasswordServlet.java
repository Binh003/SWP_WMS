package controller;

import dao.UserDAO;
import model.User;
import util.PasswordUtil;
import util.SessionKeys;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        if (WebUtil.currentUser(request) != null) {
            WebUtil.redirect(request, response, "/home");
            return;
        }
        WebUtil.consumeFlash(request);
        if (hasResetSession(request)) {
            request.setAttribute("resetStep", 2);
            HttpSession session = request.getSession(false);
            if (session != null) {
                Object username = session.getAttribute(SessionKeys.FORGOT_PASSWORD_USERNAME);
                if (username != null) {
                    request.setAttribute("username", username);
                }
            }
        } else {
            request.setAttribute("resetStep", 1);
        }
        request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        if ("reset".equals(action)) {
            handleReset(request, response);
            return;
        }
        handleVerify(request, response);
    }

    private void handleVerify(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String username = WebUtil.param(request, "username");
        String email = WebUtil.param(request, "email");

        try {
            User user = userDAO.findByUsernameAndEmail(username, email);
            if (user == null) {
                request.setAttribute("flashError", "Tài khoản hoặc email không khớp");
                request.setAttribute("username", username);
                request.setAttribute("email", email);
                request.setAttribute("resetStep", 1);
                request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
                return;
            }
            if (!user.isEnabled()) {
                request.setAttribute("flashError", "Tài khoản chưa được kích hoạt. Liên hệ admin.");
                request.setAttribute("resetStep", 1);
                request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
                return;
            }
            HttpSession resetSession = request.getSession(true);
            resetSession.setAttribute(SessionKeys.FORGOT_PASSWORD_USER_ID, user.getId());
            resetSession.setAttribute(SessionKeys.FORGOT_PASSWORD_USERNAME, username);
            request.setAttribute("resetStep", 2);
            request.setAttribute("username", username);
            request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
        } catch (SQLException ex) {
            request.setAttribute("flashError", "Lỗi hệ thống: " + ex.getMessage());
            request.setAttribute("resetStep", 1);
            request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
        }
    }

    private void handleReset(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Long userId = session == null ? null : (Long) session.getAttribute(SessionKeys.FORGOT_PASSWORD_USER_ID);
        if (userId == null) {
            WebUtil.setFlashError(request, "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thử lại.");
            WebUtil.redirect(request, response, "/forgot-password");
            return;
        }

        String newPassword = WebUtil.param(request, "newPassword");
        String confirmPassword = WebUtil.param(request, "confirmPassword");
        if (newPassword.length() < 6) {
            request.setAttribute("flashError", "Mật khẩu mới phải có ít nhất 6 ký tự");
            request.setAttribute("resetStep", 2);
            request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
            return;
        }
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("flashError", "Mật khẩu xác nhận không khớp");
            request.setAttribute("resetStep", 2);
            request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            userDAO.updatePassword(userId, PasswordUtil.hash(newPassword));
            session.removeAttribute(SessionKeys.FORGOT_PASSWORD_USER_ID);
            session.removeAttribute(SessionKeys.FORGOT_PASSWORD_USERNAME);
            WebUtil.setFlashSuccess(request, "Đặt lại mật khẩu thành công. Vui lòng đăng nhập.");
            WebUtil.redirect(request, response, "/login");
        } catch (SQLException ex) {
            request.setAttribute("flashError", "Lỗi hệ thống: " + ex.getMessage());
            request.setAttribute("resetStep", 2);
            request.getRequestDispatcher("/jsp/forgot-password.jsp").forward(request, response);
        }
    }

    private boolean hasResetSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute(SessionKeys.FORGOT_PASSWORD_USER_ID) != null;
    }
}
