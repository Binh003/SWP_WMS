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
        }
        
        return r;
    }

    private List<ReceiptDetail> getDetailsByReceiptId(long receiptId) throws SQLException {
        List<ReceiptDetail> details = new ArrayList<>();
        String sql = "SELECT rd.*, p.sku, p.name as product_name, p.unit " +
                     "FROM receipt_details rd " +
                     "INNER JOIN products p ON rd.product_id = p.id " +
                     "WHERE rd.receipt_id = ?";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, receiptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ReceiptDetail rd = new ReceiptDetail();
                    rd.setId(rs.getLong("id"));
                    rd.setReceiptId(rs.getLong("receipt_id"));
                    rd.setProductId(rs.getLong("product_id"));
                    rd.setQuantity(rs.getInt("quantity"));
                    
                    Product p = new Product();
                    p.setId(rs.getLong("product_id"));
                    p.setSku(rs.getString("sku"));
                    p.setName(rs.getString("product_name"));
                    p.setUnit(rs.getString("unit"));
                    rd.setProduct(p);
                    
                    details.add(rd);
                }
            }
        }
        return details;
    }

    public void insertWithDetails(Receipt receipt) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConfig.getConnection();
            conn.setAutoCommit(false);

            // 1. Insert Receipt
            String sqlReceipt = "INSERT INTO receipts (receipt_code, supplier_id, created_by, status, notes) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlReceipt, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, receipt.getReceiptCode());
                ps.setLong(2, receipt.getSupplierId());
                ps.setLong(3, receipt.getCreatedBy());
                ps.setString(4, receipt.getStatus() == null ? "COMPLETED" : receipt.getStatus());
                ps.setString(5, receipt.getNotes());
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        receipt.setId(rs.getLong(1));
                    } else {
                        throw new SQLException("Creating receipt failed, no ID obtained.");
                    }
                }
            }

            // 2. Insert Receipt Details and update Inventory
            String sqlDetail = "INSERT INTO receipt_details (receipt_id, product_id, quantity) VALUES (?, ?, ?)";
            String sqlUpdateInv = "UPDATE inventories SET quantity_in_stock = quantity_in_stock + ? WHERE product_id = ?";
            
            try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail);
                 PreparedStatement psInv = conn.prepareStatement(sqlUpdateInv)) {
                 
                for (ReceiptDetail detail : receipt.getDetails()) {
                    psDetail.setLong(1, receipt.getId());
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