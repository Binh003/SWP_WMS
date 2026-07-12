package controller;

import dao.ReportDAO;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class ReportServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        request.setAttribute("currentUser", WebUtil.currentUser(request));
        WebUtil.consumeFlash(request);
        request.setAttribute("activePage", "reports");
        request.setAttribute("pageTitle", "Báo cáo thống kê");

        try {
            // Get Overview stats (Total products, total stock, valuation, low stock count)
            Map<String, Object> overviewStats = reportDAO.getOverviewStats();
            request.setAttribute("overview", overviewStats);

            // Get Inbound/Outbound Monthly stats
            List<Map<String, Object>> monthlyStats = reportDAO.getMonthlyInboundOutboundStats();
            request.setAttribute("monthlyStats", monthlyStats);

            // Get Brand Valuation stats
            List<Map<String, Object>> brandValuation = reportDAO.getBrandValuationStats();
            request.setAttribute("brandValuation", brandValuation);

            // Get Top Moving Products
            List<Map<String, Object>> topMoving = reportDAO.getTopMovingProducts();
            request.setAttribute("topMoving", topMoving);

            request.getRequestDispatcher("/jsp/report/dashboard.jsp").forward(request, response);
        } catch (SQLException ex) {
            request.getServletContext().log("Lỗi tải dữ liệu báo cáo: " + ex.getMessage(), ex);
            WebUtil.setFlashError(request, "Đã xảy ra lỗi khi tải dữ liệu báo cáo thống kê.");
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
