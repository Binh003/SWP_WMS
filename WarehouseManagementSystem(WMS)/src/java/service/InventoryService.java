package service;

import dao.BrandDAO;
import dao.InventoryDAO;
import dao.ProductLineDAO;
import model.Brand;
import model.Inventory;
import model.ProductLine;

import java.sql.SQLException;
import java.util.List;

public class InventoryService {

    private final InventoryDAO inventoryDAO = new InventoryDAO();
    private final ProductLineDAO productLineDAO = new ProductLineDAO();
    private final BrandDAO brandDAO = new BrandDAO();

    public static class InventoryPageResult {
        private final List<Inventory> inventories;
        private final List<Brand> allBrands;
        private final List<ProductLine> allProductLines;
        private final int currentPage;
        private final int totalPages;
        private final int totalItems;
        private final int limit;

        public InventoryPageResult(List<Inventory> inventories, List<Brand> allBrands, List<ProductLine> allProductLines, int currentPage, int totalPages, int totalItems, int limit) {
            this.inventories = inventories;
            this.allBrands = allBrands;
            this.allProductLines = allProductLines;
            this.currentPage = currentPage;
            this.totalPages = totalPages;
            this.totalItems = totalItems;
            this.limit = limit;
        }

        public List<Inventory> getInventories() { return inventories; }
        public List<Brand> getAllBrands() { return allBrands; }
        public List<ProductLine> getAllProductLines() { return allProductLines; }
        public int getCurrentPage() { return currentPage; }
        public int getTotalPages() { return totalPages; }
        public int getTotalItems() { return totalItems; }
        public int getLimit() { return limit; }
    }

    public InventoryPageResult getInventoriesPaginated(int requestedPage, int requestedLimit, String sku, Long brandId, Long productLineId, String batchCode, String barcode) throws SQLException {
        int page = requestedPage < 1 ? 1 : requestedPage;
        int limit = requestedLimit < 1 ? 10 : requestedLimit;
        String cleanSku = sku == null ? null : sku.trim();
        String cleanBatch = batchCode == null ? null : batchCode.trim();
        String cleanBarcode = barcode == null ? null : barcode.trim();

        List<Inventory> inventories = inventoryDAO.findPaginated(page, limit, cleanSku, brandId, productLineId, cleanBatch, cleanBarcode);
        int totalItems = inventoryDAO.count(cleanSku, brandId, productLineId, cleanBatch, cleanBarcode);
        int totalPages = (int) Math.ceil((double) totalItems / limit);

        List<Brand> brands = brandDAO.getAll();
        List<ProductLine> productLines = productLineDAO.getAll();

        return new InventoryPageResult(inventories, brands, productLines, page, totalPages, totalItems, limit);
    }

    public Inventory getInventoryForForm(String idStr, String productIdStr) throws SQLException {
        Inventory inventory = null;
        if (idStr != null && !idStr.trim().isEmpty()) {
            inventory = inventoryDAO.getById(Long.parseLong(idStr.trim()));
        } else if (productIdStr != null && !productIdStr.trim().isEmpty()) {
            inventory = inventoryDAO.getByProductId(Long.parseLong(productIdStr.trim()));
        }
        if (inventory != null) {
            int totalQty = inventoryDAO.getQuantityByProductAndBatch(inventory.getProductId(), inventory.getBatchCode());
            inventory.setQuantityInStock(totalQty);
        }
        return inventory;
    }

    public static class BatchDetailResult {
        private final Inventory inventory;
        private final List<Inventory> itemizedList;
        private final int totalQuantity;

        public BatchDetailResult(Inventory inventory, List<Inventory> itemizedList, int totalQuantity) {
            this.inventory = inventory;
            this.itemizedList = itemizedList;
            this.totalQuantity = totalQuantity;
        }

        public Inventory getInventory() { return inventory; }
        public List<Inventory> getItemizedList() { return itemizedList; }
        public int getTotalQuantity() { return totalQuantity; }
    }

    public BatchDetailResult getBatchDetail(String idStr, String productIdStr) throws SQLException {
        Inventory inventory = null;
        if (idStr != null && !idStr.trim().isEmpty()) {
            inventory = inventoryDAO.getById(Long.parseLong(idStr.trim()));
        } else if (productIdStr != null && !productIdStr.trim().isEmpty()) {
            inventory = inventoryDAO.getByProductId(Long.parseLong(productIdStr.trim()));
        }
        if (inventory == null) {
            return null;
        }

        List<Inventory> itemizedList = inventoryDAO.getItemizedListByProductAndBatch(inventory.getProductId(), inventory.getBatchCode());
        int totalQuantity = inventoryDAO.getQuantityByProductAndBatch(inventory.getProductId(), inventory.getBatchCode());

        return new BatchDetailResult(inventory, itemizedList, totalQuantity);
    }

    public Inventory getItemDetail(long id) throws SQLException {
        return inventoryDAO.getById(id);
    }

    public void updateMinStockLevel(String idStr, String productIdStr, String minStockLevelStr) throws SQLException, IllegalArgumentException {
        Inventory i = null;
        if (idStr != null && !idStr.trim().isEmpty()) {
            i = inventoryDAO.getById(Long.parseLong(idStr.trim()));
        } else if (productIdStr != null && !productIdStr.trim().isEmpty()) {
            i = inventoryDAO.getByProductId(Long.parseLong(productIdStr.trim()));
        }

        if (i == null) {
            throw new IllegalArgumentException("Không tìm thấy tồn kho");
        }

        int minStockLevel;
        try {
            minStockLevel = Integer.parseInt(minStockLevelStr != null ? minStockLevelStr.trim() : "0");
            if (minStockLevel < 0) {
                throw new IllegalArgumentException("Lỗi: Mức tồn kho tối thiểu không được nhỏ hơn 0!");
            }
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Lỗi: Mức tồn kho tối thiểu không hợp lệ!");
        }

        long productId = i.getProductId();
        String oldBatchCode = i.getBatchCode();

        i.setMinStockLevel(minStockLevel);
        inventoryDAO.update(i);

        inventoryDAO.updateMinStockLevelForProductAndBatch(productId, oldBatchCode, minStockLevel);
    }
}
