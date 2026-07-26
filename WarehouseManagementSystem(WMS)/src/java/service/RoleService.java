package service;

import dao.PermissionDAO;
import dao.RoleDAO;
import model.Role;

import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

public class RoleService {

    private final RoleDAO roleDAO = new RoleDAO();
    private final PermissionDAO permissionDAO = new PermissionDAO();

    public static class RolePageResult {
        private final List<Role> roles;
        private final int currentPage;
        private final int pageSize;
        private final int totalCount;
        private final int totalPages;

        public RolePageResult(List<Role> roles, int currentPage, int pageSize, int totalCount, int totalPages) {
            this.roles = roles;
            this.currentPage = currentPage;
            this.pageSize = pageSize;
            this.totalCount = totalCount;
            this.totalPages = totalPages;
        }

        public List<Role> getRoles() { return roles; }
        public int getCurrentPage() { return currentPage; }
        public int getPageSize() { return pageSize; }
        public int getTotalCount() { return totalCount; }
        public int getTotalPages() { return totalPages; }
    }

    public List<Role> getAllRoles() throws SQLException {
        return roleDAO.findAll();
    }

    public RolePageResult getRolesPaginated(String search, String status, int requestedPage, int requestedSize) throws SQLException {
        int page = requestedPage < 1 ? 1 : requestedPage;
        int size = requestedSize < 1 ? 10 : requestedSize;

        int totalCount = roleDAO.count(search, status);
        int totalPages = (int) Math.ceil((double) totalCount / size);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * size;
        List<Role> roles = roleDAO.findPaginated(search, status, offset, size);

        return new RolePageResult(roles, page, size, totalCount, totalPages);
    }

    public Role getRoleWithPermissions(long id) throws SQLException {
        return roleDAO.findByIdWithPermissions(id);
    }

    public List<String[]> getAllPermissions() throws SQLException {
        return permissionDAO.findAll();
    }

    public long createRole(String code, String name, String description, boolean enabled, String[] permissionCodes) throws SQLException, IllegalArgumentException {
        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã vai trò không được để trống");
        }
        String cleanCode = code.trim().toUpperCase();
        if (roleDAO.existsByCode(cleanCode)) {
            throw new IllegalArgumentException("Mã vai trò đã tồn tại");
        }

        Role role = new Role();
        role.setCode(cleanCode);
        role.setName(name != null ? name.trim() : "");
        role.setDescription(description != null ? description.trim() : "");
        role.setEnabled(enabled);

        long newId = roleDAO.insertRole(role);

        List<String> codes = permissionCodes == null ? List.of() : Arrays.asList(permissionCodes);
        roleDAO.replacePermissions(newId, codes);

        return newId;
    }

    public void updateRole(long id, String name, String description, boolean enabled, String[] permissionCodes) throws SQLException, IllegalArgumentException {
        Role role = roleDAO.findByIdWithPermissions(id);
        if (role == null) {
            throw new IllegalArgumentException("Vai trò không tồn tại");
        }

        if ("ADMIN".equalsIgnoreCase(role.getCode())) {
            throw new IllegalArgumentException("Không thể chỉnh sửa vai trò ADMIN mặc định");
        }

        roleDAO.updateRole(id, name != null ? name.trim() : "", description != null ? description.trim() : "");
        roleDAO.setEnabled(id, enabled);

        List<String> codes = permissionCodes == null ? List.of() : Arrays.asList(permissionCodes);
        roleDAO.replacePermissions(id, codes);
    }

    public String toggleRoleStatus(long id, boolean enabled) throws SQLException, IllegalArgumentException {
        Role role = roleDAO.findByIdWithPermissions(id);
        if (role == null) {
            throw new IllegalArgumentException("Vai trò không tồn tại");
        }

        if ("ADMIN".equalsIgnoreCase(role.getCode()) && !enabled) {
            throw new IllegalArgumentException("Không thể khóa vai trò ADMIN mặc định");
        }

        roleDAO.setEnabled(id, enabled);
        return "Đã " + (enabled ? "kích hoạt" : "hủy kích hoạt") + " vai trò thành công";
    }
}
