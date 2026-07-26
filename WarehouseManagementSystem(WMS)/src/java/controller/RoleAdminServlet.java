package controller;

import model.Role;
import model.User;
import service.RoleService;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class RoleAdminServlet extends HttpServlet {

    private final RoleService roleService = new RoleService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        try {
            User currentUser = WebUtil.currentUser(request);
            boolean canWrite = currentUser != null && (currentUser.hasRole("ADMIN") || currentUser.hasPermission("ROLE_WRITE"));

            request.setAttribute("permissions", roleService.getAllPermissions());
            request.setAttribute("currentUser", currentUser);

            String action = WebUtil.param(request, "action");
            String idParam = WebUtil.param(request, "id");
            String forwardJsp = "/jsp/manage/roles.jsp";

            if ("create".equalsIgnoreCase(action)) {
                if (!canWrite) {
                    WebUtil.setFlashError(request, "Bạn không có quyền thực hiện thao tác này");
                    WebUtil.redirect(request, response, "/manage/roles");
                    return;
                }
                forwardJsp = "/jsp/manage/role-create.jsp";
            } else if ("detail".equalsIgnoreCase(action)) {
                long selectedId = parseLong(idParam, 0);
                Role selected = selectedId > 0 ? roleService.getRoleWithPermissions(selectedId) : null;
                if (selected != null) {
                    request.setAttribute("selectedRole", selected);
                    request.setAttribute("selectedRoleId", selectedId);
                    forwardJsp = "/jsp/manage/role-detail.jsp";
                } else {
                    WebUtil.setFlashError(request, "Không tìm thấy vai trò");
                    WebUtil.redirect(request, response, "/manage/roles");
                    return;
                }
            } else if ("edit".equalsIgnoreCase(action) || (idParam != null && !idParam.isEmpty() && !"detail".equalsIgnoreCase(action))) {
                if (!canWrite) {
                    WebUtil.setFlashError(request, "Bạn không có quyền thực hiện thao tác này");
                    WebUtil.redirect(request, response, "/manage/roles");
                    return;
                }
                long selectedId = parseLong(idParam, 0);
                Role selected = selectedId > 0 ? roleService.getRoleWithPermissions(selectedId) : null;
                if (selected != null) {
                    if ("ADMIN".equalsIgnoreCase(selected.getCode())) {
                        WebUtil.setFlashError(request, "Không thể chỉnh sửa vai trò ADMIN mặc định");
                        WebUtil.redirect(request, response, "/manage/roles");
                        return;
                    }
                    request.setAttribute("selectedRole", selected);
                    request.setAttribute("selectedRoleId", selectedId);
                    forwardJsp = "/jsp/manage/role-edit.jsp";
                }
            } else {
                String search = request.getParameter("search");
                String status = request.getParameter("status");

                int page = 1;
                String pageStr = request.getParameter("page");
                if (pageStr != null && !pageStr.isEmpty()) {
                    try { page = Integer.parseInt(pageStr); } catch (NumberFormatException ignored) {}
                }

                int size = 10;
                String sizeStr = request.getParameter("size");
                if (sizeStr != null && !sizeStr.isEmpty()) {
                    try { size = Integer.parseInt(sizeStr); } catch (NumberFormatException ignored) {}
                }

                RoleService.RolePageResult result = roleService.getRolesPaginated(search, status, page, size);

                request.setAttribute("roles", result.getRoles());
                request.setAttribute("search", search);
                request.setAttribute("status", status);
                request.setAttribute("currentPage", result.getCurrentPage());
                request.setAttribute("pageSize", result.getPageSize());
                request.setAttribute("totalCount", result.getTotalCount());
                request.setAttribute("totalPages", result.getTotalPages());
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
        
        User currentUser = WebUtil.currentUser(request);
        boolean canWrite = currentUser != null && (currentUser.hasRole("ADMIN") || currentUser.hasPermission("ROLE_WRITE"));
        if (!canWrite) {
            WebUtil.setFlashError(request, "Bạn không có quyền thực hiện thao tác này");
            WebUtil.redirect(request, response, "/manage/roles");
            return;
        }
        
        String action = WebUtil.param(request, "action");

        try {
            if ("toggle-status".equalsIgnoreCase(action)) {
                long id = Long.parseLong(WebUtil.param(request, "id"));
                boolean enabled = "true".equalsIgnoreCase(WebUtil.param(request, "enabled"));
                try {
                    String msg = roleService.toggleRoleStatus(id, enabled);
                    WebUtil.setFlashSuccess(request, msg);
                } catch (IllegalArgumentException ex) {
                    WebUtil.setFlashError(request, ex.getMessage());
                }
                WebUtil.redirect(request, response, "/manage/roles");
                return;
            }

            if ("create".equalsIgnoreCase(action)) {
                String code = WebUtil.param(request, "code");
                String name = WebUtil.param(request, "name");
                String description = WebUtil.param(request, "description");
                boolean enabled = "on".equalsIgnoreCase(WebUtil.param(request, "enabled"))
                    || "true".equalsIgnoreCase(WebUtil.param(request, "enabled"));
                String[] permissionCodes = request.getParameterValues("permissionCodes");

                try {
                    long newId = roleService.createRole(code, name, description, enabled, permissionCodes);
                    WebUtil.setFlashSuccess(request, "Đã tạo vai trò mới thành công");
                    WebUtil.redirect(request, response, "/manage/roles?id=" + newId);
                } catch (IllegalArgumentException ex) {
                    WebUtil.setFlashError(request, ex.getMessage());
                    WebUtil.redirect(request, response, "/manage/roles?action=create");
                }
                return;
            }

            // Default: Update Role
            long id = Long.parseLong(WebUtil.param(request, "id"));
            String name = WebUtil.param(request, "name");
            String description = WebUtil.param(request, "description");
            boolean enabled = "on".equalsIgnoreCase(WebUtil.param(request, "enabled"))
                || "true".equalsIgnoreCase(WebUtil.param(request, "enabled"));
            String[] permissionCodes = request.getParameterValues("permissionCodes");

            try {
                roleService.updateRole(id, name, description, enabled, permissionCodes);
                WebUtil.setFlashSuccess(request, "Đã cập nhật vai trò");
                WebUtil.redirect(request, response, "/manage/roles?id=" + id);
            } catch (IllegalArgumentException ex) {
                WebUtil.setFlashError(request, ex.getMessage());
                WebUtil.redirect(request, response, "/manage/roles?id=" + id);
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            String redirectUrl = "/manage/roles";
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
