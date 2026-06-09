package controller;

import dao.SupplierDAO;
import model.Supplier;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class SupplierServlet extends HttpServlet {

    private final SupplierDAO supplierDAO = new SupplierDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }
        try {
            request.setAttribute("currentUser", WebUtil.currentUser(request));
            WebUtil.consumeFlash(request);
            switch (action) {
                case "create" -> showCreateForm(request, response);
                case "edit" -> showEditForm(request, response);
                case "view" -> showDetail(request, response);
                default -> listSuppliers(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listSuppliers(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String search = request.getParameter("search");
        if (search == null) {
            search = "";
        }
        
        int page = 1;
        String pageStr = request.getParameter("page");
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
                if (page < 1) page = 1;
            } catch (NumberFormatException ignored) {}
        }
        
        int limit = 10;
        String limitStr = request.getParameter("limit");
        if (limitStr != null && !limitStr.isEmpty()) {
            try {
                limit = Integer.parseInt(limitStr);
                if (limit < 1) limit = 10;
            } catch (NumberFormatException ignored) {}
        }
        
        int totalItems = supplierDAO.count(search);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }
        int offset = (page - 1) * limit;
        
        request.setAttribute("suppliers", supplierDAO.findPaginated(search, offset, limit));
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("limit", limit);
        request.setAttribute("search", search);
        
        request.getRequestDispatcher("/jsp/admin/suppliers.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Supplier supplier = supplierDAO.getById(id);
        if (supplier == null) {
            WebUtil.setFlashError(request, "Không tìm thấy nhà cung cấp");
            WebUtil.redirect(request, response, "/admin/suppliers");
            return;
        }
        request.setAttribute("supplier", supplier);
        request.getRequestDispatcher("/jsp/admin/supplier-detail.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/admin/supplier-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Supplier supplier = supplierDAO.getById(id);
        if (supplier == null) {
            WebUtil.setFlashError(request, "Không tìm thấy nhà cung cấp");
            WebUtil.redirect(request, response, "/admin/suppliers");
            return;
        }
        request.setAttribute("supplier", supplier);
        request.getRequestDispatcher("/jsp/admin/supplier-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        try {
            switch (action) {
                case "create" -> createSupplier(request, response);
                case "update" -> updateSupplier(request, response);
                case "delete" -> deleteSupplier(request, response);
                default -> WebUtil.redirect(request, response, "/admin/suppliers");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/admin/suppliers");
        }
    }

    private void createSupplier(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        Supplier supplier = new Supplier();
        supplier.setCode(WebUtil.param(request, "code"));
        supplier.setName(WebUtil.param(request, "name"));
        supplier.setPhone(WebUtil.param(request, "phone"));
        supplier.setEmail(WebUtil.param(request, "email"));
        supplier.setAddress(WebUtil.param(request, "address"));

        supplierDAO.insert(supplier);
        WebUtil.setFlashSuccess(request, "Đã thêm nhà cung cấp thành công");
        WebUtil.redirect(request, response, "/admin/suppliers");
    }

    private void updateSupplier(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Supplier supplier = supplierDAO.getById(id);
        if (supplier != null) {
            supplier.setCode(WebUtil.param(request, "code"));
            supplier.setName(WebUtil.param(request, "name"));
            supplier.setPhone(WebUtil.param(request, "phone"));
            supplier.setEmail(WebUtil.param(request, "email"));
            supplier.setAddress(WebUtil.param(request, "address"));
            supplierDAO.update(supplier);
            WebUtil.setFlashSuccess(request, "Đã cập nhật nhà cung cấp");
        }
        WebUtil.redirect(request, response, "/admin/suppliers");
    }

    private void deleteSupplier(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        supplierDAO.delete(id);
        WebUtil.setFlashSuccess(request, "Đã xóa nhà cung cấp");
        WebUtil.redirect(request, response, "/admin/suppliers");
    }
}
