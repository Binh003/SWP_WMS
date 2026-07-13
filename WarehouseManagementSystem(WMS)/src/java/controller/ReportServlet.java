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

        String reportType = request.getParameter("reportType");
        if (reportType == null || reportType.trim().isEmpty()) {
            reportType = "overview";
        }
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String action = request.getParameter("action");

        request.setAttribute("reportType", reportType);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);

        try {
            if ("export".equals(action)) {
                response.setContentType("application/vnd.ms-excel");
                response.setCharacterEncoding("UTF-8");
                String filename = "Bao_cao_" + reportType + "_" + System.currentTimeMillis() + ".xls";
                response.setHeader("Content-Disposition", "attachment; filename=" + filename);

                java.io.PrintWriter out = response.getWriter();
                out.println("<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:x='urn:schemas-microsoft-com:office:excel' xmlns='http://www.w3.org/TR/REC-html40'>");
                out.println("<head>");
                out.println("<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>");
                out.println("<!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>Báo cáo</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->");
                out.println("<style>");
                out.println("  body { font-family: 'Segoe UI', Arial, sans-serif; }");
                out.println("  table { border-collapse: collapse; }");
                out.println("  th { background-color: #3b82f6; color: #ffffff; font-weight: bold; border: 1px solid #cbd5e1; padding: 8px; text-align: left; }");
                out.println("  td { border: 1px solid #cbd5e1; padding: 8px; }");
                out.println("  .title { font-size: 16pt; font-weight: bold; text-align: center; color: #1e293b; }");
                out.println("  .bold { font-weight: bold; }");
                out.println("  .bg-header { background-color: #f1f5f9; }");
                out.println("  .bg-summary { background-color: #eff6ff; }");
                out.println("</style>");
                out.println("</head>");
                out.println("<body>");

                java.text.NumberFormat curFmt = java.text.NumberFormat.getCurrencyInstance(new java.util.Locale("vi", "VN"));
                java.text.SimpleDateFormat dateFmt = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");

                if ("inbound".equals(reportType)) {
                    List<Map<String, Object>> list = reportDAO.getDetailedInboundReport(startDate, endDate);
                    int totalQty = 0;
                    double totalVal = 0.0;
                    for (Map<String, Object> r : list) {
                        totalQty += (int) r.get("totalQty");
                        totalVal += (double) r.get("totalVal");
                    }

                    out.println("<table>");
                    out.println("  <tr><td colspan='7' class='title'>BÁO CÁO CHI TIẾT NHẬP KHO</td></tr>");
                    if (startDate != null && !startDate.isEmpty()) {
                        out.println("  <tr><td colspan='7' class='bold'>Từ ngày: " + startDate + "</td></tr>");
                    }
                    if (endDate != null && !endDate.isEmpty()) {
                        out.println("  <tr><td colspan='7' class='bold'>Đến ngày: " + endDate + "</td></tr>");
                    }
                    out.println("  <tr><td colspan='7'>Ngày xuất báo cáo: " + dateFmt.format(new java.util.Date()) + "</td></tr>");
                    out.println("  <tr><td colspan='7'></td></tr>");
                    
                    out.println("  <tr>");
                    out.println("    <th>Mã phiếu</th>");
                    out.println("    <th>Ngày nhập</th>");
                    out.println("    <th>Nhà cung cấp</th>");
                    out.println("    <th>Người lập</th>");
                    out.println("    <th>Trạng thái</th>");
                    out.println("    <th>Tổng số lượng</th>");
                    out.println("    <th>Tổng giá trị nhập</th>");
                    out.println("  </tr>");

                    for (Map<String, Object> r : list) {
                        out.println("  <tr>");
                        out.println("    <td>#" + r.get("code") + "</td>");
                        out.println("    <td>" + dateFmt.format((java.sql.Timestamp) r.get("createdAt")) + "</td>");
                        out.println("    <td>" + r.get("supplierName") + "</td>");
                        out.println("    <td>" + r.get("creatorName") + "</td>");
                        out.println("    <td>" + r.get("status") + "</td>");
                        out.println("    <td>" + r.get("totalQty") + "</td>");
                        out.println("    <td>" + curFmt.format(r.get("totalVal")) + "</td>");
                        out.println("  </tr>");
                    }

                    out.println("  <tr class='bg-summary bold'>");
                    out.println("    <td colspan='5'>TỔNG CỘNG</td>");
                    out.println("    <td>" + totalQty + "</td>");
                    out.println("    <td>" + curFmt.format(totalVal) + "</td>");
                    out.println("  </tr>");
                    out.println("</table>");

                } else if ("outbound".equals(reportType)) {
                    List<Map<String, Object>> list = reportDAO.getDetailedOutboundReport(startDate, endDate);
                    int totalQty = 0;
                    double totalVal = 0.0;
                    for (Map<String, Object> r : list) {
                        totalQty += (int) r.get("totalQty");
                        totalVal += (double) r.get("totalVal");
                    }

                    out.println("<table>");
                    out.println("  <tr><td colspan='7' class='title'>BÁO CÁO CHI TIẾT XUẤT KHO</td></tr>");
                    if (startDate != null && !startDate.isEmpty()) {
                        out.println("  <tr><td colspan='7' class='bold'>Từ ngày: " + startDate + "</td></tr>");
                    }
                    if (endDate != null && !endDate.isEmpty()) {
                        out.println("  <tr><td colspan='7' class='bold'>Đến ngày: " + endDate + "</td></tr>");
                    }
                    out.println("  <tr><td colspan='7'>Ngày xuất báo cáo: " + dateFmt.format(new java.util.Date()) + "</td></tr>");
                    out.println("  <tr><td colspan='7'></td></tr>");
                    
                    out.println("  <tr>");
                    out.println("    <th>Mã phiếu</th>");
                    out.println("    <th>Ngày xuất</th>");
                    out.println("    <th>Địa điểm nhận</th>");
                    out.println("    <th>Người lập</th>");
                    out.println("    <th>Trạng thái</th>");
                    out.println("    <th>Tổng số lượng</th>");
                    out.println("    <th>Tổng giá trị xuất</th>");
                    out.println("  </tr>");

                    for (Map<String, Object> r : list) {
                        out.println("  <tr>");
                        out.println("    <td>#" + r.get("code") + "</td>");
                        out.println("    <td>" + dateFmt.format((java.sql.Timestamp) r.get("createdAt")) + "</td>");
                        out.println("    <td>" + r.get("destination") + "</td>");
                        out.println("    <td>" + r.get("creatorName") + "</td>");
                        out.println("    <td>" + r.get("status") + "</td>");
                        out.println("    <td>" + r.get("totalQty") + "</td>");
                        out.println("    <td>" + curFmt.format(r.get("totalVal")) + "</td>");
                        out.println("  </tr>");
                    }

                    out.println("  <tr class='bg-summary bold'>");
                    out.println("    <td colspan='5'>TỔNG CỘNG</td>");
                    out.println("    <td>" + totalQty + "</td>");
                    out.println("    <td>" + curFmt.format(totalVal) + "</td>");
                    out.println("  </tr>");
                    out.println("</table>");

                } else if ("inventory".equals(reportType)) {
                    List<Map<String, Object>> list = reportDAO.getDetailedInventoryReport();
                    int totalQty = 0;
                    double totalVal = 0.0;
                    int lowStockCount = 0;
                    for (Map<String, Object> r : list) {
                        int qty = (int) r.get("quantityInStock");
                        int min = (int) r.get("minStockLevel");
                        double price = (double) r.get("price");
                        totalQty += qty;
                        totalVal += (qty * price);
                        if (min > 0 && qty <= min) {
                            lowStockCount++;
                        }
                    }

                    out.println("<table>");
                    out.println("  <tr><td colspan='8' class='title'>BÁO CÁO CHI TIẾT TỒN KHO THỰC TẾ</td></tr>");
                    out.println("  <tr><td colspan='8'>Ngày xuất báo cáo: " + dateFmt.format(new java.util.Date()) + "</td></tr>");
                    out.println("  <tr><td colspan='8'></td></tr>");
                    
                    out.println("  <tr>");
                    out.println("    <th>Mã vạch</th>");
                    out.println("    <th>Mã lô</th>");
                    out.println("    <th>SKU</th>");
                    out.println("    <th>Tên sản phẩm</th>");
                    out.println("    <th>Đơn giá</th>");
                    out.println("    <th>Lượng tồn kho</th>");
                    out.println("    <th>Định mức tối thiểu</th>");
                    out.println("    <th>Trạng thái</th>");
                    out.println("  </tr>");

                    for (Map<String, Object> r : list) {
                        int qty = (int) r.get("quantityInStock");
                        int min = (int) r.get("minStockLevel");
                        boolean isLow = (min > 0 && qty <= min);

                        out.println("  <tr>");
                        out.println("    <td>" + r.get("barcode") + "</td>");
                        out.println("    <td>" + r.get("batchCode") + "</td>");
                        out.println("    <td>" + r.get("sku") + "</td>");
                        out.println("    <td>" + r.get("productName") + "</td>");
                        out.println("    <td>" + curFmt.format(r.get("price")) + "</td>");
                        out.println("    <td" + (isLow ? " style='color: red; font-weight: bold;'" : "") + ">" + qty + "</td>");
                        out.println("    <td>" + min + "</td>");
                        out.println("    <td>" + (isLow ? "Tồn kho thấp" : "Đủ hàng") + "</td>");
                        out.println("  </tr>");
                    }

                    out.println("  <tr class='bg-summary bold'>");
                    out.println("    <td colspan='5'>TỔNG CỘNG / TỔNG HỢP</td>");
                    out.println("    <td>" + totalQty + "</td>");
                    out.println("    <td>Dưới định mức: " + lowStockCount + "</td>");
                    out.println("    <td>Giá trị: " + curFmt.format(totalVal) + "</td>");
                    out.println("  </tr>");
                    out.println("</table>");
                }

                out.println("</body>");
                out.println("</html>");
                return;
            }

            // Always fetch overview to keep quick stats available
            Map<String, Object> overviewStats = reportDAO.getOverviewStats();
            request.setAttribute("overview", overviewStats);

            if ("overview".equals(reportType)) {
                // Get Inbound/Outbound Monthly stats
                List<Map<String, Object>> monthlyStats = reportDAO.getMonthlyInboundOutboundStats();
                request.setAttribute("monthlyStats", monthlyStats);

                // Get Brand Valuation stats
                List<Map<String, Object>> brandValuation = reportDAO.getBrandValuationStats();
                request.setAttribute("brandValuation", brandValuation);

                // Get Top Moving Products
                List<Map<String, Object>> topMoving = reportDAO.getTopMovingProducts();
                request.setAttribute("topMoving", topMoving);
            } else if ("inbound".equals(reportType)) {
                List<Map<String, Object>> inboundReport = reportDAO.getDetailedInboundReport(startDate, endDate);
                request.setAttribute("inboundReport", inboundReport);
                
                // Calculate summaries
                int totalInboundQty = 0;
                double totalInboundVal = 0.0;
                for (Map<String, Object> r : inboundReport) {
                    totalInboundQty += (int) r.get("totalQty");
                    totalInboundVal += (double) r.get("totalVal");
                }
                request.setAttribute("totalInboundQty", totalInboundQty);
                request.setAttribute("totalInboundVal", totalInboundVal);
                request.setAttribute("totalInboundReceipts", inboundReport.size());
            } else if ("outbound".equals(reportType)) {
                List<Map<String, Object>> outboundReport = reportDAO.getDetailedOutboundReport(startDate, endDate);
                request.setAttribute("outboundReport", outboundReport);

                // Calculate summaries
                int totalOutboundQty = 0;
                double totalOutboundVal = 0.0;
                for (Map<String, Object> r : outboundReport) {
                    totalOutboundQty += (int) r.get("totalQty");
                    totalOutboundVal += (double) r.get("totalVal");
                }
                request.setAttribute("totalOutboundQty", totalOutboundQty);
                request.setAttribute("totalOutboundVal", totalOutboundVal);
                request.setAttribute("totalOutboundShipments", outboundReport.size());
            } else if ("inventory".equals(reportType)) {
                List<Map<String, Object>> inventoryReport = reportDAO.getDetailedInventoryReport();
                request.setAttribute("inventoryReport", inventoryReport);

                // Calculate summaries
                int totalInvQty = 0;
                double totalInvVal = 0.0;
                int totalLowStock = 0;
                for (Map<String, Object> r : inventoryReport) {
                    int qty = (int) r.get("quantityInStock");
                    int min = (int) r.get("minStockLevel");
                    double price = (double) r.get("price");
                    totalInvQty += qty;
                    totalInvVal += (qty * price);
                    if (min > 0 && qty <= min) {
                        totalLowStock++;
                    }
                }
                request.setAttribute("totalInvQty", totalInvQty);
                request.setAttribute("totalInvVal", totalInvVal);
                request.setAttribute("totalInvProductsCount", inventoryReport.size());
                request.setAttribute("totalInvLowStock", totalLowStock);
            }

            request.getRequestDispatcher("/jsp/report/dashboard.jsp").forward(request, response);
        } catch (SQLException ex) {
            request.getServletContext().log("Lỗi tải dữ liệu báo cáo: " + ex.getMessage(), ex);
            WebUtil.setFlashError(request, "Đã xảy ra lỗi khi tải dữ liệu báo cáo thống kê.");
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
