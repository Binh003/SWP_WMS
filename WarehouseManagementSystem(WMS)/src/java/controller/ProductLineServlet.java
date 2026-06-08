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
                default -> listProductLines(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listProductLines(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("productLines", productLineDAO.getAll());
        request.getRequestDispatcher("/jsp/admin/product-lines.jsp").forward(request, response);
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
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/admin/product-lines");
        }
    }

    private void createProductLine(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        ProductLine pl = new ProductLine();
        pl.setBrandId(Long.parseLong(WebUtil.param(request, "brandId")));
        pl.setCode(WebUtil.param(request, "code"));
        pl.setName(WebUtil.param(request, "name"));
        pl.setDescription(WebUtil.param(request, "description"));

        productLineDAO.insert(pl);
        WebUtil.setFlashSuccess(request, "Đã thêm dòng sản phẩm thành công");
        WebUtil.redirect(request, response, "/admin/product-lines");
    }

    private void updateProductLine(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        ProductLine pl = productLineDAO.getById(id);
        if (pl != null) {
            pl.setBrandId(Long.parseLong(WebUtil.param(request, "brandId")));
            pl.setCode(WebUtil.param(request, "code"));
            pl.setName(WebUtil.param(request, "name"));
            pl.setDescription(WebUtil.param(request, "description"));
            productLineDAO.update(pl);
            WebUtil.setFlashSuccess(request, "Đã cập nhật dòng sản phẩm");
        }
        WebUtil.redirect(request, response, "/admin/product-lines");
    }

    private void deleteProductLine(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        productLineDAO.delete(id);
        WebUtil.setFlashSuccess(request, "Đã xóa dòng sản phẩm");
        WebUtil.redirect(request, response, "/admin/product-lines");
    }
}
