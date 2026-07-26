package service;

import dao.BrandDAO;
import model.Brand;

import java.sql.SQLException;
import java.util.List;

public class BrandService {

    private final BrandDAO brandDAO = new BrandDAO();

    public static class BrandPageResult {
        private final List<Brand> brands;
        private final int currentPage;
        private final int totalPages;
        private final int totalItems;
        private final int limit;

        public BrandPageResult(List<Brand> brands, int currentPage, int totalPages, int totalItems, int limit) {
            this.brands = brands;
            this.currentPage = currentPage;
            this.totalPages = totalPages;
            this.totalItems = totalItems;
            this.limit = limit;
        }

        public List<Brand> getBrands() { return brands; }
        public int getCurrentPage() { return currentPage; }
        public int getTotalPages() { return totalPages; }
        public int getTotalItems() { return totalItems; }
        public int getLimit() { return limit; }
    }

    public BrandPageResult getBrandsPaginated(String search, int requestedPage, int requestedLimit) throws SQLException {
        String query = search == null ? "" : search.trim();
        int page = requestedPage < 1 ? 1 : requestedPage;
        int limit = requestedLimit < 1 ? 10 : requestedLimit;

        int totalItems = brandDAO.count(query);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }
        int offset = (page - 1) * limit;

        List<Brand> brands = brandDAO.findPaginated(query, offset, limit);
        return new BrandPageResult(brands, page, totalPages, totalItems, limit);
    }

    public Brand getById(long id) throws SQLException {
        return brandDAO.getById(id);
    }

    public void createBrand(String code, String name, String description) throws SQLException, IllegalArgumentException {
        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã hãng không được để trống!");
        }
        String cleanCode = code.trim();
        if (brandDAO.getByCode(cleanCode) != null) {
            throw new IllegalArgumentException("Lỗi: Hãng này đã tồn tại (Mã hãng '" + cleanCode + "' đã được sử dụng)!");
        }

        Brand brand = new Brand();
        brand.setCode(cleanCode);
        brand.setName(name != null ? name.trim() : "");
        brand.setDescription(description != null ? description.trim() : "");

        try {
            brandDAO.insert(brand);
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1062 || (ex.getMessage() != null && ex.getMessage().contains("Duplicate entry"))) {
                throw new IllegalArgumentException("Lỗi: Hãng này đã tồn tại (Mã hãng '" + cleanCode + "' đã được sử dụng)!");
            }
            throw ex;
        }
    }

    public void updateBrand(long id, String newCode, String name, String description) throws SQLException, IllegalArgumentException {
        Brand brand = brandDAO.getById(id);
        if (brand == null) {
            throw new IllegalArgumentException("Không tìm thấy hãng");
        }

        if (newCode == null || newCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã hãng không được để trống!");
        }
        String cleanCode = newCode.trim();

        if (!brand.getCode().equalsIgnoreCase(cleanCode)) {
            Brand existing = brandDAO.getByCode(cleanCode);
            if (existing != null && existing.getId() != id) {
                throw new IllegalArgumentException("Lỗi: Hãng này đã tồn tại (Mã hãng '" + cleanCode + "' đã được sử dụng)!");
            }
        }

        brand.setCode(cleanCode);
        brand.setName(name != null ? name.trim() : "");
        brand.setDescription(description != null ? description.trim() : "");

        try {
            brandDAO.update(brand);
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1062 || (ex.getMessage() != null && ex.getMessage().contains("Duplicate entry"))) {
                throw new IllegalArgumentException("Lỗi: Hãng này đã tồn tại (Mã hãng '" + cleanCode + "' đã được sử dụng)!");
            }
            throw ex;
        }
    }

    public void deleteBrand(long id) throws SQLException, IllegalArgumentException {
        Brand brand = brandDAO.getById(id);
        if (brand == null) {
            throw new IllegalArgumentException("Hãng sản xuất không tồn tại hoặc đã bị xóa!");
        }

        int productLineCount = brandDAO.countProductLinesByBrandId(id);
        if (productLineCount > 0) {
            throw new IllegalArgumentException("Không thể xóa hãng \"" + brand.getName() + "\" (Mã: " + brand.getCode() + ") vì đang có " + productLineCount + " dòng sản phẩm (Product Lines) thuộc hãng này trong hệ thống. Vui lòng xóa hoặc di chuyển các dòng sản phẩm liên quan trước khi xóa hãng!");
        }

        try {
            brandDAO.delete(id);
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1451 || (ex.getMessage() != null && ex.getMessage().contains("foreign key constraint fails"))) {
                throw new IllegalArgumentException("Không thể xóa hãng \"" + brand.getName() + "\" (Mã: " + brand.getCode() + ") vì đang có dữ liệu thuộc hãng này tồn tại ở các bảng khác trong hệ thống!");
            }
            throw ex;
        }
    }
}
