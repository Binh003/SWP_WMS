package controller;

import dao.ProductDAO;
import dao.ProductLineDAO;
import dao.InventoryDAO;
import model.Product;
import model.Inventory;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class ProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ProductLineDAO productLineDAO = new ProductLineDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();

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
                default -> listProducts(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("products", productDAO.getAll());
        request.getRequestDispatcher("/jsp/admin/products.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("productLines", productLineDAO.getAll());
        request.getRequestDispatcher("/jsp/admin/product-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Product product = productDAO.getById(id);
        if (product == null) {
            WebUtil.setFlashError(request, "Không tìm thấy sản phẩm");
            WebUtil.redirect(request, response, "/admin/products");
            return;
        }
        request.setAttribute("product", product);
        request.setAttribute("productLines", productLineDAO.getAll());
        request.getRequestDispatcher("/jsp/admin/product-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        String action = WebUtil.param(request, "action");
        try {
            switch (action) {
                case "create" -> createProduct(request, response);
                case "update" -> updateProduct(request, response);
                case "delete" -> deleteProduct(request, response);
                default -> WebUtil.redirect(request, response, "/admin/products");
            }
        } catch (SQLException ex) {
            WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            WebUtil.redirect(request, response, "/admin/products");
        }
    }

    private void createProduct(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        
        String sku = WebUtil.param(request, "sku");
        // Check if SKU exists
        if (productDAO.getBySku(sku) != null) {
            WebUtil.setFlashError(request, "Lỗi: SKU đã tồn tại trong hệ thống!");
            WebUtil.redirect(request, response, "/admin/products?action=create");
            return;
        }

        Product p = new Product();
        p.setProductLineId(Long.parseLong(WebUtil.param(request, "productLineId")));
        p.setSku(sku);
        p.setName(WebUtil.param(request, "name"));
        p.setUnit(WebUtil.param(request, "unit"));
        
        String priceStr = WebUtil.param(request, "price");
        if (priceStr != null && !priceStr.isEmpty()) {
            p.setPrice(Double.parseDouble(priceStr));
        }
        p.setDescription(WebUtil.param(request, "description"));

        productDAO.insert(p);
        
        // Initialize inventory for new product
        Inventory inv = new Inventory();
        inv.setProductId(p.getId()); // Get the generated ID
        inv.setQuantityInStock(0);
        inv.setMinStockLevel(0);
        inventoryDAO.insert(inv);

        WebUtil.setFlashSuccess(request, "Đã thêm sản phẩm thành công");
        WebUtil.redirect(request, response, "/admin/products");
    }

    private void updateProduct(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Product p = productDAO.getById(id);
        if (p != null) {
            String newSku = WebUtil.param(request, "sku");
            
            // Check SKU unique if changed
            if (!p.getSku().equals(newSku) && productDAO.getBySku(newSku) != null) {
                WebUtil.setFlashError(request, "Lỗi: SKU đã tồn tại trong hệ thống!");
                WebUtil.redirect(request, response, "/admin/products?action=edit&id=" + id);
                return;
            }

            p.setProductLineId(Long.parseLong(WebUtil.param(request, "productLineId")));
            p.setSku(newSku);
            p.setName(WebUtil.param(request, "name"));
            p.setUnit(WebUtil.param(request, "unit"));
            
            String priceStr = WebUtil.param(request, "price");
            if (priceStr != null && !priceStr.isEmpty()) {
                p.setPrice(Double.parseDouble(priceStr));
            } else {
                p.setPrice(null);
            }
            p.setDescription(WebUtil.param(request, "description"));
            
            productDAO.update(p);
            WebUtil.setFlashSuccess(request, "Đã cập nhật sản phẩm");
        }
        WebUtil.redirect(request, response, "/admin/products");
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        try {
            productDAO.delete(id);
            WebUtil.setFlashSuccess(request, "Đã xóa sản phẩm");
        } catch (SQLException ex) {
            // Cannot delete if there are foreign key constraints (e.g., inventory or orders)
            WebUtil.setFlashError(request, "Không thể xóa sản phẩm này vì có dữ liệu liên quan (tồn kho, phiếu nhập/xuất...).");
        }
        WebUtil.redirect(request, response, "/admin/products");
    }
}
