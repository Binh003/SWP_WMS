package controller;

import model.Product;
import model.Inventory;
import service.ProductService;
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

    private final ProductService productService = new ProductService();

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
        Product product = productService.getById(id);
        if (product == null) {
            WebUtil.setFlashError(request, "Không tìm thấy sản phẩm");
            WebUtil.redirect(request, response, "/manage/products");
            return;
        }
        Inventory inventory = productService.getInventoryByProductId(id);
        request.setAttribute("product", product);
        request.setAttribute("inventory", inventory);
        request.getRequestDispatcher("/jsp/manage/product-detail.jsp").forward(request, response);
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
        
        ProductService.ProductPageResult result = productService.getProductsPaginated(page, limit, search, brandId, productLineId);

        request.setAttribute("products", result.getProducts());
        request.setAttribute("totalItems", result.getTotalItems());
        request.setAttribute("totalPages", result.getTotalPages());
        request.setAttribute("currentPage", result.getCurrentPage());
        request.setAttribute("limit", result.getLimit());
        request.setAttribute("search", search);
        request.setAttribute("selectedBrandId", brandId);
        request.setAttribute("selectedProductLineId", productLineId);
        request.setAttribute("brands", result.getAllBrands());
        request.setAttribute("productLines", result.getAllProductLines());
        
        request.getRequestDispatcher("/jsp/manage/products.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        request.setAttribute("productLines", productService.getAllProductLines());
        request.getRequestDispatcher("/jsp/manage/product-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, ServletException, IOException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        Product product = productService.getById(id);
        if (product == null) {
            WebUtil.setFlashError(request, "Không tìm thấy sản phẩm");
            WebUtil.redirect(request, response, "/manage/products");
            return;
        }
        request.setAttribute("product", product);
        request.setAttribute("productLines", productService.getAllProductLines());
        request.getRequestDispatcher("/jsp/manage/product-form.jsp").forward(request, response);
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
                default -> WebUtil.redirect(request, response, "/manage/products");
            }
        } catch (SQLException ex) {
            if (ex.getErrorCode() == 1451 || (ex.getMessage() != null && ex.getMessage().contains("foreign key constraint fails"))) {
                WebUtil.setFlashModalError(request, "Không thể xóa sản phẩm này vì đang có dữ liệu (tồn kho, phiếu nhập/xuất) liên quan trong hệ thống.");
            } else {
                WebUtil.setFlashError(request, "Lỗi cơ sở dữ liệu: " + ex.getMessage());
            }
            WebUtil.redirect(request, response, "/manage/products");
        }
    }

    private void createProduct(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        
        long productLineId = Long.parseLong(WebUtil.param(request, "productLineId"));
        String sku = WebUtil.param(request, "sku");
        String name = WebUtil.param(request, "name");
        String unit = WebUtil.param(request, "unit");
        String priceStr = WebUtil.param(request, "price");
        String description = WebUtil.param(request, "description");
        String imageUrl = handleFileUpload(request);

        try {
            productService.createProduct(productLineId, sku, name, unit, priceStr, description, imageUrl);
            WebUtil.setFlashSuccess(request, "Đã thêm sản phẩm thành công");
            WebUtil.redirect(request, response, "/manage/products");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/products?action=create");
        }
    }

    private void updateProduct(HttpServletRequest request, HttpServletResponse response)
        throws SQLException, IOException, ServletException {
        long id = Long.parseLong(WebUtil.param(request, "id"));
        long productLineId = Long.parseLong(WebUtil.param(request, "productLineId"));
        String sku = WebUtil.param(request, "sku");
        String name = WebUtil.param(request, "name");
        String unit = WebUtil.param(request, "unit");
        String priceStr = WebUtil.param(request, "price");
        String description = WebUtil.param(request, "description");
        String imageUrl = handleFileUpload(request);

        try {
            productService.updateProduct(id, productLineId, sku, name, unit, priceStr, description, imageUrl);
            WebUtil.setFlashSuccess(request, "Đã cập nhật sản phẩm");
            WebUtil.redirect(request, response, "/manage/products");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashError(request, ex.getMessage());
            WebUtil.redirect(request, response, "/manage/products?action=edit&id=" + id);
        }
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
                String workspacePath = util.WebUtil.getWorkspacePath(request);
                if (workspacePath != null) {
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
            productService.deleteProduct(id);
            WebUtil.setFlashSuccess(request, "Đã xóa sản phẩm thành công!");
        } catch (IllegalArgumentException ex) {
            WebUtil.setFlashModalError(request, ex.getMessage());
        }
        WebUtil.redirect(request, response, "/manage/products");
    }
}
