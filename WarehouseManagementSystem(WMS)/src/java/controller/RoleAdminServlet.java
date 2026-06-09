package controller;

import dao.PermissionDAO;
import dao.RoleDAO;
import model.Role;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

public class RoleAdminServlet extends HttpServlet {

    private final RoleDAO roleDAO = new RoleDAO();
    private final PermissionDAO permissionDAO = new PermissionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        try {
            model.User currentUser = WebUtil.currentUser(request);
            boolean canWrite = currentUser != null && (currentUser.hasRole("ADMIN") || currentUser.hasPermission("ROLE_WRITE"));

            request.setAttribute("permissions", permissionDAO.findAll());
            request.setAttribute("currentUser", currentUser);

            String action = WebUtil.param(request, "action");
            String idParam = WebUtil.param(request, "id");
            String forwardJsp = "/jsp/admin/roles.jsp";

            if ("create".equalsIgnoreCase(action)) {
                if (!canWrite) {
                    WebUtil.setFlashError(request, "Bạn không có quyền thực hiện thao tác này");
                    WebUtil.redirect(request, response, "/admin/roles");
                    return;
                }
                forwardJsp = "/jsp/admin/role-create.jsp";
            } else if ("detail".equalsIgnoreCase(action)) {
                long selectedId = parseLong(idParam, 0);
                Role selected = selectedId > 0 ? roleDAO.findByIdWithPermissions(selectedId) : null;
                if (selected != null) {
                    request.setAttribute("selectedRole", selected);
                    request.setAttribute("selectedRoleId", selectedId);
                    forwardJsp = "/jsp/admin/role-detail.jsp";
                } else {
                    WebUtil.setFlashError(request, "Không tìm thấy vai trò");
                    WebUtil.redirect(request, response, "/admin/roles");
                    return;
                }
            } else if ("edit".equalsIgnoreCase(action) || (idParam != null && !idParam.isEmpty() && !"detail".equalsIgnoreCase(action))) {
                if (!canWrite) {
                    WebUtil.setFlashError(request, "Bạn không có quyền thực hiện thao tác này");
                    WebUtil.redirect(request, response, "/admin/roles");
                    return;
                }
                long selectedId = parseLong(idParam, 0);
                Role selected = selectedId > 0 ? roleDAO.findByIdWithPermissions(selectedId) : null;
                if (selected != null) {
                    request.setAttribute("selectedRole", selected);
                    request.setAttribute("selectedRoleId", selectedId);
                    forwardJsp = "/jsp/admin/role-edit.jsp";
                }
            } else {
                String search = request.getParameter("search");
                String status = request.getParameter("status");

                int page = 1;
                String pageStr = request.getParameter("page");
                if (pageStr != null && !pageStr.isEmpty()) {
                    try {
                        page = Integer.parseInt(pageStr);
                    } catch (NumberFormatException ignored) {}
                }

                int size = 10;
                String sizeStr = request.getParameter("size");
                if (sizeStr != null && !sizeStr.isEmpty()) {
                    try {
                        size = Integer.parseInt(sizeStr);
                    } catch (NumberFormatException ignored) {}
                }

                int totalCount = roleDAO.count(search, status);
                int totalPages = (int) Math.ceil((double) totalCount / size);
                if (totalPages < 1) totalPages = 1;
                if (page > totalPages) page = totalPages;
                if (page < 1) page = 1;

                int offset = (page - 1) * size;
                List<Role> roles = roleDAO.findPaginated(search, status, offset, size);

                request.setAttribute("roles", roles);
                request.setAttribute("search", search);
                request.setAttribute("status", status);
                request.setAttribute("currentPage", page);
                request.setAttribute("pageSize", size);
                request.setAttribute("totalCount", totalCount);
                request.setAttribute("totalPages", totalPages);
            }

            WebUtil.consumeFlash(request);
            request.getRequestDispatcher(forwardJsp).forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        model.User currentUser = WebUtil.currentUser(request);
        boolean canWrite = currentUser != null && (currentUser.hasRole("ADMIN") || currentUser.hasPermission("ROLE_WRITE"));
        if (!canWrite) {
            WebUtil.setFlashError(request, "Bạn không có quyền thực hiện thao tác này");
            WebUtil.redirect(request, response, "/admin/roles");
            return;
        }
        
        String action = WebUtil.param(request, "action");

        try {
            if ("toggle-status".equalsIgnoreCase(action)) {
                long id = Long.parseLong(WebUtil.param(request, "id"));
                boolean enabled = "true".equalsIgnoreCase(WebUtil.param(request, "enabled"));
                Role role = roleDAO.findByIdWithPermissions(id);
                if (role == null) {
                    WebUtil.setFlashError(request, "Vai trò không tồn tại");
                    WebUtil.redirect(request, response, "/admin/roles");
                    return;
                }
                if ("ADMIN".equalsIgnoreCase(role.getCode()) && !enabled) {
                    WebUtil.setFlashError(request, "Không thể khóa vai trò ADMIN mặc định");
                    WebUtil.redirect(request, response, "/admin/roles");
                    return;
                }
                roleDAO.setEnabled(id, enabled);
                WebUtil.setFlashSuccess(request, "Đã " + (enabled ? "kích hoạt" : "hủy kích hoạt") + " vai trò thành công");
                WebUtil.redirect(request, response, "/admin/roles");
                return;
            }

            if ("create".equalsIgnoreCase(action)) {
                String code = WebUtil.param(request, "code");
                if (code == null || code.trim().isEmpty()) {
                    WebUtil.setFlashError(request, "Mã vai trò không được để trống");
                    WebUtil.redirect(request, response, "/admin/roles?action=create");
                    return;
                }
                code = code.trim().toUpperCase();
                if (roleDAO.existsByCode(code)) {
                    WebUtil.setFlashError(request, "Mã vai trò đã tồn tại");
                    WebUtil.redirect(request, response, "/admin/roles?action=create");
                    return;
                }

                Role role = new Role();
                role.setCode(code);
                role.setName(WebUtil.param(request, "name"));
                role.setDescription(WebUtil.param(request, "description"));
                boolean enabled = "on".equalsIgnoreCase(WebUtil.param(request, "enabled"))
                    || "true".equalsIgnoreCase(WebUtil.param(request, "enabled"));
                role.setEnabled(enabled);

                long newId = roleDAO.insertRole(role);

                String[] codes = request.getParameterValues("permissionCodes");
                List<String> permissionCodes = codes == null ? List.of() : Arrays.asList(codes);
                roleDAO.replacePermissions(newId, permissionCodes);

                WebUtil.setFlashSuccess(request, "Đã tạo vai trò mới thành công");
                WebUtil.redirect(request, response, "/admin/roles?id=" + newId);
                return;
            }

            // Default: Update Role
            long id = Long.parseLong(WebUtil.param(request, "id"));
            Role role = roleDAO.findByIdWithPermissions(id);
            if (role == null) {
                WebUtil.setFlashError(request, "Vai trò không tồn tại");
                WebUtil.redirect(request, response, "/admin/roles");
                return;
            }

            boolean enabled = "on".equalsIgnoreCase(WebUtil.param(request, "enabled"))
                || "true".equalsIgnoreCase(WebUtil.param(request, "enabled"));

            if ("ADMIN".equalsIgnoreCase(role.getCode()) && !enabled) {
                WebUtil.setFlashError(request, "Không thể khóa vai trò ADMIN mặc định");
                WebUtil.redirect(request, response, "/admin/roles?id=" + id);
                return;
            }

            roleDAO.updateRole(id, WebUtil.param(request, "name"), WebUtil.param(request, "description"));
            roleDAO.setEnabled(id, enabled);

            String[] codes = request.getParameterValues("permissionCodes");
            List<String> permissionCodes = codes == null ? List.of() : Arrays.asList(codes);
            roleDAO.replacePermissions(id, permissionCodes);

            WebUtil.setFlashSuccess(request, "Đã cập nhật vai trò");
            WebUtil.redirect(request, response, "/admin/roles?id=" + id);
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            String redirectUrl = "/admin/roles";
            String idStr = WebUtil.param(request, "id");
            if (idStr != null && !idStr.isEmpty()) {
                redirectUrl += "?id=" + idStr;
            } else if ("create".equalsIgnoreCase(action)) {
                redirectUrl += "?action=create";
            }
            WebUtil.redirect(request, response, redirectUrl);
        }
    }

    private long parseLong(String value, long defaultValue) {
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException ex) {
            return defaultValue;
        }
    }
}
