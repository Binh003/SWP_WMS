package dao;

import config.DBConfig;
import model.*;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReceiptDAO {

    public List<Receipt> getAll() throws SQLException {
        List<Receipt> list = new ArrayList<>();
        String sql = "SELECT r.*, s.name as supplier_name, u.full_name as creator_name " +
                     "FROM receipts r " +
                     "INNER JOIN suppliers s ON r.supplier_id = s.id " +
                     "INNER JOIN users u ON r.created_by = u.id " +
                     "ORDER BY r.created_at DESC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Receipt r = new Receipt();
                r.setId(rs.getLong("id"));
                r.setReceiptCode(rs.getString("receipt_code"));
                r.setSupplierId(rs.getLong("supplier_id"));
                r.setCreatedBy(rs.getLong("created_by"));
                r.setStatus(rs.getString("status"));
                r.setNotes(rs.getString("notes"));
                r.setInvoiceImage(rs.getString("invoice_image"));
                r.setReceivingImages(rs.getString("receiving_images"));
                r.setCreatedAt(rs.getTimestamp("created_at"));
                
                Supplier s = new Supplier();
                s.setId(rs.getLong("supplier_id"));
                s.setName(rs.getString("supplier_name"));
                r.setSupplier(s);
                
                User u = new User();
                u.setId(rs.getLong("created_by"));
                u.setFullName(rs.getString("creator_name"));
                r.setCreator(u);
                
                list.add(r);
            }
        }
        return list;
    }

    public Receipt getById(long id) throws SQLException {
        Receipt r = null;
        String sql = "SELECT r.*, s.name as supplier_name, u.full_name as creator_name " +
                     "FROM receipts r " +
                     "INNER JOIN suppliers s ON r.supplier_id = s.id " +
                     "INNER JOIN users u ON r.created_by = u.id " +
                     "WHERE r.id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    r = new Receipt();
                    r.setId(rs.getLong("id"));
                    r.setReceiptCode(rs.getString("receipt_code"));
                    r.setSupplierId(rs.getLong("supplier_id"));
                    r.setCreatedBy(rs.getLong("created_by"));
                    r.setStatus(rs.getString("status"));
                    r.setNotes(rs.getString("notes"));
                    r.setInvoiceImage(rs.getString("invoice_image"));
                    r.setReceivingImages(rs.getString("receiving_images"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    
                    Supplier s = new Supplier();
                    s.setId(rs.getLong("supplier_id"));
                    s.setName(rs.getString("supplier_name"));
                    r.setSupplier(s);
                    
                    User u = new User();
                    u.setId(rs.getLong("created_by"));
                    u.setFullName(rs.getString("creator_name"));
                    r.setCreator(u);
                }
            }
        }
        
        if (r != null) {
            r.setDetails(getDetailsByReceiptId(r.getId()));
            r.setHistory(getHistoryByReceiptId(r.getId()));
        }
        
        return r;
    }

    private List<ReceiptDetail> getDetailsByReceiptId(long receiptId) throws SQLException {
        try (Connection conn = DBConfig.getConnection()) {
            return getDetailsByReceiptId(conn, receiptId);
        }
    }

    private List<ReceiptDetail> getDetailsByReceiptId(Connection conn, long receiptId) throws SQLException {
        List<ReceiptDetail> details = new ArrayList<>();
        String sql = "SELECT rd.*, p.sku, p.name as product_name, p.unit, p.price " +
                     "FROM receipt_details rd " +
                     "INNER JOIN products p ON rd.product_id = p.id " +
                     "WHERE rd.receipt_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, receiptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReceiptDetail rd = new ReceiptDetail();
                    rd.setId(rs.getLong("id"));
                    rd.setReceiptId(rs.getLong("receipt_id"));
                    rd.setProductId(rs.getLong("product_id"));
                    rd.setQuantity(rs.getInt("quantity"));
                    rd.setBatchCode(rs.getString("batch_code"));
                    rd.setBarcode(rs.getString("barcode"));
                    
                    Product p = new Product();
                    p.setId(rs.getLong("product_id"));
                    p.setSku(rs.getString("sku"));
                    p.setName(rs.getString("product_name"));
                    p.setUnit(rs.getString("unit"));
                    p.setPrice(rs.getDouble("price"));
                    rd.setProduct(p);
                    
                    details.add(rd);
                }
            }
        }
        return details;
    }

    private List<ReceiptHistory> getHistoryByReceiptId(long receiptId) throws SQLException {
        List<ReceiptHistory> history = new ArrayList<>();
        String sql = "SELECT rh.*, u.full_name as updater_name, u.username as updater_username " +
                     "FROM receipt_history rh " +
                     "INNER JOIN users u ON rh.changed_by = u.id " +
                     "WHERE rh.receipt_id = ? " +
                     "ORDER BY rh.changed_at ASC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, receiptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReceiptHistory rh = new ReceiptHistory();
                    rh.setId(rs.getLong("id"));
                    rh.setReceiptId(rs.getLong("receipt_id"));
                    rh.setFromStatus(rs.getString("from_status"));
                    rh.setToStatus(rs.getString("to_status"));
                    rh.setChangedBy(rs.getLong("changed_by"));
                    rh.setChangedAt(rs.getTimestamp("changed_at"));
                    rh.setNotes(rs.getString("notes"));
                    
                    User u = new User();
                    u.setId(rs.getLong("changed_by"));
                    u.setFullName(rs.getString("updater_name"));
                    u.setUsername(rs.getString("updater_username"));
                    rh.setUpdater(u);
                    
                    history.add(rh);
                }
            }
        }
        return history;
    }

    public void insertWithDetails(Receipt receipt) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConfig.getConnection();
            conn.setAutoCommit(false);

            // 1. Insert Receipt
            String sqlReceipt = "INSERT INTO receipts (receipt_code, supplier_id, created_by, status, notes, invoice_image, receiving_images) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlReceipt, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, receipt.getReceiptCode());
                ps.setLong(2, receipt.getSupplierId());
                ps.setLong(3, receipt.getCreatedBy());
                ps.setString(4, receipt.getStatus() == null ? "PENDING_APPROVAL" : receipt.getStatus());
                ps.setString(5, receipt.getNotes());
                ps.setString(6, receipt.getInvoiceImage());
                ps.setString(7, receipt.getReceivingImages());
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        receipt.setId(rs.getLong(1));
                    } else {
                        throw new SQLException("Creating receipt failed, no ID obtained.");
                    }
                }
            }

            // Generate batch code and barcode for details
            for (ReceiptDetail detail : receipt.getDetails()) {
                if (detail.getBatchCode() == null || detail.getBatchCode().trim().isEmpty()) {
                    detail.setBatchCode("BAT-" + receipt.getReceiptCode());
                } else {
                    detail.setBatchCode(detail.getBatchCode().trim());
                }
                
                String barcode = "BC-" + receipt.getId() + "-" + detail.getProductId();
                detail.setBarcode(barcode);
            }

            // 1b. Insert initial history entry
            String sqlInsertHistory = "INSERT INTO receipt_history (receipt_id, from_status, to_status, changed_by, notes) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlInsertHistory)) {
                ps.setLong(1, receipt.getId());
                ps.setNull(2, java.sql.Types.VARCHAR);
                ps.setString(3, receipt.getStatus() == null ? "PENDING_APPROVAL" : receipt.getStatus());
                ps.setLong(4, receipt.getCreatedBy());
                ps.setString(5, "Tạo mới phiếu nhập kho");
                ps.executeUpdate();
            }

            // 2. Insert Receipt Details and update Inventory if status is COMPLETED
            String sqlDetail = "INSERT INTO receipt_details (receipt_id, product_id, quantity, batch_code, barcode) VALUES (?, ?, ?, ?, ?)";
            String sqlCheckInv = "SELECT id, quantity_in_stock FROM inventories WHERE product_id = ? AND batch_code = ? AND barcode = ?";
            String sqlInsertInv = "INSERT INTO inventories (product_id, batch_code, barcode, quantity_in_stock, min_stock_level, last_updated) VALUES (?, ?, ?, ?, 10, CURRENT_TIMESTAMP)";
            String sqlUpdateInv = "UPDATE inventories SET quantity_in_stock = quantity_in_stock + ?, last_updated = CURRENT_TIMESTAMP WHERE id = ?";
            
            try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail)) {
                for (ReceiptDetail detail : receipt.getDetails()) {
                    psDetail.setLong(1, receipt.getId());
                    psDetail.setLong(2, detail.getProductId());
                    psDetail.setInt(3, detail.getQuantity());
                    String batchCode = normalizeNullableCode(detail.getBatchCode());
                    String barcode = normalizeNullableCode(detail.getBarcode());

                    if (batchCode == null) psDetail.setNull(4, Types.VARCHAR);
                    else psDetail.setString(4, batchCode);

                    if (barcode == null) psDetail.setNull(5, Types.VARCHAR);
                    else psDetail.setString(5, barcode);

                    psDetail.addBatch();
                }
                psDetail.executeBatch();
                
                if ("COMPLETED".equals(receipt.getStatus())) {
                    for (ReceiptDetail detail : receipt.getDetails()) {
                        List<String> itemBarcodes = parseBarcodes(detail.getBarcode());
                        if (itemBarcodes.size() != detail.getQuantity()) {
                            throw new SQLException("Số Barcode không khớp số lượng của sản phẩm ID " + detail.getProductId());
                        }
                        for (String itemBarcode : itemBarcodes) {
                            long inventoryId = -1;
                            try (PreparedStatement psCheck = conn.prepareStatement(sqlCheckInv)) {
                                psCheck.setLong(1, detail.getProductId());
                                psCheck.setString(2, detail.getBatchCode());
                                psCheck.setString(3, itemBarcode);
                                try (ResultSet rsCheck = psCheck.executeQuery()) {
                                    if (rsCheck.next()) {
                                        inventoryId = rsCheck.getLong("id");
                                    }
                                }
                            }
                            
                            if (inventoryId != -1) {
                                try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateInv)) {
                                    psUpdate.setInt(1, 1);
                                    psUpdate.setLong(2, inventoryId);
                                    psUpdate.executeUpdate();
                                }
                            } else {
                                try (PreparedStatement psInsert = conn.prepareStatement(sqlInsertInv)) {
                                    psInsert.setLong(1, detail.getProductId());
                                    psInsert.setString(2, detail.getBatchCode());
                                    psInsert.setString(3, itemBarcode);
                                    psInsert.setInt(4, 1);
                                    psInsert.executeUpdate();
                                }
                            }
                        }
                    }
                }
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }

    public void updateStatus(long id, String newStatus) throws SQLException {
        updateStatus(id, newStatus, 1L);
    }

    public void updateStatus(long id, String newStatus, long userId) throws SQLException {
        updateStatus(id, newStatus, null, userId);
    }

    public void updateStatus(long id, String newStatus, String receivingImages, long userId) throws SQLException {
        updateStatus(id, newStatus, receivingImages, userId, null);
    }

    public void updateStatus(long id, String newStatus, String receivingImages, long userId, List<ReceiptDetail> updatedDetails) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConfig.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Get current status
            String currentStatus = null;
            String sqlSelect = "SELECT status FROM receipts WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        currentStatus = rs.getString("status");
                    }
                }
            }
            
            if (currentStatus == null) {
                throw new SQLException("Receipt not found with id: " + id);
            }
            
            // 1b. Save actual quantity, Batch Code and Barcode entered at RECEIVING.
            if (updatedDetails != null && !updatedDetails.isEmpty()) {
                String sqlUpdateDetail =
                    "UPDATE receipt_details SET quantity = ?, batch_code = ?, barcode = ? " +
                    "WHERE id = ? AND receipt_id = ?";

                try (PreparedStatement psDetail = conn.prepareStatement(sqlUpdateDetail)) {
                    for (ReceiptDetail d : updatedDetails) {
                        if (d.getQuantity() == null || d.getQuantity() < 0) {
                            throw new SQLException("Số lượng thực nhận không hợp lệ cho chi tiết ID " + d.getId());
                        }

                        String batchCode = normalizeNullableCode(d.getBatchCode());
                        String barcode = normalizeNullableCode(d.getBarcode());

                        if ("RECEIVED".equals(newStatus)) {
                            if (batchCode == null) {
                                throw new SQLException("Batch Code không được để trống cho chi tiết ID " + d.getId());
                            }
                            if (barcode == null) {
                                throw new SQLException("Barcode không được để trống cho chi tiết ID " + d.getId());
                            }
                        }

                        psDetail.setInt(1, d.getQuantity());
                        if (batchCode == null) psDetail.setNull(2, Types.VARCHAR);
                        else psDetail.setString(2, batchCode);

                        if (barcode == null) psDetail.setNull(3, Types.VARCHAR);
                        else psDetail.setString(3, barcode);

                        psDetail.setLong(4, d.getId());
                        psDetail.setLong(5, id);
                        psDetail.addBatch();
                    }
                    psDetail.executeBatch();
                }
            }

            if ("RECEIVED".equals(newStatus)) {
                validateReceivingDetails(conn, id);
            }
            
            // 2. Update status
            String sqlUpdateStatus;
            if (receivingImages != null) {
                sqlUpdateStatus = "UPDATE receipts SET status = ?, receiving_images = ? WHERE id = ?";
            } else {
                sqlUpdateStatus = "UPDATE receipts SET status = ? WHERE id = ?";
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateStatus)) {
                if (receivingImages != null) {
                    ps.setString(1, newStatus);
                    ps.setString(2, receivingImages);
                    ps.setLong(3, id);
                } else {
                    ps.setString(1, newStatus);
                    ps.setLong(2, id);
                }
                ps.executeUpdate();
            }

            // 2b. Insert history
            String sqlInsertHistory = "INSERT INTO receipt_history (receipt_id, from_status, to_status, changed_by, notes) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlInsertHistory)) {
                ps.setLong(1, id);
                ps.setString(2, currentStatus);
                ps.setString(3, newStatus);
                ps.setLong(4, userId);
                
                String note = "Cập nhật trạng thái từ " + currentStatus + " sang " + newStatus;
                ps.setString(5, note);
                ps.executeUpdate();
            }
            
            // 3. Update inventory if transitioning to COMPLETED from another status
            if ("COMPLETED".equals(newStatus) && !"COMPLETED".equals(currentStatus)) {
                validateReceivingDetails(conn, id);
                List<ReceiptDetail> details = getDetailsByReceiptId(conn, id);
                String sqlCheckInv = "SELECT id, quantity_in_stock FROM inventories WHERE product_id = ? AND batch_code = ? AND barcode = ?";
                String sqlInsertInv = "INSERT INTO inventories (product_id, batch_code, barcode, quantity_in_stock, min_stock_level, last_updated) VALUES (?, ?, ?, ?, 10, CURRENT_TIMESTAMP)";
                String sqlUpdateInv = "UPDATE inventories SET quantity_in_stock = quantity_in_stock + ?, last_updated = CURRENT_TIMESTAMP WHERE id = ?";
                
                for (ReceiptDetail d : details) {
                    List<String> itemBarcodes = parseBarcodes(d.getBarcode());
                    if (itemBarcodes.size() != d.getQuantity()) {
                        throw new SQLException("Số Barcode không khớp số lượng của chi tiết ID " + d.getId());
                    }
                    for (String itemBarcode : itemBarcodes) {
                        long inventoryId = -1;
                        try (PreparedStatement psCheck = conn.prepareStatement(sqlCheckInv)) {
                            psCheck.setLong(1, d.getProductId());
                            psCheck.setString(2, d.getBatchCode());
                            psCheck.setString(3, itemBarcode);
                            try (ResultSet rsCheck = psCheck.executeQuery()) {
                                if (rsCheck.next()) {
                                    inventoryId = rsCheck.getLong("id");
                                }
                            }
                        }
                        
                        if (inventoryId != -1) {
                            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdateInv)) {
                                psUpdate.setInt(1, 1);
                                psUpdate.setLong(2, inventoryId);
                                psUpdate.executeUpdate();
                            }
                        } else {
                            try (PreparedStatement psInsert = conn.prepareStatement(sqlInsertInv)) {
                                psInsert.setLong(1, d.getProductId());
                                psInsert.setString(2, d.getBatchCode());
                                psInsert.setString(3, itemBarcode);
                                psInsert.setInt(4, 1);
                                psInsert.executeUpdate();
                            }
                        }
                    }
                }
            }
            
            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }

    public List<Receipt> findPaginated(int page, int limit, String search, String statusVal, Long supplierId, Long creatorId, String startDate, String endDate) throws SQLException {
        List<Receipt> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT r.*, s.name as supplier_name, u.full_name as creator_name " +
            "FROM receipts r " +
            "INNER JOIN suppliers s ON r.supplier_id = s.id " +
            "INNER JOIN users u ON r.created_by = u.id WHERE 1=1 "
        );
        
        List<Object> params = new ArrayList<>();
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (r.receipt_code LIKE ? OR s.name LIKE ? OR u.full_name LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (statusVal != null && !statusVal.trim().isEmpty() && !"ALL".equals(statusVal)) {
            if ("PROCESSING".equals(statusVal)) {
                sql.append("AND (r.status = 'APPROVED' OR r.status = 'RECEIVING' OR r.status = 'RECEIVED') ");
            } else {
                sql.append("AND r.status = ? ");
                params.add(statusVal);
            }
        }

        if (supplierId != null) {
            sql.append("AND r.supplier_id = ? ");
            params.add(supplierId);
        }

        if (creatorId != null) {
            sql.append("AND r.created_by = ? ");
            params.add(creatorId);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append("AND r.created_at >= ? ");
            params.add(startDate.trim() + " 00:00:00");
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append("AND r.created_at <= ? ");
            params.add(endDate.trim() + " 23:59:59");
        }
        
        sql.append("ORDER BY r.created_at DESC LIMIT ? OFFSET ?");
        int offset = (page - 1) * limit;
        params.add(limit);
        params.add(offset);
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Receipt r = new Receipt();
                    r.setId(rs.getLong("id"));
                    r.setReceiptCode(rs.getString("receipt_code"));
                    r.setSupplierId(rs.getLong("supplier_id"));
                    r.setCreatedBy(rs.getLong("created_by"));
                    r.setStatus(rs.getString("status"));
                    r.setNotes(rs.getString("notes"));
                    r.setInvoiceImage(rs.getString("invoice_image"));
                    r.setReceivingImages(rs.getString("receiving_images"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    
                    Supplier s = new Supplier();
                    s.setId(rs.getLong("supplier_id"));
                    s.setName(rs.getString("supplier_name"));
                    r.setSupplier(s);
                    
                    User u = new User();
                    u.setId(rs.getLong("created_by"));
                    u.setFullName(rs.getString("creator_name"));
                    r.setCreator(u);
                    
                    list.add(r);
                }
            }
        }
        return list;
    }

    public int count(String search, String statusVal, Long supplierId, Long creatorId, String startDate, String endDate) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) " +
            "FROM receipts r " +
            "INNER JOIN suppliers s ON r.supplier_id = s.id " +
            "INNER JOIN users u ON r.created_by = u.id WHERE 1=1 "
        );
        
        List<Object> params = new ArrayList<>();
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (r.receipt_code LIKE ? OR s.name LIKE ? OR u.full_name LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (statusVal != null && !statusVal.trim().isEmpty() && !"ALL".equals(statusVal)) {
            if ("PROCESSING".equals(statusVal)) {
                sql.append("AND (r.status = 'APPROVED' OR r.status = 'RECEIVING') ");
            } else {
                sql.append("AND r.status = ? ");
                params.add(statusVal);
            }
        }

        if (supplierId != null) {
            sql.append("AND r.supplier_id = ? ");
            params.add(supplierId);
        }

        if (creatorId != null) {
            sql.append("AND r.created_by = ? ");
            params.add(creatorId);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append("AND r.created_at >= ? ");
            params.add(startDate.trim() + " 00:00:00");
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append("AND r.created_at <= ? ");
            params.add(endDate.trim() + " 23:59:59");
        }
        
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<User> getCreators() throws SQLException {
        List<User> list = new ArrayList<>();
        String sql = "SELECT DISTINCT u.id, u.full_name FROM receipts r INNER JOIN users u ON r.created_by = u.id ORDER BY u.full_name";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getLong("id"));
                u.setFullName(rs.getString("full_name"));
                list.add(u);
            }
        }
        return list;
    }

    public void updateInvoiceImage(long id, String invoiceImage) throws SQLException {
        String sql = "UPDATE receipts SET invoice_image = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, invoiceImage);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void updateReceivingImages(long id, String receivingImages) throws SQLException {
        String sql = "UPDATE receipts SET receiving_images = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, receivingImages);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }


    private String normalizeNullableCode(String value) {
        if (value == null) return null;
        String normalized = value.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private void validateReceivingDetails(Connection conn, long receiptId) throws SQLException {
        String sql = "SELECT id, quantity, batch_code, barcode FROM receipt_details WHERE receipt_id = ?";
        boolean hasDetail = false;
        java.util.Set<String> receiptBarcodeSet = new java.util.HashSet<>();

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, receiptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    hasDetail = true;
                    long detailId = rs.getLong("id");
                    int quantity = rs.getInt("quantity");
                    String batchCode = normalizeNullableCode(rs.getString("batch_code"));
                    List<String> barcodes = parseBarcodes(rs.getString("barcode"));

                    if (quantity <= 0) throw new SQLException("Số lượng thực nhận phải lớn hơn 0 cho chi tiết ID " + detailId);
                    if (batchCode == null) throw new SQLException("Batch Code chưa được nhập cho chi tiết ID " + detailId);
                    if (barcodes.size() != quantity) {
                        throw new SQLException("Chi tiết ID " + detailId + " có số lượng " + quantity + " nhưng có " + barcodes.size() + " Barcode.");
                    }

                    java.util.Set<String> detailBarcodeSet = new java.util.HashSet<>();
                    for (String barcode : barcodes) {
                        String normalized = barcode.toUpperCase();
                        if (!detailBarcodeSet.add(normalized)) throw new SQLException("Barcode " + barcode + " bị trùng trong chi tiết ID " + detailId);
                        if (!receiptBarcodeSet.add(normalized)) throw new SQLException("Barcode " + barcode + " bị trùng trong phiếu nhập.");
                    }
                }
            }
        }
        if (!hasDetail) throw new SQLException("Phiếu nhập không có sản phẩm để xác nhận.");
    }

    private List<String> parseBarcodes(String barcodeValue) {
        List<String> barcodes = new ArrayList<>();
        if (barcodeValue == null || barcodeValue.trim().isEmpty()) return barcodes;
        for (String value : barcodeValue.split(",")) {
            String barcode = normalizeNullableCode(value);
            if (barcode != null) barcodes.add(barcode);
        }
        return barcodes;
    }

    public void deleteDraft(long id) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConfig.getConnection();
            conn.setAutoCommit(false);

            // Verify status is DRAFT first to be safe
            String status = null;
            String sqlCheck = "SELECT status FROM receipts WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        status = rs.getString("status");
                    }
                }
            }

            if (!"DRAFT".equals(status)) {
                throw new SQLException("Chỉ có thể xóa phiếu ở trạng thái Nháp (DRAFT).");
            }

            // 1. Delete details
            String sqlDeleteDetails = "DELETE FROM receipt_details WHERE receipt_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDeleteDetails)) {
                ps.setLong(1, id);
                ps.executeUpdate();
            }

            // 2. Delete history
            String sqlDeleteHistory = "DELETE FROM receipt_history WHERE receipt_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDeleteHistory)) {
                ps.setLong(1, id);
                ps.executeUpdate();
            }

            // 3. Delete receipt
            String sqlDeleteReceipt = "DELETE FROM receipts WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDeleteReceipt)) {
                ps.setLong(1, id);
                ps.executeUpdate();
            }

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }
}