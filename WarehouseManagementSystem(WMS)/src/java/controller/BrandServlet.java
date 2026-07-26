package controller;

import model.Brand;
import service.BrandService;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class BrandServlet extends HttpServlet {

    private final BrandService brandService = new BrandService();

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
                default -> listBrands(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listBrands(HttpServletRequest request, HttpServletResponse response)
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
        
        BrandService.BrandPageResult result = brandService.getBrandsPaginated(search, page, limit);

        request.setAttribute("brands", result.getBrands());
        request.setAttribute("currentPage", result.getCurrentPage());
        request.setAttribute("totalPages", result.getTotalPages());
        request.setAttribute("totalItems", result.getTotalItems());
        request.setAttribute("limit", result.getLimit());
        request.setAttribute("search", search);
        
        request.getRequestDispatcher("/jsp/manage/brands.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Brand brand = brandService.getById(id);
        if (brand == null) {
            WebUtil.setFlashError(request, "Không tìm thấy hãng");
            WebUtil.redirect(request, response, "/manage/brands");
            return;
        }
        request.setAttribute("brand", brand);
        request.getRequestDispatcher("/jsp/manage/brand-detail.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/manage/brand-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Brand brand = brandService.getById(id);
        if (brand == null) {
            WebUtil.setFlashError(request, "Không tìm thấy hãng");
            WebUtil.redirect(request, response, "/manage/brands");
            return;
        }
        request.setAttribute("brand", brand);
        request.getRequestDispatcher("/jsp/manage/brand-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        try {
            switch (action) {
                case "create" -> createBrand(request, response);
                case "update" -> updateBrand(request, response);
                case "delete" -> deleteBrand(request, response);
                default -> WebUtil.redirect(request, response, "/manage/brands");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            WebUtil.redirect(request, response, "/manage/brands");
        }
    }

    private void createBrand(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        String code = WebUtil.param(request, "code");
        String name = WebUtil.param(request, "name");
        String description = WebUtil.param(request, "description");

        try {
            brandService.createBrand(code, name, description);
            WebUtil.setFlashSuccess(request, "Đã thêm hãng thành công");
            WebUtil.redirect(request, response, "/manage/brands");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/brands?action=create");
        }
    }

    private void updateBrand(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        String newCode = WebUtil.param(request, "code");
        String name = WebUtil.param(request, "name");
        String description = WebUtil.param(request, "description");

        try {
            brandService.updateBrand(id, newCode, name, description);
            WebUtil.setFlashSuccess(request, "Đã cập nhật hãng");
            WebUtil.redirect(request, response, "/manage/brands");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/brands?action=edit&id=" + id);
        }
    }

    private void deleteBrand(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        brandService.deleteBrand(id);
        WebUtil.setFlashSuccess(request, "Đã xóa hãng");
        WebUtil.redirect(request, response, "/manage/brands");
    }
}
