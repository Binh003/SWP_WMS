package controller;

import dao.ShipmentDAO;
import dao.ProductDAO;
import dao.InventoryDAO;
import model.Shipment;
import model.ShipmentDetail;
import model.User;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class ShipmentServlet extends HttpServlet {

    private final ShipmentDAO shipmentDAO = new ShipmentDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();

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
                case "view" -> viewShipment(request, response);
                default -> listShipments(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listShipments(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("shipments", shipmentDAO.getAll());
        request.getRequestDispatcher("/jsp/admin/shipments.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        // Only load products that have inventory > 0
        request.setAttribute("products", productDAO.getAll());
        request.setAttribute("inventories", inventoryDAO.getAll()); // to check stock via JS
        
        String generatedCode = "PX-" + System.currentTimeMillis();
        request.setAttribute("generatedCode", generatedCode);
        
        request.getRequestDispatcher("/jsp/admin/shipment-form.jsp").forward(request, response);
    }

    private void viewShipment(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Shipment shipment = shipmentDAO.getById(id);
        if (shipment == null) {
            WebUtil.setFlashError(request, "Không tìm thấy phiếu xuất");
            WebUtil.redirect(request, response, "/admin/shipments");
            return;
        }
        request.setAttribute("shipment", shipment);
        request.getRequestDispatcher("/jsp/admin/shipment-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        try {
            if ("create".equals(action)) {
                createShipment(request, response);
            } else {
                WebUtil.redirect(request, response, "/admin/shipments");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi tạo phiếu xuất: " + ex.getMessage());
            WebUtil.redirect(request, response, "/admin/shipments?action=create");
        }
    }

    private void createShipment(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        
        User currentUser = WebUtil.currentUser(request);
        
        Shipment s = new Shipment();
        s.setShipmentCode(WebUtil.param(request, "shipmentCode"));
        s.setDestination(WebUtil.param(request, "destination"));
        s.setCreatedBy(currentUser.getId());
        s.setNotes(WebUtil.param(request, "notes"));
        s.setStatus("COMPLETED");

        String[] productIds = request.getParameterValues("productId[]");
        String[] quantities = request.getParameterValues("quantity[]");
        
        if (productIds == null || productIds.length == 0) {
            String singleProductId = WebUtil.param(request, "productId");
            String singleQty = WebUtil.param(request, "quantity");
            if (singleProductId != null && !singleProductId.isEmpty() && singleQty != null && !singleQty.isEmpty()) {
                ShipmentDetail sd = new ShipmentDetail();
                sd.setProductId(Long.parseLong(singleProductId));
                sd.setQuantity(Integer.parseInt(singleQty));
                if (sd.getQuantity() > 0) {
                    s.getDetails().add(sd);
                }
            }
        } else {
            for (int i = 0; i < productIds.length; i++) {
                if (productIds[i] != null && !productIds[i].trim().isEmpty() && quantities[i] != null && !quantities[i].trim().isEmpty()) {
                    int qty = Integer.parseInt(quantities[i]);
                    if (qty > 0) {
                        ShipmentDetail sd = new ShipmentDetail();
                        sd.setProductId(Long.parseLong(productIds[i]));
                        sd.setQuantity(qty);
                        s.getDetails().add(sd);
                    }
                }
            }
        }
        
        if (s.getDetails().isEmpty()) {
            WebUtil.setFlashError(request, "Lỗi: Vui lòng thêm ít nhất 1 sản phẩm với số lượng > 0");
            WebUtil.redirect(request, response, "/admin/shipments?action=create");
            return;
        }

        shipmentDAO.insertWithDetails(s);
        
        WebUtil.setFlashSuccess(request, "Đã tạo phiếu xuất kho và trừ tồn kho thành công");
        WebUtil.redirect(request, response, "/admin/shipments");
    }
}
