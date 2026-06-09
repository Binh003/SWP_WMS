package controller;

import dao.BrandDAO;
import model.Brand;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class BrandServlet extends HttpServlet {

    private final BrandDAO brandDAO = new BrandDAO();

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
        
        int totalItems = brandDAO.count(search);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }
        int offset = (page - 1) * limit;
        
        request.setAttribute("brands", brandDAO.findPaginated(search, offset, limit));
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("limit", limit);
        request.setAttribute("search", search);
        
        request.getRequestDispatcher("/jsp/admin/brands.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Brand brand = brandDAO.getById(id);
        if (brand == null) {
            WebUtil.setFlashError(request, "Không tìm thấy hãng");
            WebUtil.redirect(request, response, "/admin/brands");
            return;
        }
        request.setAttribute("brand", brand);
        request.getRequestDispatcher("/jsp/admin/brand-detail.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/admin/brand-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Brand brand = brandDAO.getById(id);
        if (brand == null) {
            WebUtil.setFlashError(request, "Không tìm thấy hãng");
            WebUtil.redirect(request, response, "/admin/brands");
            return;
        }
        request.setAttribute("brand", brand);
        request.getRequestDispatcher("/jsp/admin/brand-form.jsp").forward(request, response);
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
                default -> WebUtil.redirect(request, response, "/admin/brands");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/admin/brands");
        }
    }

    private void createBrand(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        Brand brand = new Brand();
        brand.setCode(WebUtil.param(request, "code"));
        brand.setName(WebUtil.param(request, "name"));
        brand.setDescription(WebUtil.param(request, "description"));

        brandDAO.insert(brand);
        WebUtil.setFlashSuccess(request, "Đã thêm hãng thành công");
        WebUtil.redirect(request, response, "/admin/brands");
    }

    private void updateBrand(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Brand brand = brandDAO.getById(id);
        if (brand != null) {
            brand.setCode(WebUtil.param(request, "code"));
            brand.setName(WebUtil.param(request, "name"));
            brand.setDescription(WebUtil.param(request, "description"));
            brandDAO.update(brand);
            WebUtil.setFlashSuccess(request, "Đã cập nhật hãng");
        }
        WebUtil.redirect(request, response, "/admin/brands");
    }

    private void deleteBrand(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        brandDAO.delete(id);
        WebUtil.setFlashSuccess(request, "Đã xóa hãng");
        WebUtil.redirect(request, response, "/admin/brands");
    }
}
