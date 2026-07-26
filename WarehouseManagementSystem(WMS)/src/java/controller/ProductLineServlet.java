package controller;

import model.ProductLine;
import service.ProductLineService;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class ProductLineServlet extends HttpServlet {

    private final ProductLineService productLineService = new ProductLineService();

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
            } catch (NumberFormatException ignored) {}
        }
        
        int limit = 10;
        String limitStr = request.getParameter("limit");
        if (limitStr != null && !limitStr.isEmpty()) {
            try {
                limit = Integer.parseInt(limitStr);
            } catch (NumberFormatException ignored) {}
        }
        
        ProductLineService.ProductLinePageResult result = productLineService.getProductLinesPaginated(search, brandId, page, limit);

        request.setAttribute("productLines", result.getProductLines());
        request.setAttribute("currentPage", result.getCurrentPage());
        request.setAttribute("totalPages", result.getTotalPages());
        request.setAttribute("totalItems", result.getTotalItems());
        request.setAttribute("limit", result.getLimit());
        request.setAttribute("search", search);
        request.setAttribute("selectedBrandId", brandId);
        request.setAttribute("brands", result.getAllBrands());
        
        request.getRequestDispatcher("/jsp/manage/product-lines.jsp").forward(request, response);
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        ProductLine productLine = productLineService.getById(id);
        if (productLine == null) {
            WebUtil.setFlashError(request, "Không tìm thấy dòng sản phẩm");
            WebUtil.redirect(request, response, "/manage/product-lines");
            return;
        }
        request.setAttribute("productLine", productLine);
        request.getRequestDispatcher("/jsp/manage/product-line-detail.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("brands", productLineService.getAllBrands());
        request.getRequestDispatcher("/jsp/manage/product-line-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        ProductLine productLine = productLineService.getById(id);
        if (productLine == null) {
            WebUtil.setFlashError(request, "Không tìm thấy dòng sản phẩm");
            WebUtil.redirect(request, response, "/manage/product-lines");
            return;
        }
        request.setAttribute("productLine", productLine);
        request.setAttribute("brands", productLineService.getAllBrands());
        request.getRequestDispatcher("/jsp/manage/product-line-form.jsp").forward(request, response);
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
                default -> WebUtil.redirect(request, response, "/manage/product-lines");
            }
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1451 || (ex.getMessage() != null && ex.getMessage().contains("foreign key constraint fails"))) {
                WebUtil.setFlashModalError(request, "Không thể xóa dòng sản phẩm này vì đang có dữ liệu (sản phẩm) thuộc dòng sản phẩm tồn tại trong hệ thống.");
            } else {
                WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            }
            WebUtil.redirect(request, response, "/manage/product-lines");
        }
    }

    private void createProductLine(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long brandId = Long.parseLong(WebUtil.param(request, "brandId"));
        String code = WebUtil.param(request, "code");
        String name = WebUtil.param(request, "name");
        String description = WebUtil.param(request, "description");

        try {
            productLineService.createProductLine(brandId, code, name, description);
            WebUtil.setFlashSuccess(request, "Đã thêm dòng sản phẩm thành công");
            WebUtil.redirect(request, response, "/manage/product-lines");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/product-lines?action=create");
        }
    }

    private void updateProductLine(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        long brandId = Long.parseLong(WebUtil.param(request, "brandId"));
        String newCode = WebUtil.param(request, "code");
        String name = WebUtil.param(request, "name");
        String description = WebUtil.param(request, "description");

        try {
            productLineService.updateProductLine(id, brandId, newCode, name, description);
            WebUtil.setFlashSuccess(request, "Đã cập nhật dòng sản phẩm");
            WebUtil.redirect(request, response, "/manage/product-lines");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/product-lines?action=edit&id=" + id);
        }
    }

    private void deleteProductLine(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        try {
            productLineService.deleteProductLine(id);
            WebUtil.setFlashSuccess(request, "Đã xóa dòng sản phẩm thành công!");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashModalError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/product-lines");
    }
}
