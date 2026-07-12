package controller;

import dao.BrandDAO;
import dao.ProductLineDAO;
import model.ProductLine;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class ProductLineServlet extends HttpServlet {

    private final ProductLineDAO productLineDAO = new ProductLineDAO();
    private final BrandDAO brandDAO = new BrandDAO(); // Lấy danh sách hãng cho dropdown

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
                default -> listProductLines(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listProductLines(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        String search = request.getParameter("search");
        if (search == null) {
            search = "";
        }

        String brandIdStr = request.getParameter("brandId");
        Long brandId = null;
        if (brandIdStr != null && !brandIdStr.trim().isEmpty() && !"all".equals(brandIdStr)) {
            try {
                brandId = Long.parseLong(brandIdStr);
            } catch (NumberFormatException ignored) {}
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
        
        int totalItems = productLineDAO.count(search, brandId);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        if (page > totalPages && totalPages > 0) {
            page = totalPages;
        }
        int offset = (page - 1) * limit;
        
        request.setAttribute("productLines", productLineDAO.findPaginated(search, brandId, offset, limit));
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("limit", limit);
        request.setAttribute("search", search);
        request.setAttribute("selectedBrandId", brandId);
        request.setAttribute("brands", brandDAO.getAll());
        
        request.getRequestDispatcher("/jsp/admin/product-lines.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        ProductLine productLine = productLineDAO.getById(id);
        if (productLine == null) {
            WebUtil.setFlashError(request, "Không tìm thấy dòng sản phẩm");
            WebUtil.redirect(request, response, "/admin/product-lines");
            return;
        }
        request.setAttribute("productLine", productLine);
        request.getRequestDispatcher("/jsp/admin/product-line-detail.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("brands", brandDAO.getAll());
        request.getRequestDispatcher("/jsp/admin/product-line-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        ProductLine productLine = productLineDAO.getById(id);
        if (productLine == null) {
            WebUtil.setFlashError(request, "Không tìm thấy dòng sản phẩm");
            WebUtil.redirect(request, response, "/admin/product-lines");
            return;
        }
        request.setAttribute("productLine", productLine);
        request.setAttribute("brands", brandDAO.getAll());
        request.getRequestDispatcher("/jsp/admin/product-line-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        try {
            switch (action) {
                case "create" -> createProductLine(request, response);
                case "update" -> updateProductLine(request, response);
                case "delete" -> deleteProductLine(request, response);
                default -> WebUtil.redirect(request, response, "/admin/product-lines");
            }
        } catch (SQLException ex) {
            String msg = ex.getMessage();
            if (ex.getErrorCode() == 1062 || (msg != null && msg.contains("Duplicate entry"))) {
                WebUtil.setFlashError(request, "Lỗi: Dòng sản phẩm này đã tồn tại (Mã dòng sản phẩm đã được sử dụng)!");
            } else {
                WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + msg);
            }
            WebUtil.redirect(request, response, "/admin/product-lines");
        }
    }

    private void createProductLine(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long brandId = Long.parseLong(WebUtil.param(request, "brandId"));
        String code = WebUtil.param(request, "code");
        String name = WebUtil.param(request, "name");
        String description = WebUtil.param(request, "description");

        // Validate beforehand
        if (productLineDAO.getByCode(code) != null) {
            WebUtil.setFlashError(request, "Lỗi: Dòng sản phẩm này đã tồn tại (Mã dòng sản phẩm '" + code + "' đã được sử dụng)!");
            WebUtil.redirect(request, response, "/admin/product-lines?action=create");
            return;
        }

        ProductLine pl = new ProductLine();
        pl.setBrandId(brandId);
        pl.setCode(code);
        pl.setName(name);
        pl.setDescription(description);

        try {
            productLineDAO.insert(pl);
            WebUtil.setFlashSuccess(request, "Đã thêm dòng sản phẩm thành công");
            WebUtil.redirect(request, response, "/admin/product-lines");
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1062 || (ex.getMessage() != null && ex.getMessage().contains("Duplicate entry"))) {
                WebUtil.setFlashError(request, "Lỗi: Dòng sản phẩm này đã tồn tại (Mã dòng sản phẩm '" + code + "' đã được sử dụng)!");
                WebUtil.redirect(request, response, "/admin/product-lines?action=create");
            } else {
                throw ex;
            }
        }
    }

    private void updateProductLine(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        ProductLine pl = productLineDAO.getById(id);
        if (pl != null) {
            String newCode = WebUtil.param(request, "code");
            
            // Check if code has changed and if the new code already exists
            if (!pl.getCode().equalsIgnoreCase(newCode)) {
                ProductLine existing = productLineDAO.getByCode(newCode);
                if (existing != null && existing.getId() != id) {
                    WebUtil.setFlashError(request, "Lỗi: Dòng sản phẩm này đã tồn tại (Mã dòng sản phẩm '" + newCode + "' đã được sử dụng)!");
                    WebUtil.redirect(request, response, "/admin/product-lines?action=edit&id=" + id);
                    return;
                }
            }

            pl.setBrandId(Long.parseLong(WebUtil.param(request, "brandId")));
            pl.setCode(newCode);
            pl.setName(WebUtil.param(request, "name"));
            pl.setDescription(WebUtil.param(request, "description"));
            
            try {
                productLineDAO.update(pl);
                WebUtil.setFlashSuccess(request, "Đã cập nhật dòng sản phẩm");
                WebUtil.redirect(request, response, "/admin/product-lines");
            } catch (SQLException ex) {
                if (ex.getErrorCode() == 1062 || (ex.getMessage() != null && ex.getMessage().contains("Duplicate entry"))) {
                    WebUtil.setFlashError(request, "Lỗi: Dòng sản phẩm này đã tồn tại (Mã dòng sản phẩm '" + newCode + "' đã được sử dụng)!");
                    WebUtil.redirect(request, response, "/admin/product-lines?action=edit&id=" + id);
                } else {
                    throw ex;
                }
            }
        } else {
            WebUtil.setFlashError(request, "Không tìm thấy dòng sản phẩm");
            WebUtil.redirect(request, response, "/admin/product-lines");
        }
    }

    private void deleteProductLine(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        productLineDAO.delete(id);
        WebUtil.setFlashSuccess(request, "Đã xóa dòng sản phẩm");
        WebUtil.redirect(request, response, "/admin/product-lines");
    }
}
