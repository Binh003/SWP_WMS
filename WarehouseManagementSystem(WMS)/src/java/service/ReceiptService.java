package service;

import dao.ProductDAO;
import dao.ReceiptDAO;
import dao.SupplierDAO;
import model.Product;
import model.Receipt;
import model.ReceiptDetail;
import model.Supplier;
import model.User;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ReceiptService {

    private final ReceiptDAO receiptDAO = new ReceiptDAO();
    private final SupplierDAO supplierDAO = new SupplierDAO();
    private final ProductDAO productDAO = new ProductDAO();

    public static class ReceiptPageResult {
        private final List<Receipt> receipts;
        private final int pendingCount;
        private final int processingCount;
        private final int completedCount;
        private final int currentPage;
        private final int totalPages;
        private final int totalItems;
        private final int limit;
        private final List<Supplier> allSuppliers;
        private final List<User> creators;

        public ReceiptPageResult(List<Receipt> receipts, int pendingCount, int processingCount, int completedCount, int currentPage, int totalPages, int totalItems, int limit, List<Supplier> allSuppliers, List<User> creators) {
            this.receipts = receipts;
            this.pendingCount = pendingCount;
            this.processingCount = processingCount;
            this.completedCount = completedCount;
            this.currentPage = currentPage;
            this.totalPages = totalPages;
            this.totalItems = totalItems;
            this.limit = limit;
            this.allSuppliers = allSuppliers;
            this.creators = creators;
        }

        public List<Receipt> getReceipts() { return receipts; }
        public int getPendingCount() { return pendingCount; }
        public int getProcessingCount() { return processingCount; }
        public int getCompletedCount() { return completedCount; }
        public int getCurrentPage() { return currentPage; }
        public int getTotalPages() { return totalPages; }
        public int getTotalItems() { return totalItems; }
        public int getLimit() { return limit; }
        public List<Supplier> getAllSuppliers() { return allSuppliers; }
        public List<User> getCreators() { return creators; }
    }

    public ReceiptPageResult getReceiptsPaginated(int requestedPage, int requestedLimit, String search, String status, Long supplierId, Long creatorId, String startDate, String endDate) throws SQLException {
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

        int page = requestedPage < 1 ? 1 : requestedPage;
        int limit = requestedLimit < 1 ? 10 : requestedLimit;
        String query = search == null ? null : search.trim();
        String st = status == null ? null : status.trim();
        String start = startDate == null ? null : startDate.trim();
        String end = endDate == null ? null : endDate.trim();

        List<Receipt> paginatedReceipts = receiptDAO.findPaginated(page, limit, query, st, supplierId, creatorId, start, end);
        int totalItems = receiptDAO.count(query, st, supplierId, creatorId, start, end);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        if (totalPages < 1) totalPages = 1;

        List<Supplier> suppliers = supplierDAO.getAll();
        List<User> creators = receiptDAO.getCreators();

        return new ReceiptPageResult(paginatedReceipts, pendingCount, processingCount, completedCount, page, totalPages, totalItems, limit, suppliers, creators);
    }

    public Receipt getById(long id) throws SQLException {
        return receiptDAO.getById(id);
    }

    public List<Supplier> getAllSuppliers() throws SQLException {
        return supplierDAO.getAll();
    }

    public List<Product> getAllProducts() throws SQLException {
        return productDAO.getAll();
    }

    public void deleteDraft(long id) throws SQLException {
        receiptDAO.deleteDraft(id);
    }

    public String createReceipt(String receiptCode, long supplierId, User currentUser, String notes, String invoiceImage, String status, String[] productIds, String[] quantities) throws SQLException, IllegalArgumentException {
        if (currentUser == null) {
            throw new IllegalArgumentException("Người dùng chưa đăng nhập.");
        }

        if (invoiceImage == null || invoiceImage.trim().isEmpty()) {
            throw new IllegalArgumentException("Lỗi: Bắt buộc phải có ảnh hóa đơn yêu cầu nhập kho!");
        }

        String st = (status == null || status.trim().isEmpty()) ? "PENDING_APPROVAL" : status.trim();

        if (productIds == null || productIds.length == 0) {
            throw new IllegalArgumentException("Lỗi: Vui lòng chọn ít nhất 1 sản phẩm nhập kho!");
        }

        Receipt r = new Receipt();
        r.setReceiptCode(receiptCode != null ? receiptCode.trim() : "");
        r.setSupplierId(supplierId);
        r.setCreatedBy(currentUser.getId());
        r.setNotes(notes != null ? notes.trim() : "");
        r.setInvoiceImage(invoiceImage);
        r.setStatus(st);

        for (int i = 0; i < productIds.length; i++) {
            if (productIds[i] != null && !productIds[i].trim().isEmpty()) {
                if (quantities != null && i < quantities.length && quantities[i] != null) {
                    try {
                        int qty = Integer.parseInt(quantities[i].trim());
                        if (qty > 0) {
                            ReceiptDetail rd = new ReceiptDetail();
                            rd.setProductId(Long.parseLong(productIds[i].trim()));
                            rd.setQuantity(qty);
                            rd.setBatchCode(null);
                            rd.setBarcode(null);
                            r.getDetails().add(rd);
                        }
                    } catch (NumberFormatException ignored) {}
                }
            }
        }

        if (r.getDetails().isEmpty()) {
            throw new IllegalArgumentException("Lỗi: Vui lòng thêm ít nhất 1 sản phẩm với số lượng > 0");
        }

        receiptDAO.insertWithDetails(r);

        return "DRAFT".equals(st) ? "Đã tạo bản nháp phiếu nhập kho thành công" : "Đã gửi yêu cầu phê duyệt phiếu nhập kho thành công";
    }

    public String updateReceiptStatus(long id, String requestedStatus, String uploadedReceivingImages, User currentUser, java.util.Map<String, String[]> requestParams) throws SQLException, IllegalArgumentException {
        Receipt receipt = receiptDAO.getById(id);
        if (receipt == null) {
            throw new IllegalArgumentException("Không tìm thấy phiếu nhập");
        }

        String status = requestedStatus;
        if (status == null || status.trim().isEmpty()) {
            if ("RECEIVING".equals(receipt.getStatus())) {
                status = "RECEIVED";
            } else {
                status = receipt.getStatus();
            }
        }

        long userId = currentUser != null ? currentUser.getId() : 1L;

        if ("RECEIVED".equals(status)) {
            String existingImages = receipt.getReceivingImages();
            String receivingImages = existingImages;

            if (uploadedReceivingImages != null && !uploadedReceivingImages.trim().isEmpty()) {
                if (existingImages != null && !existingImages.trim().isEmpty()) {
                    receivingImages = existingImages + "," + uploadedReceivingImages.trim();
                } else {
                    receivingImages = uploadedReceivingImages.trim();
                }
            }

            if (receivingImages == null || receivingImages.trim().isEmpty()) {
                throw new IllegalArgumentException("Lỗi: Bắt buộc phải chụp/tải lên ảnh hàng hóa đã nhận làm bằng chứng khi xác nhận nhận hàng!");
            }

            if (receipt.getDetails() == null || receipt.getDetails().isEmpty()) {
                throw new IllegalArgumentException("Lỗi: Phiếu nhập không có sản phẩm để xác nhận.");
            }

            List<ReceiptDetail> updatedDetails = new ArrayList<>();
            Set<String> allReceiptBarcodes = new HashSet<>();

            for (ReceiptDetail detail : receipt.getDetails()) {
                String quantityValue = getSingleParam(requestParams, "actualQuantity_" + detail.getId());
                String batchCode = trimToNull(getSingleParam(requestParams, "batchCode_" + detail.getId()));
                String[] submittedBarcodes = requestParams.get("barcode_" + detail.getId());

                int actualQty;
                if (quantityValue == null || quantityValue.trim().isEmpty()) {
                    actualQty = (detail.getQuantity() != null && detail.getQuantity() > 0) ? detail.getQuantity() : 1;
                } else {
                    try {
                        actualQty = Integer.parseInt(quantityValue.trim());
                    } catch (NumberFormatException e) {
                        actualQty = (detail.getQuantity() != null && detail.getQuantity() > 0) ? detail.getQuantity() : 1;
                    }
                }

                if (actualQty <= 0) {
                    throw new IllegalArgumentException("Lỗi: Số lượng thực nhận phải lớn hơn 0 cho sản phẩm " + detail.getProduct().getName());
                }

                if (batchCode == null || batchCode.trim().isEmpty()) {
                    batchCode = "BAT-" + receipt.getReceiptCode() + "-" + detail.getId();
                }

                List<String> barcodeList = new ArrayList<>();
                if (submittedBarcodes != null) {
                    for (String submittedBarcode : submittedBarcodes) {
                        String barcode = trimToNull(submittedBarcode);
                        if (barcode != null) {
                            barcodeList.add(barcode);
                        }
                    }
                }

                if (barcodeList.size() != actualQty) {
                    barcodeList = new ArrayList<>();
                    for (int k = 1; k <= actualQty; k++) {
                        barcodeList.add("BC-" + receipt.getReceiptCode() + "-" + detail.getId() + "-" + k);
                    }
                }

                Set<String> detailBarcodeSet = new HashSet<>();
                for (String barcode : barcodeList) {
                    String normalizedBarcode = barcode.toUpperCase();
                    if (!detailBarcodeSet.add(normalizedBarcode)) {
                        throw new IllegalArgumentException("Lỗi: Barcode " + barcode + " đang bị trùng trong sản phẩm " + detail.getProduct().getName() + ".");
                    }
                    if (!allReceiptBarcodes.add(normalizedBarcode)) {
                        throw new IllegalArgumentException("Lỗi: Barcode " + barcode + " đang bị trùng trong phiếu nhập.");
                    }
                }

                ReceiptDetail updated = new ReceiptDetail();
                updated.setId(detail.getId());
                updated.setProductId(detail.getProductId());
                updated.setQuantity(actualQty);
                updated.setBatchCode(batchCode);
                updated.setBarcode(String.join(",", barcodeList));
                updatedDetails.add(updated);
            }

            receiptDAO.updateStatus(id, status, receivingImages, userId, updatedDetails);
        } else {
            receiptDAO.updateStatus(id, status, userId);
        }

        String msg = "Đã cập nhật trạng thái phiếu nhập";
        if ("PENDING_APPROVAL".equals(status)) {
            msg = "Đã gửi yêu cầu phê duyệt phiếu nhập";
        } else if ("APPROVED".equals(status)) {
            msg = "Đã phê duyệt phiếu nhập";
        } else if ("RECEIVING".equals(status)) {
            msg = "Bắt đầu nhận hàng vào kho";
        } else if ("RECEIVED".equals(status)) {
            msg = "Đã tạo đơn nhận hàng thành công và ghi nhận thực nhận";
        } else if ("COMPLETED".equals(status)) {
            msg = "Đã hoàn thành nhập kho (cất hàng) và cập nhật tồn kho";
        } else if ("CANCELLED".equals(status)) {
            msg = "Đã hủy phiếu nhập";
        }

        return msg;
    }

    public void updateInvoiceImage(long id, String imageUrl) throws SQLException, IllegalArgumentException {
        if (imageUrl == null || imageUrl.trim().isEmpty()) {
            throw new IllegalArgumentException("Lỗi: Không thể tải ảnh lên hoặc ảnh trống");
        }
        receiptDAO.updateInvoiceImage(id, imageUrl);
    }

    public void updateReceivingImages(long id, String imageUrls) throws SQLException, IllegalArgumentException {
        if (imageUrls == null || imageUrls.trim().isEmpty()) {
            throw new IllegalArgumentException("Lỗi: Không thể tải ảnh lên hoặc số lượng ảnh trống");
        }
        Receipt receipt = receiptDAO.getById(id);
        String finalUrls = imageUrls;
        if (receipt != null && receipt.getReceivingImages() != null && !receipt.getReceivingImages().trim().isEmpty()) {
            finalUrls = receipt.getReceivingImages() + "," + imageUrls;
        }
        receiptDAO.updateReceivingImages(id, finalUrls);
    }

    public void deleteReceivingImage(long id, String imageUrl) throws SQLException {
        Receipt receipt = receiptDAO.getById(id);
        if (receipt != null && imageUrl != null) {
            List<String> list = receipt.getReceivingImagesList();
            list.remove(imageUrl.trim());
            String newImages = String.join(",", list);
            receiptDAO.updateReceivingImages(id, newImages.trim().isEmpty() ? null : newImages);
        }
    }

    public void cancelReceipt(long id, User currentUser) throws SQLException, IllegalArgumentException {
        if (currentUser == null) {
            throw new IllegalArgumentException("Bạn chưa đăng nhập.");
        }
        Receipt receipt = receiptDAO.getById(id);
        if (receipt == null) {
            throw new IllegalArgumentException("Không tìm thấy phiếu nhập.");
        }
        if ("COMPLETED".equals(receipt.getStatus()) || "CANCELLED".equals(receipt.getStatus())) {
            throw new IllegalArgumentException("Không thể hủy phiếu ở trạng thái " + receipt.getStatus());
        }
        receiptDAO.updateStatus(id, "CANCELLED", currentUser.getId());
    }

    private String getSingleParam(java.util.Map<String, String[]> params, String key) {
        String[] arr = params.get(key);
        if (arr != null && arr.length > 0) {
            return arr[0];
        }
        return null;
    }

    private String trimToNull(String value) {
        if (value == null) return null;
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
