package controller;

import model.Supplier;
import service.SupplierService;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class SupplierServlet extends HttpServlet {

    private final SupplierService supplierService = new SupplierService();

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
            } catch (NumberFormatException ignored) {}
        }
        
        int limit = 10;
        String limitStr = request.getParameter("limit");
        if (limitStr != null && !limitStr.isEmpty()) {
            try {
                limit = Integer.parseInt(limitStr);
            } catch (NumberFormatException ignored) {}
        }
        
        SupplierService.SupplierPageResult result = supplierService.getSuppliersPaginated(search, page, limit);

        request.setAttribute("suppliers", result.getSuppliers());
        request.setAttribute("currentPage", result.getCurrentPage());
        request.setAttribute("totalPages", result.getTotalPages());
        request.setAttribute("totalItems", result.getTotalItems());
        request.setAttribute("limit", result.getLimit());
        request.setAttribute("search", search);
        
        request.getRequestDispatcher("/jsp/manage/suppliers.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Supplier supplier = supplierService.getById(id);
        if (supplier == null) {
            WebUtil.setFlashError(request, "Không tìm thấy nhà cung cấp");
            WebUtil.redirect(request, response, "/manage/suppliers");
            return;
        }
        request.setAttribute("supplier", supplier);
        request.getRequestDispatcher("/jsp/manage/supplier-detail.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/manage/supplier-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Supplier supplier = supplierService.getById(id);
        if (supplier == null) {
            WebUtil.setFlashError(request, "Không tìm thấy nhà cung cấp");
            WebUtil.redirect(request, response, "/manage/suppliers");
            return;
        }
        request.setAttribute("supplier", supplier);
        request.getRequestDispatcher("/jsp/manage/supplier-form.jsp").forward(request, response);
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
                default -> WebUtil.redirect(request, response, "/manage/suppliers");
            }
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1451 || (ex.getMessage() != null && ex.getMessage().contains("foreign key constraint fails"))) {
                WebUtil.setFlashModalError(request, "Không thể xóa nhà cung cấp này vì đang có dữ liệu (phiếu nhập kho) liên quan trong hệ thống.");
            } else {
                WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            }
            WebUtil.redirect(request, response, "/manage/suppliers");
        }
    }

    private void createSupplier(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        String code = WebUtil.param(request, "code");
        String name = WebUtil.param(request, "name");
        String phone = WebUtil.param(request, "phone");
        String email = WebUtil.param(request, "email");
        String address = WebUtil.param(request, "address");

        try {
            supplierService.createSupplier(code, name, phone, email, address);
            WebUtil.setFlashSuccess(request, "Đã thêm nhà cung cấp thành công");
            WebUtil.redirect(request, response, "/manage/suppliers");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/suppliers?action=create");
        }
    }

    private void updateSupplier(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String newCode = WebUtil.param(request, "code");
        String name = WebUtil.param(request, "name");
        String phone = WebUtil.param(request, "phone");
        String email = WebUtil.param(request, "email");
        String address = WebUtil.param(request, "address");

        try {
            supplierService.updateSupplier(id, newCode, name, phone, email, address);
            WebUtil.setFlashSuccess(request, "Đã cập nhật nhà cung cấp");
            WebUtil.redirect(request, response, "/manage/suppliers");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/suppliers?action=edit&id=" + id);
        }
    }

    private void deleteSupplier(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        try {
            supplierService.deleteSupplier(id);
            WebUtil.setFlashSuccess(request, "Đã xóa nhà cung cấp thành công!");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashModalError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/suppliers");
    }
}
