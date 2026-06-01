package controller;

import dao.ReceiptDAO;
import dao.SupplierDAO;
import dao.ProductDAO;
import model.Receipt;
import model.ReceiptDetail;
import model.User;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ReceiptServlet extends HttpServlet {

    private final ReceiptDAO receiptDAO = new ReceiptDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        try {
            request.setAttribute("currentUser", WebUtil.currentUser(request));
            WebUtil.consumeFlash(request);
            switch (action) {
                case "create" -> showCreateForm(request, response);
                case "view" -> viewReceipt(request, response);
                default -> listReceipts(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listReceipts(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("receipts", receiptDAO.getAll());
        request.getRequestDispatcher("/jsp/admin/receipts.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("suppliers", supplierDAO.getAll());
        request.setAttribute("products", productDAO.getAll());
        
        // Generate a random code for initial draft or use auto generated
        String generatedCode = "PN-" + System.currentTimeMillis();
        request.setAttribute("generatedCode", generatedCode);
        
        request.getRequestDispatcher("/jsp/admin/receipt-form.jsp").forward(request, response);
    }

    private void viewReceipt(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Receipt receipt = receiptDAO.getById(id);
        if (receipt == null) {
            WebUtil.setFlashError(request, "Không tìm thấy phiếu nhập");
            WebUtil.redirect(request, response, "/admin/receipts");
            return;
        }
        request.setAttribute("receipt", receipt);
        request.getRequestDispatcher("/jsp/admin/receipt-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        try {
            if ("create".equals(action)) {
                createReceipt(request, response);
            } else {
                WebUtil.redirect(request, response, "/admin/receipts");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            WebUtil.redirect(request, response, "/admin/receipts");
        }
    }

    private void createReceipt(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        
        User currentUser = WebUtil.currentUser(request);
        
        Receipt r = new Receipt();
        r.setReceiptCode(WebUtil.param(request, "receiptCode"));
        r.setSupplierId(Long.parseLong(WebUtil.param(request, "supplierId")));
        r.setCreatedBy(currentUser.getId());
        r.setNotes(WebUtil.param(request, "notes"));
        r.setStatus("COMPLETED"); // Default auto complete

        // Get details (for simplicity, we assume single item submission from simple form, or arrays for multi-item)
        String[] productIds = request.getParameterValues("productId[]");
        String[] quantities = request.getParameterValues("quantity[]");
        
        if (productIds == null || productIds.length == 0) {
            // fallback to single if not array
            String singleProductId = WebUtil.param(request, "productId");
            String singleQty = WebUtil.param(request, "quantity");
            if (singleProductId != null && !singleProductId.isEmpty() && singleQty != null && !singleQty.isEmpty()) {
                ReceiptDetail rd = new ReceiptDetail();
                rd.setProductId(Long.parseLong(singleProductId));
                rd.setQuantity(Integer.parseInt(singleQty));
                if (rd.getQuantity() > 0) {
                    r.getDetails().add(rd);
                }
            }
        } else {
            for (int i = 0; i < productIds.length; i++) {
                if (productIds[i] != null && !productIds[i].trim().isEmpty() && quantities[i] != null && !quantities[i].trim().isEmpty()) {
                    int qty = Integer.parseInt(quantities[i]);
                    if (qty > 0) {
                        ReceiptDetail rd = new ReceiptDetail();
                        rd.setProductId(Long.parseLong(productIds[i]));
                        rd.setQuantity(qty);
                        r.getDetails().add(rd);
                    }
                }
            }
        }
        
        if (r.getDetails().isEmpty()) {
            WebUtil.setFlashError(request, "Lỗi: Vui lòng thêm ít nhất 1 sản phẩm với số lượng > 0");
            WebUtil.redirect(request, response, "/admin/receipts?action=create");
            return;
        }

        receiptDAO.insertWithDetails(r);
        
        WebUtil.setFlashSuccess(request, "Đã tạo phiếu nhập kho và cập nhật số lượng tồn thành công");
        WebUtil.redirect(request, response, "/admin/receipts");
    }
}