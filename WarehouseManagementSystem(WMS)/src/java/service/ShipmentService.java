package service;

import dao.InventoryDAO;
import dao.ProductDAO;
import dao.ShipmentDAO;
import model.Inventory;
import model.Product;
import model.Shipment;
import model.ShipmentDetail;
import model.User;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class ShipmentService {

    private final ShipmentDAO shipmentDAO = new ShipmentDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();

    public static class ShipmentPageResult {
        private final List<Shipment> shipments;
        private final int pendingCount;
        private final int approvedCount;
        private final int shippingCount;
        private final int completedCount;
        private final int currentPage;
        private final int totalPages;
        private final int totalItems;
        private final int limit;
        private final List<User> creators;

        public ShipmentPageResult(List<Shipment> shipments, int pendingCount, int approvedCount, int shippingCount, int completedCount, int currentPage, int totalPages, int totalItems, int limit, List<User> creators) {
            this.shipments = shipments;
            this.pendingCount = pendingCount;
            this.approvedCount = approvedCount;
            this.shippingCount = shippingCount;
            this.completedCount = completedCount;
            this.currentPage = currentPage;
            this.totalPages = totalPages;
            this.totalItems = totalItems;
            this.limit = limit;
            this.creators = creators;
        }

        public List<Shipment> getShipments() { return shipments; }
        public int getPendingCount() { return pendingCount; }
        public int getApprovedCount() { return approvedCount; }
        public int getShippingCount() { return shippingCount; }
        public int getCompletedCount() { return completedCount; }
        public int getCurrentPage() { return currentPage; }
        public int getTotalPages() { return totalPages; }
        public int getTotalItems() { return totalItems; }
        public int getLimit() { return limit; }
        public List<User> getCreators() { return creators; }
    }

    public ShipmentPageResult getShipmentsPaginated(int requestedPage, int requestedLimit, String search, String status, Long creatorId, String startDate, String endDate) throws SQLException {
        List<Shipment> allShipments = shipmentDAO.getAll();
        int pendingCount = 0;
        int approvedCount = 0;
        int shippingCount = 0;
        int completedCount = 0;

        for (Shipment s : allShipments) {
            if ("PENDING".equals(s.getStatus())) {
                pendingCount++;
            } else if ("APPROVED".equals(s.getStatus())) {
                approvedCount++;
            } else if ("PICKING".equals(s.getStatus())) {
                shippingCount++;
            } else if ("COMPLETED".equals(s.getStatus())) {
                completedCount++;
            }
        }

        int page = requestedPage < 1 ? 1 : requestedPage;
        int limit = requestedLimit < 1 ? 10 : requestedLimit;
        String query = search == null ? null : search.trim();
        String st = status == null ? null : status.trim();
        String start = startDate == null ? null : startDate.trim();
        String end = endDate == null ? null : endDate.trim();

        List<Shipment> paginatedShipments = shipmentDAO.findPaginated(page, limit, query, st, creatorId, start, end);
        int totalItems = shipmentDAO.count(query, st, creatorId, start, end);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        if (totalPages < 1) totalPages = 1;

        List<User> creators = shipmentDAO.getCreators();

        return new ShipmentPageResult(paginatedShipments, pendingCount, approvedCount, shippingCount, completedCount, page, totalPages, totalItems, limit, creators);
    }

    public Shipment getById(long id) throws SQLException {
        return shipmentDAO.getById(id);
    }

    public List<Product> getAllProducts() throws SQLException {
        return productDAO.getAll();
    }

    public List<Inventory> getAllInventories() throws SQLException {
        return inventoryDAO.getAll();
    }

    public void deleteDraft(long id) throws SQLException {
        shipmentDAO.deleteDraft(id);
    }

    public void createShipment(String shipmentCode, String destination, User currentUser, String notes, String status, String[] productIds, String[] quantities, String[] batchCodes, String[] barcodes, String singleProductId, String singleQty) throws SQLException, IllegalArgumentException {
        if (currentUser == null) {
            throw new IllegalArgumentException("Người dùng chưa đăng nhập.");
        }

        Shipment s = new Shipment();
        s.setShipmentCode(shipmentCode != null ? shipmentCode.trim() : "");
        s.setDestination(destination != null ? destination.trim() : "");
        s.setCreatedBy(currentUser.getId());
        s.setNotes(notes != null ? notes.trim() : "");
        s.setStatus((status == null || status.trim().isEmpty()) ? "PENDING" : status.trim());

        if (productIds == null || productIds.length == 0) {
            if (singleProductId != null && !singleProductId.trim().isEmpty() && singleQty != null && !singleQty.trim().isEmpty()) {
                ShipmentDetail sd = new ShipmentDetail();
                sd.setProductId(Long.parseLong(singleProductId.trim()));
                sd.setQuantity(Integer.parseInt(singleQty.trim()));
                if (batchCodes != null && batchCodes.length > 0) sd.setBatchCode(batchCodes[0]);
                if (barcodes != null && barcodes.length > 0) sd.setBarcode(barcodes[0]);
                if (sd.getQuantity() > 0) {
                    s.getDetails().add(sd);
                }
            }
        } else {
            for (int i = 0; i < productIds.length; i++) {
                if (productIds[i] != null && !productIds[i].trim().isEmpty() && quantities != null && i < quantities.length && quantities[i] != null && !quantities[i].trim().isEmpty()) {
                    int qty = Integer.parseInt(quantities[i].trim());
                    if (qty > 0) {
                        ShipmentDetail sd = new ShipmentDetail();
                        sd.setProductId(Long.parseLong(productIds[i].trim()));
                        sd.setQuantity(qty);
                        if (batchCodes != null && i < batchCodes.length) sd.setBatchCode(batchCodes[i]);
                        if (barcodes != null && i < barcodes.length) sd.setBarcode(barcodes[i]);
                        s.getDetails().add(sd);
                    }
                }
            }
        }

        if (s.getDetails().isEmpty()) {
            throw new IllegalArgumentException("Lỗi: Vui lòng thêm ít nhất 1 sản phẩm với số lượng > 0");
        }

        try {
            shipmentDAO.insertWithDetails(s);
        } catch (SQLException ex) {
            throw new IllegalArgumentException("Lỗi tạo yêu cầu xuất kho: " + ex.getMessage());
        }
    }

    public String updateShipmentStatus(long id, String status, String uploadedShippingImages, String deliveryNoteImage, User currentUser) throws SQLException, IllegalArgumentException {
        long userId = currentUser != null ? currentUser.getId() : 1L;

        if ("COMPLETED".equals(status)) {
            Shipment shipment = shipmentDAO.getById(id);
            String existingImages = (shipment != null) ? shipment.getShippingImages() : null;
            String shippingImages = existingImages;

            if (uploadedShippingImages != null && !uploadedShippingImages.trim().isEmpty()) {
                if (existingImages != null && !existingImages.trim().isEmpty()) {
                    shippingImages = existingImages + "," + uploadedShippingImages.trim();
                } else {
                    shippingImages = uploadedShippingImages.trim();
                }
            }

            try {
                shipmentDAO.updateStatus(id, status, deliveryNoteImage, shippingImages, userId);
                return "Đã xác nhận xuất kho thành công và trừ tồn kho (PGI)!";
            } catch (SQLException ex) {
                throw new IllegalArgumentException("Lỗi khi hoàn thành xuất kho (PGI): " + ex.getMessage());
            }
        } else {
            try {
                shipmentDAO.updateStatus(id, status, userId);
                String msg = "Đã cập nhật trạng thái phiếu xuất";
                if ("PENDING".equals(status)) msg = "Đã gửi yêu cầu xuất kho";
                else if ("APPROVED".equals(status)) msg = "Đã tạo phiếu xuất kho thành công";
                else if ("PICKING".equals(status)) msg = "Bắt đầu lấy hàng & đóng gói";
                else if ("CANCELLED".equals(status)) msg = "Đã hủy phiếu xuất kho và hoàn trả tồn kho (nếu có)";
                return msg;
            } catch (SQLException ex) {
                throw new IllegalArgumentException("Lỗi cập nhật trạng thái: " + ex.getMessage());
            }
        }
    }

    public void updateShippingImages(long id, String imageUrls) throws SQLException, IllegalArgumentException {
        if (imageUrls == null || imageUrls.trim().isEmpty()) {
            throw new IllegalArgumentException("Lỗi: Không thể tải ảnh lên hoặc số lượng ảnh trống");
        }
        Shipment shipment = shipmentDAO.getById(id);
        String finalUrls = imageUrls;
        if (shipment != null && shipment.getShippingImages() != null && !shipment.getShippingImages().trim().isEmpty()) {
            finalUrls = shipment.getShippingImages() + "," + imageUrls;
        }
        shipmentDAO.updateShippingImages(id, finalUrls);
    }

    public void deleteShippingImage(long id, String imageUrl) throws SQLException {
        Shipment shipment = shipmentDAO.getById(id);
        if (shipment != null && imageUrl != null) {
            List<String> list = shipment.getShippingImagesList();
            list.remove(imageUrl.trim());
            String newImages = String.join(",", list);
            shipmentDAO.updateShippingImages(id, newImages.trim().isEmpty() ? null : newImages);
        }
    }

    public List<Map<String, Object>> getAvailableInventoryBatches(long productId) throws SQLException {
        return shipmentDAO.getAvailableInventoryBatches(productId);
    }

    public void updateManualBatches(long shipmentId, String[] detailIds, String[] batchCodes, String[] barcodes) throws SQLException, IllegalArgumentException {
        if (detailIds == null || detailIds.length == 0) {
            throw new IllegalArgumentException("Lỗi: Không tìm thấy danh sách chi tiết cần cập nhật");
        }

        for (int i = 0; i < detailIds.length; i++) {
            if (detailIds[i] != null && !detailIds[i].trim().isEmpty()) {
                long detailId = Long.parseLong(detailIds[i].trim());
                String batchCode = (batchCodes != null && i < batchCodes.length) ? batchCodes[i] : "";
                String barcode = (barcodes != null && i < barcodes.length) ? barcodes[i] : "";
                shipmentDAO.updateDetailBatchesAndBarcodes(detailId, batchCode, barcode);
            }
        }
    }
}
