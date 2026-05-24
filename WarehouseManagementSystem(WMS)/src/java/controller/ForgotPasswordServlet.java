package controller;

import dao.UserDAO;
import dao.PasswordResetDAO;
import model.User;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.UUID;

public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetDAO passwordResetDAO = new PasswordResetDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        if (WebUtil.currentUser(request) != null) {
            WebUtil.redirect(request, response, "/home");
            return;
        }
        WebUtil.consumeFlash(request);
        request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String email = WebUtil.param(request, "email");

        if (email.isEmpty()) {
            request.setAttribute("flashError", "Email không được để trống");
            request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            User user = userDAO.findByEmail(email);
            if (user == null) {
                request.setAttribute("flashError", "Email không tồn tại trong hệ thống");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            if (!user.isEnabled()) {
                request.setAttribute("flashError", "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);
                return;
            }

            // Generate token (random UUID)
            String token = UUID.randomUUID().toString();
            // Expire in 15 minutes
            Timestamp expiryTime = new Timestamp(System.currentTimeMillis() + 15 * 60 * 1000);

            // Save to DB
            passwordResetDAO.createToken(user.getId(), token, expiryTime);

            // Construct reset link
            String scheme = request.getScheme();
            String serverName = request.getServerName();
            int serverPort = request.getServerPort();
            String contextPath = request.getContextPath();
            
            String baseUrl = scheme + "://" + serverName + ":" + serverPort + contextPath;
            String resetLink = baseUrl + "/reset-password?token=" + token;

            // Log the link in server console
            System.out.println("=================================================");
            System.out.println("MÃ KHÔI PHỤC MẬT KHẨU CHO: " + user.getUsername());
            System.out.println("Reset Link: " + resetLink);
            System.out.println("=================================================");

            // Send actual email (safe block to prevent crashes if credentials/jars are missing)
            try {
                util.EmailUtil.sendResetLink(email, resetLink);
            } catch (Throwable t) {
                System.err.println("Gửi email thật thất bại (Có thể do chưa cấu hình SMTP hoặc thiếu thư viện JAR): " + t.getMessage());
            }

            // Pass variables to UI
            request.setAttribute("emailSent", true);
            request.setAttribute("resetLink", resetLink);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);

        } catch (SQLException ex) {
            request.setAttribute("flashError", "Lỗi hệ thống: " + ex.getMessage());
            request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);
        }
    }
}
