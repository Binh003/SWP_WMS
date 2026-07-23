package dao;

import config.DBConfig;
import model.*;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ShipmentDAO {

    public List<Shipment> getAll() throws SQLException {
        List<Shipment> list = new ArrayList<>();
        String sql = "SELECT s.*, u.full_name as creator_name " +
                     "FROM shipments s " +
                     "INNER JOIN users u ON s.created_by = u.id " +
                     "ORDER BY s.created_at DESC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Shipment s = new Shipment();
                s.setId(rs.getLong("id"));
                s.setShipmentCode(rs.getString("shipment_code"));
                s.setDestination(rs.getString("destination"));
                s.setCreatedBy(rs.getLong("created_by"));
                s.setStatus(rs.getString("status"));
                s.setNotes(rs.getString("notes"));
                s.setDeliveryNoteImage(rs.getString("delivery_note_image"));
                s.setShippingImages(rs.getString("shipping_images"));
                s.setCreatedAt(rs.getTimestamp("created_at"));
                
                User u = new User();
                u.setId(rs.getLong("created_by"));
                u.setFullName(rs.getString("creator_name"));
                s.setCreator(u);
                
                list.add(s);
            }
        }
        return list;
    }

    public Shipment getById(long id) throws SQLException {
        Shipment s = null;
        String sql = "SELECT s.*, u.full_name as creator_name " +
                     "FROM shipments s " +
                     "INNER JOIN users u ON s.created_by = u.id " +
                     "WHERE s.id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    s = new Shipment();
                    s.setId(rs.getLong("id"));
                    s.setShipmentCode(rs.getString("shipment_code"));
                    s.setDestination(rs.getString("destination"));
                    s.setCreatedBy(rs.getLong("created_by"));
                    s.setStatus(rs.getString("status"));
                    s.setNotes(rs.getString("notes"));
                    s.setDeliveryNoteImage(rs.getString("delivery_note_image"));
                    s.setShippingImages(rs.getString("shipping_images"));
                    s.setCreatedAt(rs.getTimestamp("created_at"));
                    
                    User u = new User();
                    u.setId(rs.getLong("created_by"));
                    u.setFullName(rs.getString("creator_name"));
                    s.setCreator(u);
                }
            }
        }
        
        if (s != null) {
            s.setDetails(getDetailsByShipmentId(s.getId()));
            s.setHistory(getHistoryByShipmentId(s.getId()));
        }
        
        return s;
    }

    private List<ShipmentDetail> getDetailsByShipmentId(long shipmentId) throws SQLException {
        List<ShipmentDetail> details = new ArrayList<>();
        String sql = "SELECT sd.*, p.sku, p.name as product_name, p.unit " +
                     "FROM shipment_details sd " +
                     "INNER JOIN products p ON sd.product_id = p.id " +
                     "WHERE sd.shipment_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ShipmentDetail sd = new ShipmentDetail();
                    sd.setId(rs.getLong("id"));
                    sd.setShipmentId(rs.getLong("shipment_id"));
                    sd.setProductId(rs.getLong("product_id"));
                    sd.setQuantity(rs.getInt("quantity"));
                    
                    try { sd.setBatchCode(rs.getString("batch_code")); } catch (SQLException ignored) {}
                    try { sd.setBarcode(rs.getString("barcode")); } catch (SQLException ignored) {}
                    
                    Product p = new Product();
                    p.setId(rs.getLong("product_id"));
                    p.setSku(rs.getString("sku"));
                    p.setName(rs.getString("product_name"));
                    p.setUnit(rs.getString("unit"));
                    sd.setProduct(p);

                    // Fallback FIFO allocation for this specific detail quantity if not stored yet
                    if ((sd.getBatchCode() == null || sd.getBatchCode().trim().isEmpty()) ||
                        (sd.getBarcode() == null || sd.getBarcode().trim().isEmpty())) {
                        allocateFifoBatchesAndBarcodes(conn, sd.getProductId(), sd.getQuantity(), sd);
                    }
                    
                    details.add(sd);
                }
            }
        }
        return details;
    }

    private void allocateFifoBatchesAndBarcodes(Connection conn, long productId, int quantity, ShipmentDetail sd) {
        if (sd == null || quantity <= 0) return;
        List<String> batches = new ArrayList<>();
        List<String> barcodes = new ArrayList<>();
        int needed = quantity;
        
        String fifoSql = "SELECT batch_code, barcode, quantity_in_stock FROM inventories WHERE product_id = ? AND quantity_in_stock > 0 ORDER BY last_updated ASC, id ASC";
        try (PreparedStatement psFifo = conn.prepareStatement(fifoSql)) {
            psFifo.setLong(1, productId);
            try (ResultSet rsFifo = psFifo.executeQuery()) {
                while (rsFifo.next() && needed > 0) {
                    String bCode = rsFifo.getString("batch_code");
                    String bCodeTrim = (bCode != null) ? bCode.trim() : "";
                    String bBc = rsFifo.getString("barcode");
                    String bBcTrim = (bBc != null) ? bBc.trim() : "";
                    int stock = rsFifo.getInt("quantity_in_stock");
                    
                    int take = Math.min(needed, stock);
                    needed -= take;
                    
                    if (!bCodeTrim.isEmpty() && !batches.contains(bCodeTrim)) {
                        batches.add(bCodeTrim);
                    }
                    if (!bBcTrim.isEmpty() && !barcodes.contains(bBcTrim)) {
                        barcodes.add(bBcTrim);
                    }
                }
            }
        } catch (SQLException ignored) {}
        
        if ((sd.getBatchCode() == null || sd.getBatchCode().trim().isEmpty()) && !batches.isEmpty()) {
            sd.setBatchCode(String.join(", ", batches));
        }
        if ((sd.getBarcode() == null || sd.getBarcode().trim().isEmpty()) && !barcodes.isEmpty()) {
            sd.setBarcode(String.join(", ", barcodes));
        }
    }

    private List<ShipmentHistory> getHistoryByShipmentId(long shipmentId) throws SQLException {
        List<ShipmentHistory> history = new ArrayList<>();
        String sql = "SELECT sh.*, u.full_name as updater_name, u.username as updater_username " +
                     "FROM shipment_history sh " +
                     "INNER JOIN users u ON sh.changed_by = u.id " +
                     "WHERE sh.shipment_id = ? " +
                     "ORDER BY sh.changed_at ASC";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, shipmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ShipmentHistory sh = new ShipmentHistory();
                    sh.setId(rs.getLong("id"));
                    sh.setShipmentId(rs.getLong("shipment_id"));
                    sh.setFromStatus(rs.getString("from_status"));
                    sh.setToStatus(rs.getString("to_status"));
                    sh.setChangedBy(rs.getLong("changed_by"));
                    sh.setChangedAt(rs.getTimestamp("changed_at"));
                    sh.setNotes(rs.getString("notes"));
                    
                    User u = new User();
                    u.setId(rs.getLong("changed_by"));
                    u.setFullName(rs.getString("updater_name"));
                    u.setUsername(rs.getString("updater_username"));
                    sh.setUpdater(u);
                    
                    history.add(sh);
                }
            }
        }
        return history;
    }

    public void insertWithDetails(Shipment shipment) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConfig.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Insert Shipment
            String sqlShipment = "INSERT INTO shipments (shipment_code, destination, created_by, status, notes, delivery_note_image, shipping_images) VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlShipment, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, shipment.getShipmentCode());
                ps.setString(2, shipment.getDestination());
                ps.setLong(3, shipment.getCreatedBy());
                ps.setString(4, shipment.getStatus() == null ? "PENDING" : shipment.getStatus());
                ps.setString(5, shipment.getNotes());
                ps.setString(6, shipment.getDeliveryNoteImage());
                ps.setString(7, shipment.getShippingImages());
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        shipment.setId(rs.getLong(1));
                    } else {
                        throw new SQLException("Creating shipment failed, no ID obtained.");
                    }
                }
            }

            // 1b. Insert initial history entry
            String sqlInsertHistory = "INSERT INTO shipment_history (shipment_id, from_status, to_status, changed_by, notes) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlInsertHistory)) {
                ps.setLong(1, shipment.getId());
                ps.setNull(2, java.sql.Types.VARCHAR);
                ps.setString(3, shipment.getStatus() == null ? "PENDING" : shipment.getStatus());
                ps.setLong(4, shipment.getCreatedBy());
                ps.setString(5, "Tạo mới phiếu xuất kho");
                ps.executeUpdate();
            }

            // 2. Insert Shipment Details and update Inventory if status is COMPLETED
            String sqlDetail = "INSERT INTO shipment_details (shipment_id, product_id, quantity, batch_code, barcode) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail, Statement.RETURN_GENERATED_KEYS)) {
                for (ShipmentDetail detail : shipment.getDetails()) {
                    allocateFifoBatchesAndBarcodes(conn, detail.getProductId(), detail.getQuantity(), detail);
                    
                    psDetail.setLong(1, shipment.getId());
                    psDetail.setLong(2, detail.getProductId());
                    psDetail.setInt(3, detail.getQuantity());
                    psDetail.setString(4, detail.getBatchCode() == null ? "" : detail.getBatchCode());
                    psDetail.setString(5, detail.getBarcode() == null ? "" : detail.getBarcode());
                    psDetail.executeUpdate();

                    try (ResultSet rsDetailKey = psDetail.getGeneratedKeys()) {
                        if (rsDetailKey.next()) {
                            detail.setId(rsDetailKey.getLong(1));
                        }
                    }
                    
                    if ("COMPLETED".equals(shipment.getStatus())) {
                        deductInventory(conn, detail.getProductId(), detail.getQuantity(), detail.getId());
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

    public void updateStatus(long id, String newStatus, long userId) throws SQLException {
        updateStatus(id, newStatus, null, null, userId);
    }

    public void updateStatus(long id, String newStatus, String deliveryNoteImage, String shippingImages, long userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConfig.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Get current status
            String currentStatus = null;
            String sqlSelect = "SELECT status FROM shipments WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        currentStatus = rs.getString("status");
                    }
                }
            }
            
            if (currentStatus == null) {
                throw new SQLException("Shipment not found with id: " + id);
            }
            
            if (currentStatus.equals(newStatus) && deliveryNoteImage == null && shippingImages == null) {
                conn.commit();
                return; // No change
            }
            
            // 2. Update status and images if provided
            StringBuilder sqlUpdate = new StringBuilder("UPDATE shipments SET status = ?");
            List<Object> updateParams = new ArrayList<>();
            updateParams.add(newStatus);
            
            if (deliveryNoteImage != null) {
                sqlUpdate.append(", delivery_note_image = ?");
                updateParams.add(deliveryNoteImage);
            }
            if (shippingImages != null) {
                sqlUpdate.append(", shipping_images = ?");
                updateParams.add(shippingImages);
            }
            sqlUpdate.append(" WHERE id = ?");
            updateParams.add(id);
            
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate.toString())) {
                for (int i = 0; i < updateParams.size(); i++) {
                    ps.setObject(i + 1, updateParams.get(i));
                }
                ps.executeUpdate();
            }

            // 2b. Insert history
            String sqlInsertHistory = "INSERT INTO shipment_history (shipment_id, from_status, to_status, changed_by, notes) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlInsertHistory)) {
                ps.setLong(1, id);
                ps.setString(2, currentStatus);
                ps.setString(3, newStatus);
                ps.setLong(4, userId);
                
                String note = "Cập nhật trạng thái từ " + currentStatus + " sang " + newStatus;
                ps.setString(5, note);
                ps.executeUpdate();
            }
            
            // 3. Handle inventory updates based on state transition
            // Transitioning to COMPLETED: Subtract inventory
            if ("COMPLETED".equals(newStatus) && !"COMPLETED".equals(currentStatus)) {
                List<ShipmentDetail> details = getDetailsByShipmentId(id);
                for (ShipmentDetail d : details) {
                    deductInventory(conn, d.getProductId(), d.getQuantity());
                }
            }
            // Transitioning from COMPLETED to CANCELLED: Revert inventory (add back)
            else if ("CANCELLED".equals(newStatus) && "COMPLETED".equals(currentStatus)) {
                List<ShipmentDetail> details = getDetailsByShipmentId(id);
                for (ShipmentDetail d : details) {
                    revertInventory(conn, d.getProductId(), d.getQuantity());
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

    public List<Shipment> findPaginated(int page, int limit, String search, String statusVal, Long creatorId, String startDate, String endDate) throws SQLException {
        List<Shipment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT s.*, u.full_name as creator_name " +
            "FROM shipments s " +
            "INNER JOIN users u ON s.created_by = u.id WHERE 1=1 "
        );
        
        List<Object> params = new ArrayList<>();
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (s.shipment_code LIKE ? OR s.destination LIKE ? OR u.full_name LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (statusVal != null && !statusVal.trim().isEmpty() && !"ALL".equals(statusVal)) {
            sql.append("AND s.status = ? ");
            params.add(statusVal);
        }

        if (creatorId != null) {
            sql.append("AND s.created_by = ? ");
            params.add(creatorId);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append("AND s.created_at >= ? ");
            params.add(startDate.trim() + " 00:00:00");
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append("AND s.created_at <= ? ");
            params.add(endDate.trim() + " 23:59:59");
        }
        
        sql.append("ORDER BY s.created_at DESC LIMIT ? OFFSET ?");
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
                    Shipment s = new Shipment();
                    s.setId(rs.getLong("id"));
                    s.setShipmentCode(rs.getString("shipment_code"));
                    s.setDestination(rs.getString("destination"));
                    s.setCreatedBy(rs.getLong("created_by"));
                    s.setStatus(rs.getString("status"));
                    s.setNotes(rs.getString("notes"));
                    s.setDeliveryNoteImage(rs.getString("delivery_note_image"));
                    s.setShippingImages(rs.getString("shipping_images"));
                    s.setCreatedAt(rs.getTimestamp("created_at"));
                    
                    User u = new User();
                    u.setId(rs.getLong("created_by"));
                    u.setFullName(rs.getString("creator_name"));
                    s.setCreator(u);
                    
                    list.add(s);
                }
            }
        }
        return list;
    }

    public int count(String search, String statusVal, Long creatorId, String startDate, String endDate) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) " +
            "FROM shipments s " +
            "INNER JOIN users u ON s.created_by = u.id WHERE 1=1 "
        );
        
        List<Object> params = new ArrayList<>();
        
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (s.shipment_code LIKE ? OR s.destination LIKE ? OR u.full_name LIKE ?) ");
            String searchPattern = "%" + search.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }
        
        if (statusVal != null && !statusVal.trim().isEmpty() && !"ALL".equals(statusVal)) {
            sql.append("AND s.status = ? ");
            params.add(statusVal);
        }

        if (creatorId != null) {
            sql.append("AND s.created_by = ? ");
            params.add(creatorId);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append("AND s.created_at >= ? ");
            params.add(startDate.trim() + " 00:00:00");
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append("AND s.created_at <= ? ");
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
        String sql = "SELECT DISTINCT u.id, u.full_name FROM shipments s INNER JOIN users u ON s.created_by = u.id ORDER BY u.full_name";
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

    public void deleteDraft(long id) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConfig.getConnection();
            conn.setAutoCommit(false);

            // Verify status is DRAFT first to be safe
            String status = null;
            String sqlCheck = "SELECT status FROM shipments WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        status = rs.getString("status");
                    }
                }
            }

            if (!"DRAFT".equals(status) && !"PENDING".equals(status) && !"APPROVED".equals(status)) {
                throw new SQLException("Chỉ có thể xóa phiếu ở trạng thái Nháp (DRAFT), Chờ duyệt (PENDING) hoặc Chờ lấy hàng (APPROVED).");
            }

            // 1. Delete details
            String sqlDeleteDetails = "DELETE FROM shipment_details WHERE shipment_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDeleteDetails)) {
                ps.setLong(1, id);
                ps.executeUpdate();
            }

            // 2. Delete history
            String sqlDeleteHistory = "DELETE FROM shipment_history WHERE shipment_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDeleteHistory)) {
                ps.setLong(1, id);
                ps.executeUpdate();
            }

            // 3. Delete shipment
            String sqlDeleteShipment = "DELETE FROM shipments WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDeleteShipment)) {
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

    private void deductInventory(Connection conn, long productId, int quantity) throws SQLException {
        deductInventory(conn, productId, quantity, 0L);
    }

    private void deductInventory(Connection conn, long productId, int quantity, long shipmentDetailId) throws SQLException {
        // 1. Check total inventory sum
        String sqlSum = "SELECT SUM(quantity_in_stock) FROM inventories WHERE product_id = ?";
        try (PreparedStatement psSum = conn.prepareStatement(sqlSum)) {
            psSum.setLong(1, productId);
            try (ResultSet rs = psSum.executeQuery()) {
                if (rs.next()) {
                    int totalStock = rs.getInt(1);
                    if (totalStock < quantity) {
                        throw new SQLException("Tồn kho không đủ cho sản phẩm ID " + productId + " (Tồn: " + totalStock + ", Yêu cầu: " + quantity + ")");
                    }
                } else {
                    throw new SQLException("Không tìm thấy thông tin tồn kho cho sản phẩm ID " + productId);
                }
            }
        }

        // 2. Select rows to deduct (FIFO)
        String sqlSelect = "SELECT id, quantity_in_stock, batch_code, barcode FROM inventories WHERE product_id = ? AND quantity_in_stock > 0 ORDER BY last_updated ASC, id ASC FOR UPDATE";
        String sqlUpdate = "UPDATE inventories SET quantity_in_stock = ? WHERE id = ?";
        
        List<String> deductedBatches = new ArrayList<>();
        List<String> deductedBarcodes = new ArrayList<>();

        int remaining = quantity;
        try (PreparedStatement psSel = conn.prepareStatement(sqlSelect);
             PreparedStatement psUpd = conn.prepareStatement(sqlUpdate)) {
            psSel.setLong(1, productId);
            try (ResultSet rs = psSel.executeQuery()) {
                while (rs.next() && remaining > 0) {
                    long invId = rs.getLong("id");
                    int stock = rs.getInt("quantity_in_stock");
                    String bCode = rs.getString("batch_code");
                    String bBarcode = rs.getString("barcode");
                    
                    int deduct = Math.min(remaining, stock);
                    
                    psUpd.setInt(1, stock - deduct);
                    psUpd.setLong(2, invId);
                    psUpd.executeUpdate();
                    
                    if (bCode != null && !bCode.trim().isEmpty() && !deductedBatches.contains(bCode.trim())) {
                        deductedBatches.add(bCode.trim());
                    }
                    if (bBarcode != null && !bBarcode.trim().isEmpty() && !deductedBarcodes.contains(bBarcode.trim())) {
                        deductedBarcodes.add(bBarcode.trim());
                    }
                    
                    remaining -= deduct;
                }
            }
        }
        
        if (remaining > 0) {
            throw new SQLException("Lỗi trừ tồn kho cho sản phẩm ID " + productId + ": không đủ dòng tồn kho hoạt động.");
        }

        if (shipmentDetailId > 0 && (!deductedBatches.isEmpty() || !deductedBarcodes.isEmpty())) {
            String sqlUpdateDetail = "UPDATE shipment_details SET batch_code = ?, barcode = ? WHERE id = ?";
            try (PreparedStatement psUpdDetail = conn.prepareStatement(sqlUpdateDetail)) {
                psUpdDetail.setString(1, String.join(", ", deductedBatches));
                psUpdDetail.setString(2, String.join(", ", deductedBarcodes));
                psUpdDetail.setLong(3, shipmentDetailId);
                psUpdDetail.executeUpdate();
            }
        }
    }

    private void revertInventory(Connection conn, long productId, int quantity) throws SQLException {
        // 1. Find rows with quantity_in_stock = 0 or less than capacity (itemized rows usually have max capacity 1)
        // We will try to add back to itemized rows that have quantity_in_stock = 0 first.
        String sqlSelect = "SELECT id, quantity_in_stock, barcode FROM inventories WHERE product_id = ? AND quantity_in_stock = 0 AND barcode <> '' ORDER BY last_updated DESC, id DESC FOR UPDATE";
        String sqlUpdate = "UPDATE inventories SET quantity_in_stock = 1 WHERE id = ?";
        
        int remaining = quantity;
        try (PreparedStatement psSel = conn.prepareStatement(sqlSelect);
             PreparedStatement psUpd = conn.prepareStatement(sqlUpdate)) {
            psSel.setLong(1, productId);
            try (ResultSet rs = psSel.executeQuery()) {
                while (rs.next() && remaining > 0) {
                    long invId = rs.getLong("id");
                    psUpd.setLong(1, invId);
                    psUpd.executeUpdate();
                    remaining--;
                }
            }
        }
        
        // 2. If there is still remaining to add back, add it to the first/oldest row of that product (usually the seed row with barcode = '')
        if (remaining > 0) {
            String sqlSelectSeed = "SELECT id, quantity_in_stock FROM inventories WHERE product_id = ? ORDER BY id ASC LIMIT 1 FOR UPDATE";
            String sqlUpdateSeed = "UPDATE inventories SET quantity_in_stock = quantity_in_stock + ? WHERE id = ?";
            try (PreparedStatement psSelSeed = conn.prepareStatement(sqlSelectSeed);
                 PreparedStatement psUpdSeed = conn.prepareStatement(sqlUpdateSeed)) {
                psSelSeed.setLong(1, productId);
                try (ResultSet rs = psSelSeed.executeQuery()) {
                    if (rs.next()) {
                        long seedId = rs.getLong("id");
                        psUpdSeed.setInt(1, remaining);
                        psUpdSeed.setLong(2, seedId);
                        psUpdSeed.executeUpdate();
                    } else {
                        // If no inventory row at all, create a new one
                        String sqlInsert = "INSERT INTO inventories (product_id, quantity_in_stock, min_stock_level) VALUES (?, ?, 10)";
                        try (PreparedStatement psIns = conn.prepareStatement(sqlInsert)) {
                            psIns.setLong(1, productId);
                            psIns.setInt(2, remaining);
                            psIns.executeUpdate();
                        }
                    }
                }
            }
        }
    }

    public void updateShippingImages(long id, String shippingImages) throws SQLException {
        String sql = "UPDATE shipments SET shipping_images = ? WHERE id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shippingImages);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }
}
