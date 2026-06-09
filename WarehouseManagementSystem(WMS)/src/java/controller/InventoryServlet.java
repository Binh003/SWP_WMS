package controller;

import dao.InventoryDAO;
import dao.ProductLineDAO;
import dao.BrandDAO;
import model.Inventory;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.stream.Collectors;

public class InventoryServlet extends HttpServlet {

    private final InventoryDAO inventoryDAO = new InventoryDAO();
    private final ProductLineDAO productLineDAO = new ProductLineDAO();
    private final BrandDAO brandDAO = new BrandDAO();

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
                case "edit" -> showEditForm(request, response);
                default -> listInventories(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listInventories(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        
        int page = 1;
        int limit = 10;
        String pageParam = request.getParameter("page");
        String limitParam = request.getParameter("limit");
        
        if (pageParam != null && !pageParam.isEmpty()) {
            try { page = Integer.parseInt(pageParam); } catch (NumberFormatException ignored) {}
        }
        if (limitParam != null && !limitParam.isEmpty()) {
            try { limit = Integer.parseInt(limitParam); } catch (NumberFormatException ignored) {}
        }
        
        String sku = request.getParameter("sku");
        if (sku != null) sku = sku.trim();
        
        String brandIdStr = request.getParameter("brandId");
        Long brandId = null;
        if (brandIdStr != null && !brandIdStr.isEmpty()) {
            try { brandId = Long.parseLong(brandIdStr); } catch (NumberFormatException ignored) {}
        }
        
        String productLineIdStr = request.getParameter("productLineId");
        Long productLineId = null;
        if (productLineIdStr != null && !productLineIdStr.isEmpty()) {
            try { productLineId = Long.parseLong(productLineIdStr); } catch (NumberFormatException ignored) {}
        }
        
        List<Inventory> inventories = inventoryDAO.findPaginated(page, limit, sku, brandId, productLineId);
        int totalItems = inventoryDAO.count(sku, brandId, productLineId);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        
        request.setAttribute("inventories", inventories);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("limit", limit);
        request.setAttribute("sku", sku);
        request.setAttribute("brandId", brandId);
        request.setAttribute("productLineId", productLineId);
        
        request.setAttribute("brands", brandDAO.getAll());
        request.setAttribute("productLines", productLineDAO.getAll());
        
        request.getRequestDispatcher("/jsp/admin/inventories.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long productId = Long.parseLong(WebUtil.param(request, "productId"));
        Inventory inventory = inventoryDAO.getByProductId(productId);
        if (inventory == null) {
            WebUtil.setFlashError(request, "Không tìm thấy tồn kho cho sản phẩm này");
            WebUtil.redirect(request, response, "/admin/inventories");
            return;
        }
        request.setAttribute("inventory", inventory);
        request.getRequestDispatcher("/jsp/admin/inventory-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        try {
            if ("update".equals(action)) {
                updateInventory(request, response);
            } else {
                WebUtil.redirect(request, response, "/admin/inventories");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            WebUtil.redirect(request, response, "/admin/inventories");
        }
    }

    private void updateInventory(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long productId = Long.parseLong(WebUtil.param(request, "productId"));
        Inventory i = inventoryDAO.getByProductId(productId);
        if (i != null) {
            // Note: quantityInStock should ideally be updated via Inbound/Outbound, 
            // but we might allow admin to override it or set initial stock.
            i.setQuantityInStock(Integer.parseInt(WebUtil.param(request, "quantityInStock")));
            i.setMinStockLevel(Integer.parseInt(WebUtil.param(request, "minStockLevel")));
            
            inventoryDAO.update(i);
            WebUtil.setFlashSuccess(request, "Đã cập nhật cấu hình tồn kho");
        }
        WebUtil.redirect(request, response, "/admin/inventories");
    }
}
