package controller;

import service.AuthService;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class ForgotPasswordServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

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

        try {
            String scheme = request.getScheme();
            String serverName = request.getServerName();
            int serverPort = request.getServerPort();
            String contextPath = request.getContextPath();
            String baseUrl = scheme + "://" + serverName + ":" + serverPort + contextPath;

            String resetLink = authService.processForgotPassword(email, baseUrl);

            request.setAttribute("emailSent", true);
            request.setAttribute("resetLink", resetLink);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);

        } catch (IllegalArgumentException ex) {
            request.setAttribute("flashError", ex.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);
        } catch (SQLException ex) {
            request.setAttribute("flashError", "Lỗi hệ thống: " + ex.getMessage());
            request.getRequestDispatcher("/jsp/auth/forgot-password.jsp").forward(request, response);
        }
    }
}
