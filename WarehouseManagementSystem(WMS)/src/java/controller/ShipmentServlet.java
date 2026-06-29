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
import java.util.ArrayList;
import java.util.List;

@jakarta.servlet.annotation.MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
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
                case "delete" -> deleteDraft(request, response);
                default -> listShipments(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listShipments(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        
        // 1. Calculate stats counts
        List<Shipment> allShipments = shipmentDAO.getAll();
        int pendingCount = 0; // Represents "Chờ lấy hàng" (APPROVED + PENDING)
        int shippingCount = 0; // Represents "Đang xử lý" (PICKING)
        int completedCount = 0; // Represents "Hoàn thành" (COMPLETED)
        for (Shipment s : allShipments) {
            if ("PENDING".equals(s.getStatus()) || "APPROVED".equals(s.getStatus())) {
                pendingCount++;
            } else if ("PICKING".equals(s.getStatus())) {
                shippingCount++;
            } else if ("COMPLETED".equals(s.getStatus())) {
                completedCount++;
            }
        }
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("shippingCount", shippingCount);
        request.setAttribute("completedCount", completedCount);

        // 2. Pagination parameters
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
        
        String search = request.getParameter("search");
        if (search != null) search = search.trim();
        
        String status = request.getParameter("status");
        if (status != null) status = status.trim();
        
        Long creatorId = null;
        String creatorIdParam = request.getParameter("creatorId");
        if (creatorIdParam != null && !creatorIdParam.isEmpty()) {
            try { creatorId = Long.parseLong(creatorIdParam); } catch (NumberFormatException ignored) {}
        }
        
        String startDate = request.getParameter("startDate");
        if (startDate != null) startDate = startDate.trim();
        
        String endDate = request.getParameter("endDate");
        if (endDate != null) endDate = endDate.trim();

        // 3. Query paginated list
        List<Shipment> paginatedShipments = shipmentDAO.findPaginated(page, limit, search, status, creatorId, startDate, endDate);
        int totalItems = shipmentDAO.count(search, status, creatorId, startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        if (totalPages < 1) totalPages = 1;
        
        request.setAttribute("shipments", paginatedShipments);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("limit", limit);
        request.setAttribute("search", search);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedCreatorId", creatorId);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        
        request.setAttribute("creators", shipmentDAO.getCreators());
        
        request.getRequestDispatcher("/jsp/admin/shipments.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("products", productDAO.getAll());
        request.setAttribute("inventories", inventoryDAO.getAll()); // for UI stock checking
        
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

    private void deleteDraft(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        try {
            shipmentDAO.deleteDraft(id);
            WebUtil.setFlashSuccess(request, "Xóa phiếu xuất nháp thành công");
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi khi xóa phiếu: " + ex.getMessage());
        }
        WebUtil.redirect(request, response, "/admin/shipments");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        try {
            if ("create".equals(action)) {
                createShipment(request, response);
            } else if ("updateStatus".equals(action)) {
                updateShipmentStatus(request, response);
            } else {
                WebUtil.redirect(request, response, "/admin/shipments");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            WebUtil.redirect(request, response, "/admin/shipments");
        }
    }

    private void createShipment(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        
        User currentUser = WebUtil.currentUser(request);
        
        Shipment s = new Shipment();
        s.setShipmentCode(WebUtil.param(request, "shipmentCode"));
        s.setDestination(WebUtil.param(request, "destination"));
        s.setCreatedBy(currentUser.getId());
        s.setNotes(WebUtil.param(request, "notes"));
        
        String status = WebUtil.param(request, "status");
        if (status == null || status.trim().isEmpty()) {
            status = "APPROVED";
        }
        s.setStatus(status);

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

        try {
            shipmentDAO.insertWithDetails(s);
            String msg = "Đã tạo phiếu xuất kho thành công";
            WebUtil.setFlashSuccess(request, msg);
            WebUtil.redirect(request, response, "/admin/shipments");
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi tạo phiếu xuất: " + ex.getMessage());
            WebUtil.redirect(request, response, "/admin/shipments?action=create");
        }
    }

    private void updateShipmentStatus(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String status = WebUtil.param(request, "status");
        
        User currentUser = WebUtil.currentUser(request);
        long userId = currentUser != null ? currentUser.getId() : 1L;
        
        if ("COMPLETED".equals(status)) {
            // Upload shipping images and delivery note image when completing shipment (from PICKING to COMPLETED)
            String shippingImages = handleMultipleFilesUpload(request, "shippingImagesFiles");
            String deliveryNoteImage = handleFileUpload(request, "deliveryNoteImageFile");
            
            try {
                shipmentDAO.updateStatus(id, status, deliveryNoteImage, shippingImages, userId);
                WebUtil.setFlashSuccess(request, "Đã xác nhận xuất kho thành công và trừ tồn kho (PGI)!");
            } catch (SQLException ex) {
                WebUtil.setFlashError(request, "Lỗi khi hoàn thành xuất kho (PGI): " + ex.getMessage());
            }
        } else {
            try {
                shipmentDAO.updateStatus(id, status, userId);
                String msg = "Đã cập nhật trạng thái phiếu xuất";
                if ("PENDING".equals(status)) msg = "Đã gửi yêu cầu phê duyệt phiếu xuất";
                else if ("APPROVED".equals(status)) msg = "Đã phê duyệt phiếu xuất";
                else if ("PICKING".equals(status)) msg = "Bắt đầu lấy hàng & đóng gói";
                else if ("CANCELLED".equals(status)) msg = "Đã hủy phiếu xuất và hoàn trả tồn kho (nếu có)";
                WebUtil.setFlashSuccess(request, msg);
            } catch (SQLException ex) {
                WebUtil.setFlashError(request, "Lỗi cập nhật trạng thái: " + ex.getMessage());
            }
        }
        
        WebUtil.redirect(request, response, "/admin/shipments?action=view&id=" + id);
    }

    private String handleFileUpload(HttpServletRequest request, String fieldName) throws ServletException, IOException {
        String contentType = request.getContentType();
        if (contentType == null || !contentType.toLowerCase().startsWith("multipart/form-data")) {
            return null;
        }
        
        try {
            jakarta.servlet.http.Part filePart = request.getPart(fieldName);
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = java.nio.file.Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String extension = "";
                int i = fileName.lastIndexOf('.');
                if (i > 0) {
                    extension = fileName.substring(i);
                }
                String uniqueFileName = "ship_" + System.currentTimeMillis() + "_" + java.util.UUID.randomUUID().toString().substring(0, 8) + extension;
                
                String relativePath = "uploads/shipments/" + uniqueFileName;
                
                // Deploy path
                String deployPath = request.getServletContext().getRealPath("/") + "uploads/shipments";
                java.io.File deployDir = new java.io.File(deployPath);
                if (!deployDir.exists()) deployDir.mkdirs();
                filePart.write(deployPath + java.io.File.separator + uniqueFileName);
                
                // Source path sync (optional, fallback if folder doesn't exist)
                String workspacePath = "d:\\SP_SWP\\Nghia-Phase4.2\\SWP_WMS\\WarehouseManagementSystem(WMS)";
                String srcPath = workspacePath + java.io.File.separator + "web" + java.io.File.separator + "uploads" + java.io.File.separator + "shipments";
                java.io.File srcDir = new java.io.File(srcPath);
                if (srcDir.exists() || srcDir.mkdirs()) {
                    try {
                        java.nio.file.Files.copy(
                            java.nio.file.Paths.get(deployPath + java.io.File.separator + uniqueFileName),
                            java.nio.file.Paths.get(srcPath + java.io.File.separator + uniqueFileName),
                            java.nio.file.StandardCopyOption.REPLACE_EXISTING
                        );
                    } catch (Exception ignored) {}
                }
                
                return "/" + relativePath;
            }
        } catch (Exception ignored) {}
        
        return null;
    }

    private String handleMultipleFilesUpload(HttpServletRequest request, String fieldName) throws ServletException, IOException {
        String contentType = request.getContentType();
        if (contentType == null || !contentType.toLowerCase().startsWith("multipart/form-data")) {
            return null;
        }
        
        List<String> uploadedPaths = new ArrayList<>();
        try {
            java.util.Collection<jakarta.servlet.http.Part> parts = request.getParts();
            int fileCount = 0;
            for (jakarta.servlet.http.Part part : parts) {
                if (part.getName().equals(fieldName) && part.getSize() > 0) {
                    fileCount++;
                    if (fileCount > 4) {
                        break; // Limit to max 4 images
                    }
                    String fileName = java.nio.file.Paths.get(part.getSubmittedFileName()).getFileName().toString();
                    String extension = "";
                    int i = fileName.lastIndexOf('.');
                    if (i > 0) {
                        extension = fileName.substring(i);
                    }
                    String uniqueFileName = "ship_ev_" + System.currentTimeMillis() + "_" + java.util.UUID.randomUUID().toString().substring(0, 8) + extension;
                    
                    String relativePath = "uploads/shipments/" + uniqueFileName;
                    
                    // Deploy path
                    String deployPath = request.getServletContext().getRealPath("/") + "uploads/shipments";
                    java.io.File deployDir = new java.io.File(deployPath);
                    if (!deployDir.exists()) deployDir.mkdirs();
                    part.write(deployPath + java.io.File.separator + uniqueFileName);
                    
                    // Source path sync
                    String workspacePath = "d:\\SP_SWP\\Nghia-Phase4.2\\SWP_WMS\\WarehouseManagementSystem(WMS)";
                    String srcPath = workspacePath + java.io.File.separator + "web" + java.io.File.separator + "uploads" + java.io.File.separator + "shipments";
                    java.io.File srcDir = new java.io.File(srcPath);
                    if (srcDir.exists() || srcDir.mkdirs()) {
                        try {
                            java.nio.file.Files.copy(
                                java.nio.file.Paths.get(deployPath + java.io.File.separator + uniqueFileName),
                                java.nio.file.Paths.get(srcPath + java.io.File.separator + uniqueFileName),
                                java.nio.file.StandardCopyOption.REPLACE_EXISTING
                            );
                        } catch (Exception ignored) {}
                    }
                    
                    uploadedPaths.add("/" + relativePath);
                }
            }
        } catch (Exception ignored) {}
        
        if (uploadedPaths.isEmpty()) {
            return null;
        }
        return String.join(",", uploadedPaths);
    }
}
