package service;

import dao.BrandDAO;
import dao.ProductLineDAO;
import dao.ReceiptDAO;
import dao.ReportDAO;
import dao.ShipmentDAO;
import model.Brand;
import model.ProductLine;
import model.Receipt;
import model.ReceiptDetail;
import model.Shipment;
import model.ShipmentDetail;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Map;

public class ReportService {

    private final ReportDAO reportDAO = new ReportDAO();
    private final BrandDAO brandDAO = new BrandDAO();
    private final ProductLineDAO productLineDAO = new ProductLineDAO();
    private final ReceiptDAO receiptDAO = new ReceiptDAO();
    private final ShipmentDAO shipmentDAO = new ShipmentDAO();

    public String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\b", "\\b")
                    .replace("\f", "\\f")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }

    public String getReceiptDetailJson(long id) throws SQLException {
        Receipt receipt = receiptDAO.getById(id);
        if (receipt == null) {
            return "{\"error\":\"Không tìm thấy phiếu nhập kho\"}";
        }

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"id\":").append(receipt.getId()).append(",");
        json.append("\"code\":\"").append(escapeJson(receipt.getReceiptCode())).append("\",");
        json.append("\"createdAt\":\"").append(receipt.getCreatedAt() != null ? sdf.format(receipt.getCreatedAt()) : "").append("\",");
        json.append("\"supplierName\":\"").append(receipt.getSupplier() != null ? escapeJson(receipt.getSupplier().getName()) : "").append("\",");
        json.append("\"creatorName\":\"").append(receipt.getCreator() != null ? escapeJson(receipt.getCreator().getFullName()) : "").append("\",");
        json.append("\"status\":\"").append(escapeJson(receipt.getStatus())).append("\",");
        json.append("\"invoiceImage\":\"").append(receipt.getInvoiceImage() != null ? escapeJson(receipt.getInvoiceImage()) : "").append("\",");

        int totalQty = 0;
        double totalVal = 0.0;
        StringBuilder detailsJson = new StringBuilder("[");
        if (receipt.getDetails() != null) {
            for (int i = 0; i < receipt.getDetails().size(); i++) {
                ReceiptDetail d = receipt.getDetails().get(i);
                int qty = d.getQuantity() != null ? d.getQuantity() : 0;
                double price = (d.getProduct() != null && d.getProduct().getPrice() != null) ? d.getProduct().getPrice() : 0.0;
                double lineVal = qty * price;
                totalQty += qty;
                totalVal += lineVal;

                if (i > 0) detailsJson.append(",");
                detailsJson.append("{");
                detailsJson.append("\"id\":").append(d.getId()).append(",");
                detailsJson.append("\"sku\":\"").append(d.getProduct() != null ? escapeJson(d.getProduct().getSku()) : "").append("\",");
                detailsJson.append("\"productName\":\"").append(d.getProduct() != null ? escapeJson(d.getProduct().getName()) : "").append("\",");
                detailsJson.append("\"unit\":\"").append(d.getProduct() != null ? escapeJson(d.getProduct().getUnit()) : "").append("\",");
                detailsJson.append("\"batchCode\":\"").append(escapeJson(d.getBatchCode())).append("\",");
                detailsJson.append("\"barcode\":\"").append(escapeJson(d.getBarcode())).append("\",");
                detailsJson.append("\"quantity\":").append(qty).append(",");
                detailsJson.append("\"price\":").append(price).append(",");
                detailsJson.append("\"totalVal\":").append(lineVal);
                detailsJson.append("}");
            }
        }
        detailsJson.append("]");

        json.append("\"totalQty\":").append(totalQty).append(",");
        json.append("\"totalVal\":").append(totalVal).append(",");
        json.append("\"details\":").append(detailsJson);
        json.append("}");

        return json.toString();
    }

    public String getShipmentDetailJson(long id) throws SQLException {
        Shipment shipment = shipmentDAO.getById(id);
        if (shipment == null) {
            return "{\"error\":\"Không tìm thấy phiếu xuất kho\"}";
        }

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"id\":").append(shipment.getId()).append(",");
        json.append("\"code\":\"").append(escapeJson(shipment.getShipmentCode())).append("\",");
        json.append("\"createdAt\":\"").append(shipment.getCreatedAt() != null ? sdf.format(shipment.getCreatedAt()) : "").append("\",");
        json.append("\"destination\":\"").append(escapeJson(shipment.getDestination())).append("\",");
        json.append("\"creatorName\":\"").append(shipment.getCreator() != null ? escapeJson(shipment.getCreator().getFullName()) : "").append("\",");
        json.append("\"status\":\"").append(escapeJson(shipment.getStatus())).append("\",");
        json.append("\"deliveryNoteImage\":\"").append(shipment.getDeliveryNoteImage() != null ? escapeJson(shipment.getDeliveryNoteImage()) : "").append("\",");
        json.append("\"shippingImages\":\"").append(shipment.getShippingImages() != null ? escapeJson(shipment.getShippingImages()) : "").append("\",");
        json.append("\"notes\":\"").append(shipment.getNotes() != null ? escapeJson(shipment.getNotes()) : "").append("\",");

        int totalQty = 0;
        double totalVal = 0.0;
        StringBuilder detailsJson = new StringBuilder("[");
        if (shipment.getDetails() != null) {
            for (int i = 0; i < shipment.getDetails().size(); i++) {
                ShipmentDetail d = shipment.getDetails().get(i);
                int qty = d.getQuantity() != null ? d.getQuantity() : 0;
                double price = (d.getProduct() != null && d.getProduct().getPrice() != null) ? d.getProduct().getPrice() : 0.0;
                double lineVal = qty * price;
                totalQty += qty;
                totalVal += lineVal;

                if (i > 0) detailsJson.append(",");
                detailsJson.append("{");
                detailsJson.append("\"id\":").append(d.getId()).append(",");
                detailsJson.append("\"sku\":\"").append(d.getProduct() != null ? escapeJson(d.getProduct().getSku()) : "").append("\",");
                detailsJson.append("\"productName\":\"").append(d.getProduct() != null ? escapeJson(d.getProduct().getName()) : "").append("\",");
                detailsJson.append("\"unit\":\"").append(d.getProduct() != null ? escapeJson(d.getProduct().getUnit()) : "").append("\",");
                detailsJson.append("\"batchCode\":\"").append(escapeJson(d.getBatchCode())).append("\",");
                detailsJson.append("\"barcode\":\"").append(escapeJson(d.getBarcode())).append("\",");
                detailsJson.append("\"quantity\":").append(qty).append(",");
                detailsJson.append("\"price\":").append(price).append(",");
                detailsJson.append("\"totalVal\":").append(lineVal);
                detailsJson.append("}");
            }
        }
        detailsJson.append("]");

        json.append("\"totalQty\":").append(totalQty).append(",");
        json.append("\"totalVal\":").append(totalVal).append(",");
        json.append("\"details\":").append(detailsJson);
        json.append("}");

        return json.toString();
    }

    public String getInventoryDetailJson(long productId) throws SQLException {
        Map<String, Object> detail = reportDAO.getInventoryProductDetail(productId);
        if (detail == null) {
            return "{\"error\":\"Không tìm thấy thông tin tồn kho cho sản phẩm này\"}";
        }

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"productId\":").append(detail.get("productId")).append(",");
        json.append("\"sku\":\"").append(escapeJson((String) detail.get("sku"))).append("\",");
        json.append("\"productName\":\"").append(escapeJson((String) detail.get("productName"))).append("\",");
        json.append("\"unit\":\"").append(escapeJson((String) detail.get("unit"))).append("\",");
        json.append("\"price\":").append(detail.get("price")).append(",");
        json.append("\"brandName\":\"").append(escapeJson((String) detail.get("brandName"))).append("\",");
        json.append("\"productLineName\":\"").append(escapeJson((String) detail.get("productLineName"))).append("\",");
        json.append("\"totalStock\":").append(detail.get("totalStock")).append(",");
        json.append("\"minStockLevel\":").append(detail.get("minStockLevel")).append(",");
        json.append("\"totalValuation\":").append(detail.get("totalValuation")).append(",");
        json.append("\"isLow\":").append(detail.get("isLow")).append(",");

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> batches = (List<Map<String, Object>>) detail.get("batches");
        StringBuilder batchesJson = new StringBuilder("[");
        if (batches != null) {
            for (int i = 0; i < batches.size(); i++) {
                Map<String, Object> b = batches.get(i);
                if (i > 0) batchesJson.append(",");
                batchesJson.append("{");
                batchesJson.append("\"id\":").append(b.get("id")).append(",");
                batchesJson.append("\"batchCode\":\"").append(escapeJson((String) b.get("batchCode"))).append("\",");
                batchesJson.append("\"barcode\":\"").append(escapeJson((String) b.get("barcode"))).append("\",");
                batchesJson.append("\"location\":\"").append(escapeJson((String) b.get("location"))).append("\",");
                batchesJson.append("\"quantity\":").append(b.get("quantity")).append(",");
                java.sql.Timestamp ts = (java.sql.Timestamp) b.get("createdAt");
                batchesJson.append("\"createdAt\":\"").append(ts != null ? sdf.format(ts) : "").append("\"");
                batchesJson.append("}");
            }
        }
        batchesJson.append("]");
        json.append("\"batches\":").append(batchesJson);
        json.append("}");

        return json.toString();
    }

    public String getNXTDetailJson(long productId, String start, String end) throws SQLException {
        Map<String, Object> detail = reportDAO.getNXTProductDetailHistory(productId, start, end);
        if (detail == null) {
            return "{\"error\":\"Không tìm thấy thông tin Nhập Xuất Tồn cho sản phẩm này\"}";
        }

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"productId\":").append(detail.get("productId")).append(",");
        json.append("\"sku\":\"").append(escapeJson((String) detail.get("sku"))).append("\",");
        json.append("\"productName\":\"").append(escapeJson((String) detail.get("productName"))).append("\",");
        json.append("\"unit\":\"").append(escapeJson((String) detail.get("unit"))).append("\",");
        json.append("\"price\":").append(detail.get("price")).append(",");
        json.append("\"brandName\":\"").append(escapeJson((String) detail.get("brandName"))).append("\",");
        json.append("\"productLineName\":\"").append(escapeJson((String) detail.get("productLineName"))).append("\",");
        json.append("\"startDate\":\"").append(escapeJson(start)).append("\",");
        json.append("\"endDate\":\"").append(escapeJson(end)).append("\",");
        json.append("\"beginningQty\":").append(detail.get("beginningQty")).append(",");
        json.append("\"inboundQty\":").append(detail.get("inboundQty")).append(",");
        json.append("\"outboundQty\":").append(detail.get("outboundQty")).append(",");
        json.append("\"endingQty\":").append(detail.get("endingQty")).append(",");
        json.append("\"endingValuation\":").append(detail.get("endingValuation")).append(",");

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> txs = (List<Map<String, Object>>) detail.get("transactions");
        StringBuilder txJson = new StringBuilder("[");
        if (txs != null) {
            for (int i = 0; i < txs.size(); i++) {
                Map<String, Object> t = txs.get(i);
                if (i > 0) txJson.append(",");
                txJson.append("{");
                txJson.append("\"type\":\"").append(t.get("type")).append("\",");
                txJson.append("\"code\":\"").append(escapeJson((String) t.get("code"))).append("\",");
                java.sql.Timestamp ts = (java.sql.Timestamp) t.get("createdAt");
                txJson.append("\"createdAt\":\"").append(ts != null ? sdf.format(ts) : "").append("\",");
                txJson.append("\"qty\":").append(t.get("qty")).append(",");
                txJson.append("\"partner\":\"").append(escapeJson((String) t.get("partner"))).append("\",");
                txJson.append("\"creator\":\"").append(escapeJson((String) t.get("creator"))).append("\"");
                txJson.append("}");
            }
        }
        txJson.append("]");
        json.append("\"transactions\":").append(txJson);
        json.append("}");

        return json.toString();
    }

    public Map<String, Object> getOverviewStats() throws SQLException {
        return reportDAO.getOverviewStats();
    }

    public List<Map<String, Object>> getMonthlyStats() throws SQLException {
        return reportDAO.getMonthlyInboundOutboundStats();
    }

    public List<Map<String, Object>> getBrandValuationStats() throws SQLException {
        return reportDAO.getBrandValuationStats();
    }

    public List<Map<String, Object>> getTopMovingProducts() throws SQLException {
        return reportDAO.getTopMovingProducts();
    }

    public List<Map<String, Object>> getDetailedInboundReport(String startDate, String endDate) throws SQLException {
        return reportDAO.getDetailedInboundReport(startDate, endDate);
    }

    public List<Map<String, Object>> getDetailedInboundReport(String startDate, String endDate, int page, int limit) throws SQLException {
        return reportDAO.getDetailedInboundReport(startDate, endDate, page, limit);
    }

    public List<Map<String, Object>> getDetailedOutboundReport(String startDate, String endDate) throws SQLException {
        return reportDAO.getDetailedOutboundReport(startDate, endDate);
    }

    public List<Map<String, Object>> getDetailedOutboundReport(String startDate, String endDate, int page, int limit) throws SQLException {
        return reportDAO.getDetailedOutboundReport(startDate, endDate, page, limit);
    }

    public List<Map<String, Object>> getDetailedInventoryReport() throws SQLException {
        return reportDAO.getDetailedInventoryReport();
    }

    public List<Map<String, Object>> getDetailedInventoryReport(int page, int limit) throws SQLException {
        return reportDAO.getDetailedInventoryReport(page, limit);
    }

    public List<Map<String, Object>> getNXTReport(String startDate, String endDate, String sku, Long brandId, Long productLineId) throws SQLException {
        return reportDAO.getNXTReport(startDate, endDate, sku, brandId, productLineId);
    }

    public List<Map<String, Object>> getNXTReport(String startDate, String endDate, String sku, Long brandId, Long productLineId, int page, int limit) throws SQLException {
        return reportDAO.getNXTReport(startDate, endDate, sku, brandId, productLineId, page, limit);
    }

    public List<Brand> getAllBrands() throws SQLException {
        return brandDAO.getAll();
    }

    public List<ProductLine> getAllProductLines() throws SQLException {
        return productLineDAO.getAll();
    }
}
