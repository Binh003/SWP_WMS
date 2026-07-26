package controller;

import model.User;
import service.AuthService;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class ChangePasswordServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        request.setAttribute("currentUser", WebUtil.currentUser(request));
        WebUtil.consumeFlash(request);
        request.getRequestDispatcher("/jsp/profile/change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        User current = WebUtil.currentUser(request);
        String currentPassword = WebUtil.param(request, "currentPassword");
        String newPassword = WebUtil.param(request, "newPassword");

        try {
            authService.changePassword(current.getId(), currentPassword, newPassword);
            WebUtil.setFlashSuccess(request, "Đổi mật khẩu thành công");
            WebUtil.redirect(request, response, "/profile");
        } catch (IllegalArgumentException ex) {
            request.setAttribute("flashError", ex.getMessage());
            request.setAttribute("currentUser", current);
            request.getRequestDispatcher("/jsp/profile/change-password.jsp").forward(request, response);
        } catch (SQLException ex) {
            request.setAttribute("flashError", ex.getMessage());
            request.setAttribute("currentUser", current);
            request.getRequestDispatcher("/jsp/profile/change-password.jsp").forward(request, response);
        }
    }
}
