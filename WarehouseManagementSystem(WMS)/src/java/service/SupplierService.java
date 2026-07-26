package service;

import dao.SupplierDAO;
import model.Supplier;

import java.sql.SQLException;
import java.util.List;

public class SupplierService {

    private final SupplierDAO supplierDAO = new SupplierDAO();

    public static class SupplierPageResult {
        private final List<Supplier> suppliers;
        private final int currentPage;
        private final int totalPages;
        private final int totalItems;
        private final int limit;

        public SupplierPageResult(List<Supplier> suppliers, int currentPage, int totalPages, int totalItems, int limit) {
            this.suppliers = suppliers;
            this.currentPage = currentPage;
            this.totalPages = totalPages;
            this.totalItems = totalItems;
            this.limit = limit;
        }

        public List<Supplier> getSuppliers() { return suppliers; }
        public int getCurrentPage() { return currentPage; }
        public int getTotalPages() { return totalPages; }
        public int getTotalItems() { return totalItems; }
        public int getLimit() { return limit; }
    }

    public SupplierPageResult getSuppliersPaginated(String search, int requestedPage, int requestedLimit) throws SQLException {
        String query = search == null ? "" : search.trim();
        int page = requestedPage < 1 ? 1 : requestedPage;
        int limit = requestedLimit < 1 ? 10 : requestedLimit;

        int totalItems = supplierDAO.count(query);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }
        int offset = (page - 1) * limit;

        List<Supplier> suppliers = supplierDAO.findPaginated(query, offset, limit);
        return new SupplierPageResult(suppliers, page, totalPages, totalItems, limit);
    }

    public Supplier getById(long id) throws SQLException {
        return supplierDAO.getById(id);
    }

    public List<Supplier> getAllSuppliers() throws SQLException {
        return supplierDAO.getAll();
    }

    public void createSupplier(String code, String name, String phone, String email, String address) throws SQLException, IllegalArgumentException {
        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã nhà cung cấp không được để trống!");
        }
        String cleanCode = code.trim();
        if (supplierDAO.getByCode(cleanCode) != null) {
            throw new IllegalArgumentException("Lỗi: Nhà cung cấp này đã tồn tại (Mã nhà cung cấp '" + cleanCode + "' đã được sử dụng)!");
        }

        Supplier supplier = new Supplier();
        supplier.setCode(cleanCode);
        supplier.setName(name != null ? name.trim() : "");
        supplier.setPhone(phone != null ? phone.trim() : "");
        supplier.setEmail(email != null ? email.trim() : "");
        supplier.setAddress(address != null ? address.trim() : "");

        try {
            supplierDAO.insert(supplier);
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1062 || (ex.getMessage() != null && ex.getMessage().contains("Duplicate entry"))) {
                throw new IllegalArgumentException("Lỗi: Nhà cung cấp này đã tồn tại (Mã nhà cung cấp '" + cleanCode + "' đã được sử dụng)!");
            }
            throw ex;
        }
    }

    public void updateSupplier(long id, String newCode, String name, String phone, String email, String address) throws SQLException, IllegalArgumentException {
        Supplier supplier = supplierDAO.getById(id);
        if (supplier == null) {
            throw new IllegalArgumentException("Không tìm thấy nhà cung cấp");
        }

        if (newCode == null || newCode.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã nhà cung cấp không được để trống!");
        }
        String cleanCode = newCode.trim();

        if (!supplier.getCode().equalsIgnoreCase(cleanCode)) {
            Supplier existing = supplierDAO.getByCode(cleanCode);
            if (existing != null && existing.getId() != id) {
                throw new IllegalArgumentException("Lỗi: Nhà cung cấp này đã tồn tại (Mã nhà cung cấp '" + cleanCode + "' đã được sử dụng)!");
            }
        }

        supplier.setCode(cleanCode);
        supplier.setName(name != null ? name.trim() : "");
        supplier.setPhone(phone != null ? phone.trim() : "");
        supplier.setEmail(email != null ? email.trim() : "");
        supplier.setAddress(address != null ? address.trim() : "");

        try {
            supplierDAO.update(supplier);
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1062 || (ex.getMessage() != null && ex.getMessage().contains("Duplicate entry"))) {
                throw new IllegalArgumentException("Lỗi: Nhà cung cấp này đã tồn tại (Mã nhà cung cấp '" + cleanCode + "' đã được sử dụng)!");
            }
            throw ex;
        }
    }

    public void deleteSupplier(long id) throws SQLException {
        supplierDAO.delete(id);
    }
}
