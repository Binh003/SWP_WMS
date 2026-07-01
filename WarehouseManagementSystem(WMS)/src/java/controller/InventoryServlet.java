package controller;

import dao.InventoryDAO;
import dao.ProductLineDAO;
import dao.BrandDAO;
import model.Inventory;
import model.InventoryHistory;
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
                case "detail" -> showInventoryDetail(request, response);
                case "batchDetail" -> showBatchDetail(request, response);
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
        
        List<Inventory> inventories = inventoryDAO.findPaginated(page, limit, sku, brandId, productLineId, batchCode, barcode);
        int totalItems = inventoryDAO.count(sku, brandId, productLineId, batchCode, barcode);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        
        request.setAttribute("inventories", inventories);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("limit", limit);
        request.setAttribute("sku", sku);
        request.setAttribute("brandId", brandId);
        request.setAttribute("productLineId", productLineId);
        request.setAttribute("batchCode", batchCode);
        request.setAttribute("barcode", barcode);
        
        request.setAttribute("brands", brandDAO.getAll());
        request.setAttribute("productLines", productLineDAO.getAll());
        
        request.getRequestDispatcher("/jsp/admin/inventories.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String idStr = request.getParameter("id");
        Inventory inventory = null;
        if (idStr != null && !idStr.isEmpty()) {
            inventory = inventoryDAO.getById(Long.parseLong(idStr));
        } else {
            String productIdStr = request.getParameter("productId");
            if (productIdStr != null && !productIdStr.isEmpty()) {
                inventory = inventoryDAO.getByProductId(Long.parseLong(productIdStr));
            }
        }
        if (inventory == null) {
            WebUtil.setFlashError(request, "Không tìm thấy tồn kho");
            WebUtil.redirect(request, response, "/admin/inventories");
            return;
        }
        request.setAttribute("inventory", inventory);
        request.getRequestDispatcher("/jsp/admin/inventory-form.jsp").forward(request, response);
    }

    private void showInventoryDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String idStr = request.getParameter("id");
        Inventory inventory = null;
        if (idStr != null && !idStr.isEmpty()) {
            inventory = inventoryDAO.getById(Long.parseLong(idStr));
        } else {
            String productIdStr = request.getParameter("productId");
            if (productIdStr != null && !productIdStr.isEmpty()) {
                inventory = inventoryDAO.getByProductId(Long.parseLong(productIdStr));
            }
        }
        if (inventory == null) {
            WebUtil.setFlashError(request, "Không tìm thấy thông tin tồn kho");
            WebUtil.redirect(request, response, "/admin/inventories");
            return;
        }
        
        List<InventoryHistory> historyList = inventoryDAO.getUpdateHistoryByProductId(inventory.getProductId());
        
        request.setAttribute("inventory", inventory);
        request.setAttribute("historyList", historyList);
        request.getRequestDispatcher("/jsp/admin/inventory-detail.jsp").forward(request, response);
    }

    private void showBatchDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String batchCode = request.getParameter("batchCode");
        if (batchCode == null || batchCode.trim().isEmpty()) {
            WebUtil.setFlashError(request, "Không tìm thấy thông tin lô hàng");
            WebUtil.redirect(request, response, "/admin/inventories");
            return;
        }
        
        List<Inventory> batchInventories = inventoryDAO.getByBatchCode(batchCode);
        request.setAttribute("batchCode", batchCode);
        request.setAttribute("batchInventories", batchInventories);
        request.getRequestDispatcher("/jsp/admin/batch-detail.jsp").forward(request, response);
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
        String idStr = request.getParameter("id");
        Inventory i = null;
        if (idStr != null && !idStr.isEmpty()) {
            i = inventoryDAO.getById(Long.parseLong(idStr));
        } else {
            String productIdStr = request.getParameter("productId");
            if (productIdStr != null && !productIdStr.isEmpty()) {
                i = inventoryDAO.getByProductId(Long.parseLong(productIdStr));
            }
        }
        if (i != null) {
            try {
                int minStockLevel = Integer.parseInt(WebUtil.param(request, "minStockLevel"));
                if (minStockLevel < 0) {
                    WebUtil.setFlashError(request, "Lỗi: Mức tồn kho tối thiểu không được nhỏ hơn 0!");
                    WebUtil.redirect(request, response, "/admin/inventories?action=edit&id=" + i.getId());
                    return;
                }
                String batchCode = WebUtil.param(request, "batchCode");
                String barcode = WebUtil.param(request, "barcode");
                
                i.setBatchCode(batchCode != null ? batchCode.trim() : "");
                i.setBarcode(barcode != null ? barcode.trim() : "");
                i.setMinStockLevel(minStockLevel);
                
                inventoryDAO.update(i);
                WebUtil.setFlashSuccess(request, "Đã cập nhật cấu hình tồn kho");
            } catch (NumberFormatException e) {
                WebUtil.setFlashError(request, "Lỗi: Mức tồn kho tối thiểu không hợp lệ!");
                WebUtil.redirect(request, response, "/admin/inventories?action=edit&id=" + i.getId());
                return;
            }
        }
        WebUtil.redirect(request, response, "/admin/inventories");
    }
}
