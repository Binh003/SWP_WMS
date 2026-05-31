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

    public void insertWithDetails(Shipment shipment) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConfig.getConnection();
            conn.setAutoCommit(false);
            
            // 0. Verify Inventory before proceeding
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

            // 1. Insert Shipment
            String sqlShipment = "INSERT INTO shipments (shipment_code, destination, created_by, status, notes) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlShipment, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, shipment.getShipmentCode());
                ps.setString(2, shipment.getDestination());
                ps.setLong(3, shipment.getCreatedBy());
                ps.setString(4, shipment.getStatus() == null ? "COMPLETED" : shipment.getStatus());
                ps.setString(5, shipment.getNotes());
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        shipment.setId(rs.getLong(1));
                    } else {
                        throw new SQLException("Creating shipment failed, no ID obtained.");
                    }
                }
            }

            // 2. Insert Shipment Details and update Inventory
            String sqlDetail = "INSERT INTO shipment_details (shipment_id, product_id, quantity) VALUES (?, ?, ?)";
            String sqlUpdateInv = "UPDATE inventories SET quantity_in_stock = quantity_in_stock - ? WHERE product_id = ?";
            
            try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail);
                 PreparedStatement psInv = conn.prepareStatement(sqlUpdateInv)) {
                 
                for (ShipmentDetail detail : shipment.getDetails()) {
                    psDetail.setLong(1, shipment.getId());
                    psDetail.setLong(2, detail.getProductId());
                    psDetail.setInt(3, detail.getQuantity());
                    psDetail.addBatch();
                    
                    psInv.setInt(1, detail.getQuantity());
                    psInv.setLong(2, detail.getProductId());
                    psInv.addBatch();
                }
                psDetail.executeBatch();
                psInv.executeBatch();
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
