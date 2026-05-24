package controller;

import dao.UserDAO;
import model.User;
import util.PasswordUtil;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class ChangePasswordServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

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
            User dbUser = userDAO.findById(current.getId());
            if (dbUser == null || !PasswordUtil.matches(currentPassword, dbUser.getPasswordHash())) {
                request.setAttribute("flashError", "Mật khẩu hiện tại không đúng");
                request.setAttribute("currentUser", current);
                request.getRequestDispatcher("/jsp/profile/change-password.jsp").forward(request, response);
                return;
            }
            userDAO.updatePassword(current.getId(), PasswordUtil.hash(newPassword));
            WebUtil.setFlashSuccess(request, "Đổi mật khẩu thành công");
            WebUtil.redirect(request, response, "/profile");
        } catch (SQLException ex) {
            request.setAttribute("flashError", ex.getMessage());
            request.setAttribute("currentUser", current);
            request.getRequestDispatcher("/jsp/profile/change-password.jsp").forward(request, response);
        }
    }
}
