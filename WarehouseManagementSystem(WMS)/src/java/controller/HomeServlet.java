package controller;

import dao.ReportDAO;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

public class HomeServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        try {
            request.setAttribute("currentUser", WebUtil.currentUser(request));
            WebUtil.consumeFlash(request);

            // Fetch real dashboard statistics
            Map<String, Object> overview = reportDAO.getOverviewStats();
            request.setAttribute("totalInventoryItems", overview.getOrDefault("totalInventoryItems", 0));
            request.setAttribute("lowStockCount", overview.getOrDefault("lowStockCount", 0));
            
            int todayTransactions = reportDAO.getTodayTransactionsCount();
            request.setAttribute("todayTransactions", todayTransactions);
            
            request.setAttribute("recentTransactions", reportDAO.getRecentTransactions());
            request.setAttribute("lowStockProducts", reportDAO.getLowStockProducts());
            
        } catch (SQLException ex) {
            request.setAttribute("totalInventoryItems", 0);
            request.setAttribute("lowStockCount", 0);
            request.setAttribute("todayTransactions", 0);
        }
        request.getRequestDispatcher("/jsp/home.jsp").forward(request, response);
    }
}
