package controller;

import model.User;
import service.AuthService;
import util.SessionKeys;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        if (WebUtil.currentUser(request) != null) {
            WebUtil.redirect(request, response, "/home");
            return;
        }
        WebUtil.consumeFlash(request);
        request.getRequestDispatcher("/jsp/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String username = WebUtil.param(request, "username");
        String password = WebUtil.param(request, "password");

        try {
            AuthService.LoginResult result = authService.login(username, password);
            if (!result.isSuccess()) {
                request.setAttribute("flashError", result.getErrorMessage());
                request.setAttribute("username", username);
                request.getRequestDispatcher("/jsp/auth/login.jsp").forward(request, response);
                return;
            }

            User user = result.getUser();
            request.getSession(true).setAttribute(SessionKeys.CURRENT_USER, user);
            WebUtil.setFlashSuccess(request, "Chào mừng trở lại!");
            WebUtil.redirect(request, response, "/home");
        } catch (SQLException ex) {
            request.setAttribute("flashError", "Lỗi hệ thống: " + ex.getMessage());
            request.getRequestDispatcher("/jsp/auth/login.jsp").forward(request, response);
        }
    }
}
