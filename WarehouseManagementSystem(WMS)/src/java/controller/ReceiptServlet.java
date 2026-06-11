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

@jakarta.servlet.annotation.MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
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
                case "delete" -> deleteDraft(request, response);
                default -> listReceipts(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listReceipts(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        
        // 1. Get all to calculate stats counts
        List<Receipt> allReceipts = receiptDAO.getAll();
        int pendingCount = 0;
        int processingCount = 0;
        int completedCount = 0;
        for (Receipt r : allReceipts) {
            if ("PENDING_APPROVAL".equals(r.getStatus())) {
                pendingCount++;
            } else if ("APPROVED".equals(r.getStatus()) || "RECEIVING".equals(r.getStatus())) {
                processingCount++;
            } else if ("COMPLETED".equals(r.getStatus())) {
                completedCount++;
            }
        }
        request.setAttribute("pendingCount", pendingCount);
        request.setAttribute("processingCount", processingCount);
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

        Long supplierId = null;
        String supplierIdParam = request.getParameter("supplierId");
        if (supplierIdParam != null && !supplierIdParam.isEmpty()) {
            try { supplierId = Long.parseLong(supplierIdParam); } catch (NumberFormatException ignored) {}
        }
        
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
        List<Receipt> paginatedReceipts = receiptDAO.findPaginated(page, limit, search, status, supplierId, creatorId, startDate, endDate);
        int totalItems = receiptDAO.count(search, status, supplierId, creatorId, startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        if (totalPages < 1) totalPages = 1;
        
        request.setAttribute("receipts", paginatedReceipts);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("limit", limit);
        request.setAttribute("search", search);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedSupplierId", supplierId);
        request.setAttribute("selectedCreatorId", creatorId);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        
        request.setAttribute("suppliers", supplierDAO.getAll());
        request.setAttribute("creators", receiptDAO.getCreators());
        
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

    private void deleteDraft(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        try {
            receiptDAO.deleteDraft(id);
            WebUtil.setFlashSuccess(request, "Xóa phiếu nhập nháp thành công");
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi khi xóa phiếu: " + ex.getMessage());
        }
        WebUtil.redirect(request, response, "/admin/receipts");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        try {
            if ("create".equals(action)) {
                createReceipt(request, response);
            } else if ("updateStatus".equals(action)) {
                updateReceiptStatus(request, response);
            } else if ("updateInvoiceImage".equals(action)) {
                updateInvoiceImage(request, response);
            } else if ("updateReceivingImages".equals(action)) {
                updateReceivingImages(request, response);
            } else {
                WebUtil.redirect(request, response, "/admin/receipts");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            WebUtil.redirect(request, response, "/admin/receipts");
        }
    }

    private void createReceipt(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        
        User currentUser = WebUtil.currentUser(request);
        
        Receipt r = new Receipt();
        r.setReceiptCode(WebUtil.param(request, "receiptCode"));
        r.setSupplierId(Long.parseLong(WebUtil.param(request, "supplierId")));
        r.setCreatedBy(currentUser.getId());
        r.setNotes(WebUtil.param(request, "notes"));
        r.setInvoiceImage(handleFileUpload(request));
        if (r.getInvoiceImage() == null || r.getInvoiceImage().trim().isEmpty()) {
            WebUtil.setFlashError(request, "Lỗi: Bắt buộc phải có ảnh hóa đơn yêu cầu nhập kho!");
            WebUtil.redirect(request, response, "/admin/receipts?action=create");
            return;
        }
        
        String status = WebUtil.param(request, "status");
        if (status == null || status.trim().isEmpty()) {
            status = "DRAFT";
        }
        r.setStatus(status);

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
        
        String msg = "DRAFT".equals(status) ? "Đã tạo bản nháp phiếu nhập kho thành công" : "Đã gửi yêu cầu phê duyệt phiếu nhập kho thành công";
        WebUtil.setFlashSuccess(request, msg);
        WebUtil.redirect(request, response, "/admin/receipts");
    }

    private void updateReceiptStatus(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String status = WebUtil.param(request, "status");
        
        User currentUser = WebUtil.currentUser(request);
        long userId = currentUser != null ? currentUser.getId() : 1L;
        
        if ("RECEIVING".equals(status)) {
            String receivingImages = handleMultipleFilesUpload(request, "receivingImagesFiles");
            if (receivingImages == null || receivingImages.trim().isEmpty()) {
                WebUtil.setFlashError(request, "Lỗi: Bắt buộc phải chụp/tải lên ảnh hàng hóa đã nhận làm bằng chứng khi đến bước nhận hàng!");
                WebUtil.redirect(request, response, "/admin/receipts?action=view&id=" + id);
                return;
            }
            receiptDAO.updateStatus(id, status, receivingImages, userId);
        } else {
            receiptDAO.updateStatus(id, status, userId);
        }
        
        String msg = "Đã cập nhật trạng thái phiếu nhập";
        if ("PENDING_APPROVAL".equals(status)) msg = "Đã gửi yêu cầu phê duyệt phiếu nhập";
        else if ("APPROVED".equals(status)) msg = "Đã phê duyệt phiếu nhập";
        else if ("RECEIVING".equals(status)) msg = "Bắt đầu nhận hàng vào kho";
        else if ("COMPLETED".equals(status)) msg = "Đã hoàn thành cất hàng và cập nhật tồn kho";
        else if ("CANCELLED".equals(status)) msg = "Đã hủy phiếu nhập";
        
        WebUtil.setFlashSuccess(request, msg);
        WebUtil.redirect(request, response, "/admin/receipts?action=view&id=" + id);
    }

    private void updateInvoiceImage(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String imageUrl = handleFileUpload(request);
        if (imageUrl != null) {
            receiptDAO.updateInvoiceImage(id, imageUrl);
            WebUtil.setFlashSuccess(request, "Đã cập nhật ảnh hóa đơn thành công");
        } else {
            WebUtil.setFlashError(request, "Lỗi: Không thể tải ảnh lên hoặc ảnh trống");
        }
        WebUtil.redirect(request, response, "/admin/receipts?action=view&id=" + id);
    }

    private void updateReceivingImages(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String imageUrls = handleMultipleFilesUpload(request, "receivingImagesFiles");
        if (imageUrls != null) {
            receiptDAO.updateReceivingImages(id, imageUrls);
            WebUtil.setFlashSuccess(request, "Đã cập nhật ảnh nhận hàng thành công");
        } else {
            WebUtil.setFlashError(request, "Lỗi: Không thể tải ảnh lên hoặc số lượng ảnh trống");
        }
        WebUtil.redirect(request, response, "/admin/receipts?action=view&id=" + id);
    }

    private String handleFileUpload(HttpServletRequest request) throws ServletException, IOException {
        String contentType = request.getContentType();
        if (contentType == null || !contentType.toLowerCase().startsWith("multipart/form-data")) {
            return null;
        }
        
        try {
            jakarta.servlet.http.Part filePart = request.getPart("invoiceImageFile");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = java.nio.file.Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String extension = "";
                int i = fileName.lastIndexOf('.');
                if (i > 0) {
                    extension = fileName.substring(i);
                }
                String uniqueFileName = "rec_" + System.currentTimeMillis() + "_" + java.util.UUID.randomUUID().toString().substring(0, 8) + extension;
                
                String relativePath = "uploads/receipts/" + uniqueFileName;
                
                // 1. Deploy path
                String deployPath = request.getServletContext().getRealPath("/") + "uploads/receipts";
                java.io.File deployDir = new java.io.File(deployPath);
                if (!deployDir.exists()) deployDir.mkdirs();
                filePart.write(deployPath + java.io.File.separator + uniqueFileName);
                
                // 2. Source path
                String workspacePath = "d:\\SP_SWP\\Vinh-Phase4.1\\SWP_WMS\\WarehouseManagementSystem(WMS)";
                String srcPath = workspacePath + java.io.File.separator + "web" + java.io.File.separator + "uploads" + java.io.File.separator + "receipts";
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
                    String uniqueFileName = "recv_" + System.currentTimeMillis() + "_" + java.util.UUID.randomUUID().toString().substring(0, 8) + extension;
                    
                    String relativePath = "uploads/receipts/" + uniqueFileName;
                    
                    // 1. Deploy path
                    String deployPath = request.getServletContext().getRealPath("/") + "uploads/receipts";
                    java.io.File deployDir = new java.io.File(deployPath);
                    if (!deployDir.exists()) deployDir.mkdirs();
                    part.write(deployPath + java.io.File.separator + uniqueFileName);
                    
                    // 2. Source path
                    String workspacePath = "d:\\SP_SWP\\Vinh-Phase4.1\\SWP_WMS\\WarehouseManagementSystem(WMS)";
                    String srcPath = workspacePath + java.io.File.separator + "web" + java.io.File.separator + "uploads" + java.io.File.separator + "receipts";
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
