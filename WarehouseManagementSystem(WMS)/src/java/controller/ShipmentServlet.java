package controller;

import model.Shipment;
import model.User;
import service.ShipmentService;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@jakarta.servlet.annotation.MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ShipmentServlet extends HttpServlet {

    private final ShipmentService shipmentService = new ShipmentService();

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
                case "deleteShippingImage" -> deleteShippingImage(request, response);
                case "apiProductBatches" -> getProductBatchesJson(request, response);
                default -> listShipments(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listShipments(HttpServletRequest request, HttpServletResponse response)
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

        ShipmentService.ShipmentPageResult result = shipmentService.getShipmentsPaginated(page, limit, search, status, creatorId, startDate, endDate);

        request.setAttribute("pendingCount", result.getPendingCount());
        request.setAttribute("approvedCount", result.getApprovedCount());
        request.setAttribute("shippingCount", result.getShippingCount());
        request.setAttribute("completedCount", result.getCompletedCount());
        request.setAttribute("shipments", result.getShipments());
        request.setAttribute("totalItems", result.getTotalItems());
        request.setAttribute("totalPages", result.getTotalPages());
        request.setAttribute("currentPage", result.getCurrentPage());
        request.setAttribute("limit", result.getLimit());
        request.setAttribute("search", search);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedCreatorId", creatorId);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("creators", result.getCreators());
        
        request.getRequestDispatcher("/jsp/manage/shipments.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("products", shipmentService.getAllProducts());
        request.setAttribute("inventories", shipmentService.getAllInventories());
        
        String generatedCode = "PX-" + System.currentTimeMillis();
        request.setAttribute("generatedCode", generatedCode);
        
        request.getRequestDispatcher("/jsp/manage/shipment-form.jsp").forward(request, response);
    }

    private void viewShipment(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Shipment shipment = shipmentService.getById(id);
        if (shipment == null) {
            WebUtil.setFlashError(request, "Không tìm thấy phiếu xuất");
            WebUtil.redirect(request, response, "/manage/shipments");
            return;
        }
        request.setAttribute("shipment", shipment);
        request.getRequestDispatcher("/jsp/manage/shipment-detail.jsp").forward(request, response);
    }

    private void deleteDraft(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        try {
            shipmentService.deleteDraft(id);
            WebUtil.setFlashSuccess(request, "Xóa phiếu xuất nháp thành công");
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi khi xóa phiếu: " + ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/shipments");
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
            } else if ("updateShippingImages".equals(action)) {
                updateShippingImages(request, response);
            } else if ("deleteShippingImage".equals(action)) {
                deleteShippingImage(request, response);
            } else if ("updateManualBatches".equals(action)) {
                updateManualBatches(request, response);
            } else {
                WebUtil.redirect(request, response, "/manage/shipments");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            WebUtil.redirect(request, response, "/manage/shipments");
        }
    }

    private void createShipment(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        User currentUser = WebUtil.currentUser(request);
        String shipmentCode = WebUtil.param(request, "shipmentCode");
        String destination = WebUtil.param(request, "destination");
        String notes = WebUtil.param(request, "notes");
        String status = WebUtil.param(request, "status");

        String[] productIds = request.getParameterValues("productId[]");
        String[] quantities = request.getParameterValues("quantity[]");
        String[] batchCodes = request.getParameterValues("batchCode[]");
        String[] barcodes = request.getParameterValues("barcode[]");
        String singleProductId = WebUtil.param(request, "productId");
        String singleQty = WebUtil.param(request, "quantity");

        try {
            shipmentService.createShipment(shipmentCode, destination, currentUser, notes, status, productIds, quantities, batchCodes, barcodes, singleProductId, singleQty);
            WebUtil.setFlashSuccess(request, "Đã tạo yêu cầu xuất kho thành công");
            WebUtil.redirect(request, response, "/manage/shipments");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/shipments?action=create");
        }
    }

    private void updateShipmentStatus(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String status = WebUtil.param(request, "status");
        User currentUser = WebUtil.currentUser(request);
        String uploadedImages = handleMultipleFilesUpload(request, "shippingImagesFiles");
        String deliveryNoteImage = handleFileUpload(request, "deliveryNoteImageFile");

        try {
            String msg = shipmentService.updateShipmentStatus(id, status, uploadedImages, deliveryNoteImage, currentUser);
            WebUtil.setFlashSuccess(request, msg);
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/shipments?action=view&id=" + id);
    }

    private void updateShippingImages(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String imageUrls = handleMultipleFilesUpload(request, "shippingImagesFiles");
        try {
            shipmentService.updateShippingImages(id, imageUrls);
            WebUtil.setFlashSuccess(request, "Đã cập nhật hình ảnh sản phẩm xuất kho thành công");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/shipments?action=view&id=" + id);
    }

    private void deleteShippingImage(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String imageUrl = WebUtil.param(request, "imageUrl");
        shipmentService.deleteShippingImage(id, imageUrl);
        WebUtil.setFlashSuccess(request, "Đã xóa ảnh sản phẩm xuất kho thành công");
        WebUtil.redirect(request, response, "/manage/shipments?action=view&id=" + id);
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
                
                // Source path sync
                String workspacePath = util.WebUtil.getWorkspacePath(request);
                if (workspacePath != null) {
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
                        break;
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
                    String workspacePath = util.WebUtil.getWorkspacePath(request);
                    if (workspacePath != null) {
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

    private void getProductBatchesJson(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String productIdStr = request.getParameter("productId");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.getWriter().write("[]");
            return;
        }
        try {
            long productId = Long.parseLong(productIdStr.trim());
            List<Map<String, Object>> batches = shipmentService.getAvailableInventoryBatches(productId);
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < batches.size(); i++) {
                Map<String, Object> b = batches.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(b.get("id")).append(",");
                json.append("\"batchCode\":\"").append(util.WebUtil.escapeJson((String) b.get("batchCode"))).append("\",");
                json.append("\"barcode\":\"").append(util.WebUtil.escapeJson((String) b.get("barcode"))).append("\",");
                json.append("\"quantityInStock\":").append(b.get("quantityInStock")).append(",");
                java.sql.Timestamp ts = (java.sql.Timestamp) b.get("lastUpdated");
                json.append("\"lastUpdated\":\"").append(ts != null ? sdf.format(ts) : "").append("\"");
                json.append("}");
            }
            json.append("]");
            response.getWriter().write(json.toString());
        } catch (Exception e) {
            response.getWriter().write("{\"error\":\"" + util.WebUtil.escapeJson(e.getMessage()) + "\"}");
        }
    }

    private void updateManualBatches(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long shipmentId = Long.parseLong(WebUtil.param(request, "id"));
        String[] detailIds = request.getParameterValues("detailId[]");
        String[] batchCodes = request.getParameterValues("batchCode[]");
        String[] barcodes = request.getParameterValues("barcode[]");

        try {
            shipmentService.updateManualBatches(shipmentId, detailIds, batchCodes, barcodes);
            WebUtil.setFlashSuccess(request, "Đã cập nhật phân bổ Lô hàng & Barcode thủ công thành công!");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/shipments?action=view&id=" + shipmentId);
    }
}
