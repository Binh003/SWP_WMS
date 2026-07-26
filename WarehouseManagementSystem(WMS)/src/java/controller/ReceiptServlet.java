package controller;

import model.Receipt;
import model.User;
import service.ReceiptService;
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
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class ReceiptServlet extends HttpServlet {

    private final ReceiptService receiptService = new ReceiptService();

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

        ReceiptService.ReceiptPageResult result = receiptService.getReceiptsPaginated(page, limit, search, status, supplierId, creatorId, startDate, endDate);

        request.setAttribute("pendingCount", result.getPendingCount());
        request.setAttribute("processingCount", result.getProcessingCount());
        request.setAttribute("completedCount", result.getCompletedCount());
        request.setAttribute("receipts", result.getReceipts());
        request.setAttribute("totalItems", result.getTotalItems());
        request.setAttribute("totalPages", result.getTotalPages());
        request.setAttribute("currentPage", result.getCurrentPage());
        request.setAttribute("limit", result.getLimit());
        request.setAttribute("search", search);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedSupplierId", supplierId);
        request.setAttribute("selectedCreatorId", creatorId);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.setAttribute("suppliers", result.getAllSuppliers());
        request.setAttribute("creators", result.getCreators());

        request.getRequestDispatcher("/jsp/manage/receipts.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        request.setAttribute("suppliers", receiptService.getAllSuppliers());
        request.setAttribute("products", receiptService.getAllProducts());
        String generatedCode = "PN-" + System.currentTimeMillis();
        request.setAttribute("generatedCode", generatedCode);
        request.getRequestDispatcher("/jsp/manage/receipt-form.jsp").forward(request, response);
    }

    private void viewReceipt(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Receipt receipt = receiptService.getById(id);
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
            receiptService.deleteDraft(id);
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
        long id = 0;
        try {
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.trim().isEmpty()) {
                id = Long.parseLong(idParam.trim());
            }
        } catch (Exception ignored) {}

        try {
            if ("create".equals(action)) {
                createReceipt(request, response);
            } else if ("updateStatus".equals(action)) {
                updateReceiptStatus(request, response);
            } else if ("cancelReceipt".equals(action)) {
                cancelReceipt(request, response);
            } else if ("updateInvoiceImage".equals(action)) {
                updateInvoiceImage(request, response);
            } else if ("updateReceivingImages".equals(action)) {
                updateReceivingImages(request, response);
            } else if ("deleteReceivingImage".equals(action)) {
                deleteReceivingImage(request, response);
            } else {
                if (id > 0) {
                    WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
                } else {
                    WebUtil.redirect(request, response, "/manage/receipts");
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            if (id > 0) {
                WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
            } else {
                WebUtil.redirect(request, response, "/manage/receipts");
            }
        }
    }

    private void createReceipt(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        User currentUser = WebUtil.currentUser(request);
        String receiptCode = WebUtil.param(request, "receiptCode");
        long supplierId = Long.parseLong(WebUtil.param(request, "supplierId"));
        String notes = WebUtil.param(request, "notes");
        String invoiceImage = handleFileUpload(request);
        String status = WebUtil.param(request, "status");
        String[] productIds = request.getParameterValues("productId[]");
        String[] quantities = request.getParameterValues("quantity[]");

        try {
            String msg = receiptService.createReceipt(receiptCode, supplierId, currentUser, notes, invoiceImage, status, productIds, quantities);
            WebUtil.setFlashSuccess(request, msg);
            WebUtil.redirect(request, response, "/manage/receipts");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/receipts?action=create");
        }
    }

    private void updateReceiptStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String status = WebUtil.param(request, "status");
        User currentUser = WebUtil.currentUser(request);
        String uploadedImages = handleMultipleFilesUpload(request, "receivingImagesFiles");

        try {
            String msg = receiptService.updateReceiptStatus(id, status, uploadedImages, currentUser, request.getParameterMap());
            WebUtil.setFlashSuccess(request, msg);
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
    }

    private void updateInvoiceImage(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String imageUrl = handleFileUpload(request);
        try {
            receiptService.updateInvoiceImage(id, imageUrl);
            WebUtil.setFlashSuccess(request, "Đã cập nhật ảnh hóa đơn thành công");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
    }

    private void updateReceivingImages(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String imageUrls = handleMultipleFilesUpload(request, "receivingImagesFiles");
        try {
            receiptService.updateReceivingImages(id, imageUrls);
            WebUtil.setFlashSuccess(request, "Đã cập nhật ảnh nhận hàng thành công");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
    }

    private void deleteReceivingImage(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String imageUrl = WebUtil.param(request, "imageUrl");
        receiptService.deleteReceivingImage(id, imageUrl);
        WebUtil.setFlashSuccess(request, "Đã xóa ảnh bằng chứng thành công");
        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
    }

    private void cancelReceipt(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        long id;
        try {
            id = Long.parseLong(WebUtil.param(request, "id"));
        } catch (Exception e) {
            WebUtil.setFlashError(request, "ID phiếu nhập không hợp lệ.");
            WebUtil.redirect(request, response, "/manage/receipts");
            return;
        }

        User currentUser = WebUtil.currentUser(request);

        try {
            receiptService.cancelReceipt(id, currentUser);
            WebUtil.setFlashSuccess(request, "Đã hủy phiếu nhập thành công.");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/receipts?action=view&id=" + id);
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
                if (!deployDir.exists()) {
                    deployDir.mkdirs();
                }
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
                        } catch (Exception ignored) {
                        }
                    }
                }

                return "/" + relativePath;
            }
        } catch (Exception ignored) {
        }

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
                    String uniqueFileName = "recv_" + System.currentTimeMillis() + "_" + java.util.UUID.randomUUID().toString().substring(0, 8) + extension;

                    String relativePath = "uploads/receipts/" + uniqueFileName;

                    // 1. Deploy path
                    String deployPath = request.getServletContext().getRealPath("/") + "uploads/receipts";
                    java.io.File deployDir = new java.io.File(deployPath);
                    if (!deployDir.exists()) {
                        deployDir.mkdirs();
                    }
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
                            } catch (Exception ignored) {
                            }
                        }
                    }

                    uploadedPaths.add("/" + relativePath);
                }
            }
        } catch (Exception ignored) {
        }

        if (uploadedPaths.isEmpty()) {
            return null;
        }
        return String.join(",", uploadedPaths);
    }
}
