package service;

import dao.BrandDAO;
import dao.InventoryDAO;
import dao.ProductDAO;
import dao.ProductLineDAO;
import model.Brand;
import model.Inventory;
import model.Product;
import model.ProductLine;

import java.sql.SQLException;
import java.util.List;

public class ProductService {

    private final ProductDAO productDAO = new ProductDAO();
    private final ProductLineDAO productLineDAO = new ProductLineDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();
    private final BrandDAO brandDAO = new BrandDAO();

    public static class ProductPageResult {
        private final List<Product> products;
        private final List<Brand> allBrands;
        private final List<ProductLine> allProductLines;
        private final int currentPage;
        private final int totalPages;
        private final int totalItems;
        private final int limit;

        public ProductPageResult(List<Product> products, List<Brand> allBrands, List<ProductLine> allProductLines, int currentPage, int totalPages, int totalItems, int limit) {
            this.products = products;
            this.allBrands = allBrands;
            this.allProductLines = allProductLines;
            this.currentPage = currentPage;
            this.totalPages = totalPages;
            this.totalItems = totalItems;
            this.limit = limit;
        }

        public List<Product> getProducts() { return products; }
        public List<Brand> getAllBrands() { return allBrands; }
        public List<ProductLine> getAllProductLines() { return allProductLines; }
        public int getCurrentPage() { return currentPage; }
        public int getTotalPages() { return totalPages; }
        public int getTotalItems() { return totalItems; }
        public int getLimit() { return limit; }
    }

    public ProductPageResult getProductsPaginated(int requestedPage, int requestedLimit, String search, Long brandId, Long productLineId) throws SQLException {
        int page = requestedPage < 1 ? 1 : requestedPage;
        int limit = requestedLimit < 1 ? 10 : requestedLimit;
        String query = search == null ? null : search.trim();

        List<Product> products = productDAO.findPaginated(page, limit, query, brandId, productLineId);
        int totalItems = productDAO.count(query, brandId, productLineId);
        int totalPages = (int) Math.ceil((double) totalItems / limit);

        List<Brand> brands = brandDAO.getAll();
        List<ProductLine> productLines = productLineDAO.getAll();

        return new ProductPageResult(products, brands, productLines, page, totalPages, totalItems, limit);
    }

    public Product getById(long id) throws SQLException {
        return productDAO.getById(id);
    }

    public Inventory getInventoryByProductId(long productId) throws SQLException {
        return inventoryDAO.getByProductId(productId);
    }

    public List<ProductLine> getAllProductLines() throws SQLException {
        return productLineDAO.getAll();
    }

    public void createProduct(long productLineId, String sku, String name, String unit, String priceStr, String description, String imageUrl) throws SQLException, IllegalArgumentException {
        if (sku == null || sku.trim().isEmpty()) {
            throw new IllegalArgumentException("SKU không được để trống!");
        }
        String cleanSku = sku.trim();

        if (productDAO.getBySku(cleanSku) != null) {
            throw new IllegalArgumentException("Lỗi: SKU đã tồn tại trong hệ thống!");
        }

        Double price = null;
        if (priceStr != null && !priceStr.trim().isEmpty()) {
            try {
                price = Double.parseDouble(priceStr.trim());
                if (price < 0) {
                    throw new IllegalArgumentException("Lỗi: Giá bán không được nhỏ hơn 0!");
                }
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Lỗi: Giá bán không hợp lệ!");
            }
        }

        Product p = new Product();
        p.setProductLineId(productLineId);
        p.setSku(cleanSku);
        p.setName(name != null ? name.trim() : "");
        p.setUnit(unit != null ? unit.trim() : "");
        p.setPrice(price);
        p.setDescription(description != null ? description.trim() : "");
        p.setImageUrl(imageUrl);

        productDAO.insert(p);

        // Initialize inventory record for new product
        Inventory inv = new Inventory();
        inv.setProductId(p.getId());
        inv.setQuantityInStock(0);
        inv.setMinStockLevel(0);
        inventoryDAO.insert(inv);
    }

    public void updateProduct(long id, long productLineId, String newSku, String name, String unit, String priceStr, String description, String imageUrl) throws SQLException, IllegalArgumentException {
        Product p = productDAO.getById(id);
        if (p == null) {
            throw new IllegalArgumentException("Không tìm thấy sản phẩm");
        }

        if (newSku == null || newSku.trim().isEmpty()) {
            throw new IllegalArgumentException("SKU không được để trống!");
        }
        String cleanSku = newSku.trim();

        if (!p.getSku().equals(cleanSku) && productDAO.getBySku(cleanSku) != null) {
            throw new IllegalArgumentException("Lỗi: SKU đã tồn tại trong hệ thống!");
        }

        Double price = null;
        if (priceStr != null && !priceStr.trim().isEmpty()) {
            try {
                price = Double.parseDouble(priceStr.trim());
                if (price < 0) {
                    throw new IllegalArgumentException("Lỗi: Giá bán không được nhỏ hơn 0!");
                }
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Lỗi: Giá bán không hợp lệ!");
            }
        }

        p.setProductLineId(productLineId);
        p.setSku(cleanSku);
        p.setName(name != null ? name.trim() : "");
        p.setUnit(unit != null ? unit.trim() : "");
        p.setPrice(price);
        p.setDescription(description != null ? description.trim() : "");
        p.setImageUrl(imageUrl);

        productDAO.update(p);
    }

    public void deleteProduct(long id) throws SQLException, IllegalArgumentException {
        try {
            productDAO.delete(id);
        } catch (SQLException ex) {
            throw new IllegalArgumentException("Không thể xóa sản phẩm này vì có dữ liệu liên quan (tồn kho, phiếu nhập/xuất...).");
        }
    }
}
