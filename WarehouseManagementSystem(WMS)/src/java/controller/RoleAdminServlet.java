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
            List<Role> roles = roleDAO.findAll();
            request.setAttribute("roles", roles);
            request.setAttribute("permissions", permissionDAO.findAll());
            request.setAttribute("currentUser", WebUtil.currentUser(request));

            String action = WebUtil.param(request, "action");
            if ("create".equalsIgnoreCase(action)) {
                request.setAttribute("isCreateMode", true);
            } else {
                long selectedId = parseLong(WebUtil.param(request, "id"), roles.isEmpty() ? 0 : roles.get(0).getId());
                Role selected = roleDAO.findByIdWithPermissions(selectedId);
                request.setAttribute("selectedRole", selected);
                request.setAttribute("selectedRoleId", selectedId);
            }

            WebUtil.consumeFlash(request);
            request.getRequestDispatcher("/jsp/admin/roles.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");

        try {
            if ("delete".equalsIgnoreCase(action)) {
                long id = Long.parseLong(WebUtil.param(request, "id"));
                Role role = roleDAO.findByIdWithPermissions(id);
                if (role != null && "ADMIN".equalsIgnoreCase(role.getCode())) {
                    WebUtil.setFlashError(request, "Không thể xóa vai trò ADMIN mặc định");
                    WebUtil.redirect(request, response, "/admin/roles?id=" + id);
                    return;
                }
                roleDAO.deleteRole(id);
                WebUtil.setFlashSuccess(request, "Đã xóa vai trò thành công");
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
