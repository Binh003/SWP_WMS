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

            long selectedId = parseLong(WebUtil.param(request, "id"), roles.isEmpty() ? 0 : roles.get(0).getId());
            Role selected = roleDAO.findByIdWithPermissions(selectedId);
            request.setAttribute("selectedRole", selected);
            request.setAttribute("selectedRoleId", selectedId);

            WebUtil.consumeFlash(request);
            request.getRequestDispatcher("/jsp/admin/roles.jsp").forward(request, response);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        try {
            roleDAO.updateRole(id, WebUtil.param(request, "name"), WebUtil.param(request, "description"));
            boolean enabled = "on".equalsIgnoreCase(WebUtil.param(request, "enabled"))
                || "true".equalsIgnoreCase(WebUtil.param(request, "enabled"));
            roleDAO.setEnabled(id, enabled);

            String[] codes = request.getParameterValues("permissionCodes");
            List<String> permissionCodes = codes == null ? List.of() : Arrays.asList(codes);
            roleDAO.replacePermissions(id, permissionCodes);

            WebUtil.setFlashSuccess(request, "Đã cập nhật vai trò");
            WebUtil.redirect(request, response, "/admin/roles?id=" + id);
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/admin/roles?id=" + id);
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
