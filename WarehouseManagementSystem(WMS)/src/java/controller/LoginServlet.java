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
import java.io.IOException;
import java.sql.SQLException;

public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        if (WebUtil.currentUser(request) != null) {
            WebUtil.redirect(request, response, "/home");
            return;
        }
        WebUtil.consumeFlash(request);
        request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String username = WebUtil.param(request, "username");
        String password = WebUtil.param(request, "password");

        try {
            User user = userDAO.findByUsername(username);
            if (user == null || !PasswordUtil.matches(password, user.getPasswordHash())) {
                request.setAttribute("flashError", "Tài khoản hoặc mật khẩu không đúng");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
                return;
            }
            if (!user.isEnabled()) {
                request.setAttribute("flashError", "Tài khoản chưa được admin kích hoạt");
                request.setAttribute("username", username);
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
                return;
            }
            request.getSession(true).setAttribute(SessionKeys.CURRENT_USER, user);
            WebUtil.setFlashSuccess(request, "Chào mừng trở lại!");
            WebUtil.redirect(request, response, "/home");
        } catch (SQLException ex) {
            request.setAttribute("flashError", "Lỗi hệ thống: " + ex.getMessage());
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        }
    }
}
