package service;

import dao.BrandDAO;
import dao.ProductLineDAO;
import model.Brand;
import model.ProductLine;

import java.sql.SQLException;
import java.util.List;

public class ProductLineService {

    private final ProductLineDAO productLineDAO = new ProductLineDAO();
    private final BrandDAO brandDAO = new BrandDAO();

    public static class ProductLinePageResult {
        private final List<ProductLine> productLines;
        private final List<Brand> allBrands;
        private final int currentPage;
        private final int totalPages;
        private final int totalItems;
        private final int limit;

        public ProductLinePageResult(List<ProductLine> productLines, List<Brand> allBrands, int currentPage, int totalPages, int totalItems, int limit) {
            this.productLines = productLines;
            this.allBrands = allBrands;
            this.currentPage = currentPage;
            this.totalPages = totalPages;
            this.totalItems = totalItems;
            this.limit = limit;
        }

        public List<ProductLine> getProductLines() { return productLines; }
        public List<Brand> getAllBrands() { return allBrands; }
        public int getCurrentPage() { return currentPage; }
        public int getTotalPages() { return totalPages; }
        public int getTotalItems() { return totalItems; }
        public int getLimit() { return limit; }
    }

    public ProductLinePageResult getProductLinesPaginated(String search, Long brandId, int requestedPage, int requestedLimit) throws SQLException {
        String query = search == null ? "" : search.trim();
        int page = requestedPage < 1 ? 1 : requestedPage;
        int limit = requestedLimit < 1 ? 10 : requestedLimit;

        int totalItems = productLineDAO.count(query, brandId);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }
        int offset = (page - 1) * limit;

        List<ProductLine> productLines = productLineDAO.findPaginated(query, brandId, offset, limit);
        List<Brand> brands = brandDAO.getAll();

        return new ProductLinePageResult(productLines, brands, page, totalPages, totalItems, limit);
    }

    public ProductLine getById(long id) throws SQLException {
        return productLineDAO.getById(id);
    }

    public List<Brand> getAllBrands() throws SQLException {
        return brandDAO.getAll();
    }

    public void createProductLine(long brandId, String code, String name, String description) throws SQLException, IllegalArgumentException {
        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã dòng sản phẩm không được để trống!");
        }
        String cleanCode = code.trim();
        if (productLineDAO.getByCode(cleanCode) != null) {
            throw new IllegalArgumentException("Lỗi: Dòng sản phẩm này đã tồn tại (Mã dòng sản phẩm '" + cleanCode + "' đã được sử dụng)!");
        }

        ProductLine pl = new ProductLine();
        pl.setBrandId(brandId);
        pl.setCode(cleanCode);
        pl.setName(name != null ? name.trim() : "");
        pl.setDescription(description != null ? description.trim() : "");

        try {
            productLineDAO.insert(pl);
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1062 || (ex.getMessage() != null && ex.getMessage().contains("Duplicate entry"))) {
                throw new IllegalArgumentException("Lỗi: Dòng sản phẩm này đã tồn tại (Mã dòng sản phẩm '" + cleanCode + "' đã được sử dụng)!");
            }
            throw ex;
        }
    }

    public void updateProductLine(long id, long brandId, String newCode, String name, String description) throws SQLException, IllegalArgumentException {
        ProductLine pl = productLineDAO.getById(id);
        if (pl == null) {
            throw new IllegalArgumentException("Không tìm thấy dòng sản phẩm");
        }

        if (newCode == null || newCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã dòng sản phẩm không được để trống!");
        }
        String cleanCode = newCode.trim();

        if (!pl.getCode().equalsIgnoreCase(cleanCode)) {
            ProductLine existing = productLineDAO.getByCode(cleanCode);
            if (existing != null && existing.getId() != id) {
                throw new IllegalArgumentException("Lỗi: Dòng sản phẩm này đã tồn tại (Mã dòng sản phẩm '" + cleanCode + "' đã được sử dụng)!");
            }
        }

        pl.setBrandId(brandId);
        pl.setCode(cleanCode);
        pl.setName(name != null ? name.trim() : "");
        pl.setDescription(description != null ? description.trim() : "");

        try {
            productLineDAO.update(pl);
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1062 || (ex.getMessage() != null && ex.getMessage().contains("Duplicate entry"))) {
                throw new IllegalArgumentException("Lỗi: Dòng sản phẩm này đã tồn tại (Mã dòng sản phẩm '" + cleanCode + "' đã được sử dụng)!");
            }
            throw ex;
        }
    }

    public void deleteProductLine(long id) throws SQLException {
        productLineDAO.delete(id);
    }
}
