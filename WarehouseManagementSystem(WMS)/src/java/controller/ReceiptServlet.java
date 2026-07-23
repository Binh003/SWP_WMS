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
                case "deleteReceivingImage" -> deleteReceivingImage(request, response);
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
            } else if ("APPROVED".equals(r.getStatus()) || "RECEIVING".equals(r.getStatus()) || "RECEIVED".equals(r.getStatus())) {
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
        
        request.getRequestDispatcher("/jsp/manage/receipts.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("suppliers", supplierDAO.getAll());
        request.setAttribute("products", productDAO.getAll());
        
        // Generate a random code for initial draft or use auto generated
        String generatedCode = "PN-" + System.currentTimeMillis();
        request.setAttribute("generatedCode", generatedCode);
        
        request.getRequestDispatcher("/jsp/manage/receipt-form.jsp").forward(request, response);
    }

    private void viewReceipt(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Receipt receipt = receiptDAO.getById(id);
        if (receipt == null) {
            WebUtil.setFlashError(request, "Không tìm thấy phiếu nhập");
            WebUtil.redirect(request, response, "/manage/receipts");
            return;
        }
        request.setAttribute("receipt", receipt);
        request.getRequestDispatcher("/jsp/manage/receipt-detail.jsp").forward(request, response);
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
        WebUtil.redirect(request, response, "/manage/receipts");
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
            } else if ("deleteReceivingImage".equals(action)) {
                deleteReceivingImage(request, response);
            } else {
                WebUtil.redirect(request, response, "/manage/receipts");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            WebUtil.redirect(request, response, "/manage/receipts");
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
            WebUtil.redirect(request, response, "/manage/receipts?action=create");
            return;
        }
        
        String status = WebUtil.param(request, "status");
        if (status == null || status.trim().isEmpty()) {
            status = "PENDING_APPROVAL";
        }
        r.setStatus(status);

        String[] productIds = request.getParameterValues("productId[]");
        String[] quantities = request.getParameterValues("quantity[]");
        
        if (productIds == null || productIds.length == 0) {
            WebUtil.setFlashError(request, "Lỗi: Vui lòng chọn ít nhất 1 sản phẩm nhập kho!");
            WebUtil.redirect(request, response, "/manage/receipts?action=create");
            return;
        }
        
        for (int i = 0; i < productIds.length; i++) {
            if (productIds[i] != null && !productIds[i].trim().isEmpty()) {
                if (quantities != null && i < quantities.length && quantities[i] != null) {
                    int qty = Integer.parseInt(quantities[i]);
                    if (qty > 0) {
                        ReceiptDetail rd = new ReceiptDetail();
                        rd.setProductId(Long.parseLong(productIds[i]));
                        rd.setQuantity(qty);
                        // Batch Code and Barcode are confirmed later by Warehouse Staff
                        // during the RECEIVING step. They must remain NULL at creation time.
                        rd.setBatchCode(null);
                        rd.setBarcode(null);
                        r.getDetails().add(rd);
                    }
                }
            }
        }
        
        if (r.getDetails().isEmpty()) {
            WebUtil.setFlashError(request, "Lỗi: Vui lòng thêm ít nhất 1 sản phẩm với số lượng > 0");
            WebUtil.redirect(request, response, "/manage/receipts?action=create");
            return;
        }

        receiptDAO.insertWithDetails(r);
        
        String msg = "DRAFT".equals(status) ? "Đã tạo bản nháp phiếu nhập kho thành công" : "Đã gửi yêu cầu phê duyệt phiếu nhập kho thành công";
        WebUtil.setFlashSuccess(request, msg);
        WebUtil.redirect(request, response, "/manage/receipts");
    }

    private void updateReceiptStatus(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String status = WebUtil.param(request, "status");
        
        User currentUser = WebUtil.currentUser(request);
        long userId = currentUser != null ? currentUser.getId() : 1L;
        
        if ("RECEIVED".equals(status)) {
            Receipt receipt = receiptDAO.getById(id);
            String existingImages = (receipt != null) ? receipt.getReceivingImages() : null;
            String newUploadedImages = handleMultipleFilesUpload(request, "receivingImagesFiles");
            
            String receivingImages = existingImages;
            if (newUploadedImages != null && !newUploadedImages.trim().isEmpty()) {
                if (existingImages != null && !existingImages.trim().isEmpty()) {
                    receivingImages = existingImages + "," + newUploadedImages;
                } else {
                    receivingImages = newUploadedImages;
                }
            }
            
            if (receivingImages == null || receivingImages.trim().isEmpty()) {
                WebUtil.setFlashError(request, "Lỗi: Bắt buộc phải chụp/tải lên ảnh hàng hóa đã nhận làm bằng chứng khi xác nhận nhận hàng!");
                WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
                return;
            }
            List<ReceiptDetail> updatedDetails = new ArrayList<>();
            if (receipt == null || receipt.getDetails() == null || receipt.getDetails().isEmpty()) {
                WebUtil.setFlashError(request, "Lỗi: Phiếu nhập không có sản phẩm để xác nhận.");
                WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
                return;
            }

            java.util.Set<String> allReceiptBarcodes = new java.util.HashSet<>();

            for (ReceiptDetail detail : receipt.getDetails()) {
                String quantityValue = request.getParameter("actualQuantity_" + detail.getId());
                String batchCode = trimToNull(request.getParameter("batchCode_" + detail.getId()));
                String[] submittedBarcodes = request.getParameterValues("barcode_" + detail.getId());

                if (quantityValue == null || quantityValue.trim().isEmpty()) {
                    WebUtil.setFlashError(request,
                        "Lỗi: Vui lòng nhập số lượng thực nhận cho sản phẩm " + detail.getProduct().getName());
                    WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
                    return;
                }

                int actualQty;
                try {
                    actualQty = Integer.parseInt(quantityValue.trim());
                } catch (NumberFormatException e) {
                    WebUtil.setFlashError(request,
                        "Lỗi: Số lượng thực nhận không hợp lệ cho sản phẩm " + detail.getProduct().getName());
                    WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
                    return;
                }

                if (actualQty <= 0) {
                    WebUtil.setFlashError(request,
                        "Lỗi: Số lượng thực nhận phải lớn hơn 0 cho sản phẩm " + detail.getProduct().getName());
                    WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
                    return;
                }

                if (batchCode == null) {
                    WebUtil.setFlashError(request,
                        "Lỗi: Vui lòng nhập hoặc tạo Batch Code cho sản phẩm " + detail.getProduct().getName());
                    WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
                    return;
                }

                List<String> barcodeList = new ArrayList<>();
                if (submittedBarcodes != null) {
                    for (String submittedBarcode : submittedBarcodes) {
                        String barcode = trimToNull(submittedBarcode);
                        if (barcode != null) barcodeList.add(barcode);
                    }
                }

                if (barcodeList.size() != actualQty) {
                    WebUtil.setFlashError(request,
                        "Lỗi: Sản phẩm " + detail.getProduct().getName()
                        + " có số lượng thực nhận là " + actualQty
                        + " nên phải có đúng " + actualQty + " Barcode.");
                    WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
                    return;
                }

                java.util.Set<String> detailBarcodeSet = new java.util.HashSet<>();
                for (String barcode : barcodeList) {
                    String normalizedBarcode = barcode.toUpperCase();
                    if (!detailBarcodeSet.add(normalizedBarcode)) {
                        WebUtil.setFlashError(request,
                            "Lỗi: Barcode " + barcode + " đang bị trùng trong sản phẩm "
                            + detail.getProduct().getName() + ".");
                        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
                        return;
                    }
                    if (!allReceiptBarcodes.add(normalizedBarcode)) {
                        WebUtil.setFlashError(request,
                            "Lỗi: Barcode " + barcode + " đang bị trùng trong phiếu nhập.");
                        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
                        return;
                    }
                }

                ReceiptDetail updated = new ReceiptDetail();
                updated.setId(detail.getId());
                updated.setProductId(detail.getProductId());
                updated.setQuantity(actualQty);
                updated.setBatchCode(batchCode);
                // Lưu danh sách Barcode trong cột barcode, phân cách bằng dấu phẩy.
                updated.setBarcode(String.join(",", barcodeList));
                updatedDetails.add(updated);
            }

            receiptDAO.updateStatus(id, status, receivingImages, userId, updatedDetails);
        } else {
            receiptDAO.updateStatus(id, status, userId);
        }
        
        String msg = "Đã cập nhật trạng thái phiếu nhập";
        if ("PENDING_APPROVAL".equals(status)) msg = "Đã gửi yêu cầu phê duyệt phiếu nhập";
        else if ("APPROVED".equals(status)) msg = "Đã phê duyệt phiếu nhập";
        else if ("RECEIVING".equals(status)) msg = "Bắt đầu nhận hàng vào kho";
        else if ("RECEIVED".equals(status)) msg = "Đã tạo đơn nhận hàng thành công và ghi nhận thực nhận";
        else if ("COMPLETED".equals(status)) msg = "Đã hoàn thành nhập kho (cất hàng) và cập nhật tồn kho";
        else if ("CANCELLED".equals(status)) msg = "Đã hủy phiếu nhập";
        
        WebUtil.setFlashSuccess(request, msg);
        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
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
        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
    }

    private void updateReceivingImages(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String imageUrls = handleMultipleFilesUpload(request, "receivingImagesFiles");
        if (imageUrls != null && !imageUrls.trim().isEmpty()) {
            Receipt receipt = receiptDAO.getById(id);
            if (receipt != null && receipt.getReceivingImages() != null && !receipt.getReceivingImages().trim().isEmpty()) {
                imageUrls = receipt.getReceivingImages() + "," + imageUrls;
            }
            receiptDAO.updateReceivingImages(id, imageUrls);
            WebUtil.setFlashSuccess(request, "Đã cập nhật ảnh nhận hàng thành công");
        } else {
            WebUtil.setFlashError(request, "Lỗi: Không thể tải ảnh lên hoặc số lượng ảnh trống");
        }
        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
    }

    private void deleteReceivingImage(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String imageUrl = WebUtil.param(request, "imageUrl");
        
        Receipt receipt = receiptDAO.getById(id);
        if (receipt != null && imageUrl != null) {
            List<String> list = receipt.getReceivingImagesList();
            list.remove(imageUrl.trim());
            String newImages = String.join(",", list);
            receiptDAO.updateReceivingImages(id, newImages.trim().isEmpty() ? null : newImages);
            WebUtil.setFlashSuccess(request, "Đã xóa ảnh bằng chứng thành công");
        }
        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
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
                String workspacePath = util.WebUtil.getWorkspacePath(request);
                if (workspacePath != null) {
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
                    String workspacePath = util.WebUtil.getWorkspacePath(request);
                    if (workspacePath != null) {
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