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
                    
                    Product p = new Product();
                    p.setId(rs.getLong("product_id"));
                    p.setSku(rs.getString("sku"));
                    p.setName(rs.getString("product_name"));
                    p.setUnit(rs.getString("unit"));
                    sd.setProduct(p);
                    
                    details.add(sd);
                }
            }
        }
        return details;
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
            
            // 0. If status is COMPLETED, verify Inventory using FOR UPDATE
            if ("COMPLETED".equals(shipment.getStatus())) {
                String sqlCheckInv = "SELECT quantity_in_stock FROM inventories WHERE product_id = ? FOR UPDATE";
                try (PreparedStatement psCheck = conn.prepareStatement(sqlCheckInv)) {
                    for (ShipmentDetail detail : shipment.getDetails()) {
                        psCheck.setLong(1, detail.getProductId());
                        try (ResultSet rs = psCheck.executeQuery()) {
                            if (rs.next()) {
                                int stock = rs.getInt("quantity_in_stock");
                                if (stock < detail.getQuantity()) {
                                    throw new SQLException("Tồn kho không đủ cho sản phẩm ID " + detail.getProductId() + " (Tồn: " + stock + ", Yêu cầu: " + detail.getQuantity() + ")");
                                }
                            } else {
                                throw new SQLException("Không tìm thấy thông tin tồn kho cho sản phẩm ID " + detail.getProductId());
                            }
                        }
                    }
                }
            }

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
            String sqlDetail = "INSERT INTO shipment_details (shipment_id, product_id, quantity) VALUES (?, ?, ?)";
            String sqlUpdateInv = "UPDATE inventories SET quantity_in_stock = quantity_in_stock - ? WHERE product_id = ?";
            
            try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail);
                 PreparedStatement psInv = conn.prepareStatement(sqlUpdateInv)) {
                 
                for (ShipmentDetail detail : shipment.getDetails()) {
                    psDetail.setLong(1, shipment.getId());
                    psDetail.setLong(2, detail.getProductId());
                    psDetail.setInt(3, detail.getQuantity());
                    psDetail.addBatch();
                    
                    if ("COMPLETED".equals(shipment.getStatus())) {
                        psInv.setInt(1, detail.getQuantity());
                        psInv.setLong(2, detail.getProductId());
                        psInv.addBatch();
                    }
                }
                psDetail.executeBatch();
                if ("COMPLETED".equals(shipment.getStatus())) {
                    psInv.executeBatch();
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
                
                // Perform check first with FOR UPDATE
                String sqlCheckInv = "SELECT quantity_in_stock FROM inventories WHERE product_id = ? FOR UPDATE";
                try (PreparedStatement psCheck = conn.prepareStatement(sqlCheckInv)) {
                    for (ShipmentDetail d : details) {
                        psCheck.setLong(1, d.getProductId());
                        try (ResultSet rs = psCheck.executeQuery()) {
                            if (rs.next()) {
                                int stock = rs.getInt("quantity_in_stock");
                                if (stock < d.getQuantity()) {
                                    throw new SQLException("Tồn kho không đủ cho sản phẩm ID " + d.getProductId() + " (Tồn: " + stock + ", Yêu cầu: " + d.getQuantity() + ")");
                                }
                            } else {
                                throw new SQLException("Không tìm thấy thông tin tồn kho cho sản phẩm ID " + d.getProductId());
                            }
                        }
                    }
                }
                
                // Execute subtraction
                String sqlUpdateInv = "UPDATE inventories SET quantity_in_stock = quantity_in_stock - ? WHERE product_id = ?";
                try (PreparedStatement psInv = conn.prepareStatement(sqlUpdateInv)) {
                    for (ShipmentDetail d : details) {
                        psInv.setInt(1, d.getQuantity());
                        psInv.setLong(2, d.getProductId());
                        psInv.addBatch();
                    }
                    psInv.executeBatch();
                }
            }
            // Transitioning from COMPLETED to CANCELLED: Revert inventory (add back)
            else if ("CANCELLED".equals(newStatus) && "COMPLETED".equals(currentStatus)) {
                List<ShipmentDetail> details = getDetailsByShipmentId(id);
                String sqlUpdateInv = "UPDATE inventories SET quantity_in_stock = quantity_in_stock + ? WHERE product_id = ?";
                try (PreparedStatement psInv = conn.prepareStatement(sqlUpdateInv)) {
                    for (ShipmentDetail d : details) {
                        psInv.setInt(1, d.getQuantity());
                        psInv.setLong(2, d.getProductId());
                        psInv.addBatch();
                    }
                    psInv.executeBatch();
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
            if ("APPROVED".equals(statusVal)) {
                sql.append("AND (s.status = 'APPROVED' OR s.status = 'PENDING') ");
            } else {
                sql.append("AND s.status = ? ");
                params.add(statusVal);
            }
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
            if ("APPROVED".equals(statusVal)) {
                sql.append("AND (s.status = 'APPROVED' OR s.status = 'PENDING') ");
            } else {
                sql.append("AND s.status = ? ");
                params.add(statusVal);
            }
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
}
