package controller;

import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        request.setAttribute("currentUser", WebUtil.currentUser(request));
        WebUtil.consumeFlash(request);
        request.getRequestDispatcher("/jsp/home.jsp").forward(request, response);
    }
}
