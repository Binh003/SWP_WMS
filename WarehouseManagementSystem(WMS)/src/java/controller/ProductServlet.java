package controller;

import dao.ProductDAO;
import dao.ProductLineDAO;
import dao.InventoryDAO;
import dao.BrandDAO;
import model.Product;
import model.Inventory;
import util.WebUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.sql.SQLException;

@jakarta.servlet.annotation.MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ProductLineDAO productLineDAO = new ProductLineDAO();
    private final InventoryDAO inventoryDAO = new InventoryDAO();
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
                case "view" -> showProductDetail(request, response);
                default -> listProducts(request, response);
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void showProductDetail(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Product product = productDAO.getById(id);
        if (product == null) {
            WebUtil.setFlashError(request, "Không tìm thấy sản phẩm");
            WebUtil.redirect(request, response, "/admin/products");
            return;
        }
        Inventory inventory = inventoryDAO.getByProductId(id);
        request.setAttribute("product", product);
        request.setAttribute("inventory", inventory);
        request.getRequestDispatcher("/jsp/admin/product-detail.jsp").forward(request, response);
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        int page = 1;
        int limit = 10;
        String pageParam = request.getParameter("page");
        String limitParam = request.getParameter("limit");
        
        if (pageParam != null && !pageParam.isEmpty()) {
            try { page = Integer.parseInt(pageParam); } catch (NumberFormatException ignored) {}
        }
        if (limitParam != null && !limitParam.isEmpty()) {
            try { limit = Integer.parseInt(limitParam); } catch (NumberFormatException ignored) {}
        }
        
        String search = request.getParameter("search");
        if (search != null) search = search.trim();
        
        String brandIdParam = request.getParameter("brandId");
        String productLineIdParam = request.getParameter("productLineId");
        
        Long brandId = null;
        Long productLineId = null;
        
        if (brandIdParam != null && !brandIdParam.isEmpty()) {
            try { brandId = Long.parseLong(brandIdParam); } catch (NumberFormatException ignored) {}
        }
        if (productLineIdParam != null && !productLineIdParam.isEmpty()) {
            try { productLineId = Long.parseLong(productLineIdParam); } catch (NumberFormatException ignored) {}
        }
        
        java.util.List<Product> products = productDAO.findPaginated(page, limit, search, brandId, productLineId);
        int totalItems = productDAO.count(search, brandId, productLineId);
        int totalPages = (int) Math.ceil((double) totalItems / limit);
        
        request.setAttribute("products", products);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("limit", limit);
        request.setAttribute("search", search);
        request.setAttribute("selectedBrandId", brandId);
        request.setAttribute("selectedProductLineId", productLineId);
        request.setAttribute("brands", brandDAO.getAll());
        request.setAttribute("productLines", productLineDAO.getAll());
        
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
        throws SQLException, IOException, ServletException {
        
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
            try {
                double price = Double.parseDouble(priceStr);
                if (price < 0) {
                    WebUtil.setFlashError(request, "Lỗi: Giá bán không được nhỏ hơn 0!");
                    WebUtil.redirect(request, response, "/admin/products?action=create");
                    return;
                }
                p.setPrice(price);
            } catch (NumberFormatException e) {
                WebUtil.setFlashError(request, "Lỗi: Giá bán không hợp lệ!");
                WebUtil.redirect(request, response, "/admin/products?action=create");
                return;
            }
        }
        p.setDescription(WebUtil.param(request, "description"));
        p.setImageUrl(handleFileUpload(request));

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
        throws SQLException, IOException, ServletException {
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
                try {
                    double price = Double.parseDouble(priceStr);
                    if (price < 0) {
                        WebUtil.setFlashError(request, "Lỗi: Giá bán không được nhỏ hơn 0!");
                        WebUtil.redirect(request, response, "/admin/products?action=edit&id=" + id);
                        return;
                    }
                    p.setPrice(price);
                } catch (NumberFormatException e) {
                    WebUtil.setFlashError(request, "Lỗi: Giá bán không hợp lệ!");
                    WebUtil.redirect(request, response, "/admin/products?action=edit&id=" + id);
                    return;
                }
            } else {
                p.setPrice(null);
            }
            p.setDescription(WebUtil.param(request, "description"));
            p.setImageUrl(handleFileUpload(request));
            
            productDAO.update(p);
            WebUtil.setFlashSuccess(request, "Đã cập nhật sản phẩm");
        }
        WebUtil.redirect(request, response, "/admin/products");
    }

    private String handleFileUpload(HttpServletRequest request) throws ServletException, IOException {
        String contentType = request.getContentType();
        if (contentType == null || !contentType.toLowerCase().startsWith("multipart/form-data")) {
            String url = WebUtil.param(request, "imageUrl");
            return url.isEmpty() ? null : url;
        }
        
        try {
            Part filePart = request.getPart("imageFile");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = java.nio.file.Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                String extension = "";
                int i = fileName.lastIndexOf('.');
                if (i > 0) {
                    extension = fileName.substring(i);
                }
                String uniqueFileName = "prod_" + System.currentTimeMillis() + "_" + java.util.UUID.randomUUID().toString().substring(0, 8) + extension;
                
                String relativePath = "uploads/products/" + uniqueFileName;
                
                // 1. Deploy path
                String deployPath = request.getServletContext().getRealPath("/") + "uploads/products";
                java.io.File deployDir = new java.io.File(deployPath);
                if (!deployDir.exists()) deployDir.mkdirs();
                filePart.write(deployPath + java.io.File.separator + uniqueFileName);
                
                // 2. Source path
                String workspacePath = "d:\\InventoryTrackingSystem\\WMS\\WarehouseManagementSystem(WMS)";
                String srcPath = workspacePath + java.io.File.separator + "web" + java.io.File.separator + "uploads" + java.io.File.separator + "products";
                java.io.File srcDir = new java.io.File(srcPath);
                if (srcDir.exists() || srcDir.mkdirs()) {
                    try {
                        java.nio.file.Files.copy(
                            java.nio.file.Paths.get(deployPath + java.io.File.separator + uniqueFileName),
                            java.nio.file.Paths.get(srcPath + java.io.File.separator + uniqueFileName),
                            java.nio.file.StandardCopyOption.REPLACE_EXISTING
                        );
                    } catch (Exception ignored) {}
                }
                
                return "/" + relativePath;
            }
        } catch (Exception ignored) {}
        
        String url = WebUtil.param(request, "imageUrl");
        return url.isEmpty() ? null : url;
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
