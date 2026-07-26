package controller;

import model.Inventory;
import service.InventoryService;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class InventoryServlet extends HttpServlet {

    private final InventoryService inventoryService = new InventoryService();

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
                case "batchDetail" -> showBatchDetail(request, response);
                case "detail" -> showItemDetail(request, response);
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

        String batchCode = request.getParameter("batchCode");
        if (batchCode != null) batchCode = batchCode.trim();

        String barcode = request.getParameter("barcode");
        if (barcode != null) barcode = barcode.trim();
        
        InventoryService.InventoryPageResult result = inventoryService.getInventoriesPaginated(page, limit, sku, brandId, productLineId, batchCode, barcode);

        request.setAttribute("inventories", result.getInventories());
        request.setAttribute("totalItems", result.getTotalItems());
        request.setAttribute("totalPages", result.getTotalPages());
        request.setAttribute("currentPage", result.getCurrentPage());
        request.setAttribute("limit", result.getLimit());
        request.setAttribute("sku", sku);
        request.setAttribute("brandId", brandId);
        request.setAttribute("productLineId", productLineId);
        request.setAttribute("batchCode", batchCode);
        request.setAttribute("barcode", barcode);
        request.setAttribute("brands", result.getAllBrands());
        request.setAttribute("productLines", result.getAllProductLines());
        
        request.getRequestDispatcher("/jsp/manage/inventories.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String idStr = request.getParameter("id");
        String productIdStr = request.getParameter("productId");

        Inventory inventory = inventoryService.getInventoryForForm(idStr, productIdStr);
        if (inventory == null) {
            WebUtil.setFlashError(request, "Không tìm thấy tồn kho");
            WebUtil.redirect(request, response, "/manage/inventories");
            return;
        }
        
        request.setAttribute("inventory", inventory);
        request.getRequestDispatcher("/jsp/manage/inventory-form.jsp").forward(request, response);
    }

    private void showBatchDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String idStr = request.getParameter("id");
        String productIdStr = request.getParameter("productId");

        InventoryService.BatchDetailResult result = inventoryService.getBatchDetail(idStr, productIdStr);
        if (result == null) {
            WebUtil.setFlashError(request, "Không tìm thấy thông tin tồn kho");
            WebUtil.redirect(request, response, "/manage/inventories");
            return;
        }
        
        request.setAttribute("inventory", result.getInventory());
        request.setAttribute("itemizedList", result.getItemizedList());
        request.setAttribute("totalQuantity", result.getTotalQuantity());
        request.getRequestDispatcher("/jsp/manage/inventory-detail.jsp").forward(request, response);
    }

    private void showItemDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            WebUtil.redirect(request, response, "/manage/inventories");
            return;
        }

        Inventory inventory = inventoryService.getItemDetail(Long.parseLong(idStr.trim()));
        if (inventory == null) {
            WebUtil.setFlashError(request, "Không tìm thấy thông tin chi tiết của sản phẩm đơn lẻ này");
            WebUtil.redirect(request, response, "/manage/inventories");
            return;
        }
        
        request.setAttribute("inventory", inventory);
        request.getRequestDispatcher("/jsp/manage/inventory-item-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        try {
            if ("update".equals(action)) {
                updateInventory(request, response);
            } else {
                WebUtil.redirect(request, response, "/manage/inventories");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            WebUtil.redirect(request, response, "/manage/inventories");
        }
    }

    private void updateInventory(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        String idStr = request.getParameter("id");
        String productIdStr = request.getParameter("productId");
        String minStockLevelStr = WebUtil.param(request, "minStockLevel");

        try {
            inventoryService.updateMinStockLevel(idStr, productIdStr, minStockLevelStr);
            WebUtil.setFlashSuccess(request, "Đã cập nhật cấu hình cảnh báo tồn kho");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/inventories");
    }
}
