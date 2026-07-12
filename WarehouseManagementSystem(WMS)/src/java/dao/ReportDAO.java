package dao;

import config.DBConfig;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportDAO {

    public Map<String, Object> getOverviewStats() throws SQLException {
        Map<String, Object> stats = new HashMap<>();
        
        // 1. Total products
        String sqlProducts = "SELECT COUNT(*) FROM products";
        // 2. Total items in stock & total valuation
        String sqlStock = "SELECT SUM(i.quantity_in_stock) AS total_items, "
                        + "SUM(i.quantity_in_stock * p.price) AS total_value "
                        + "FROM inventories i "
                        + "JOIN products p ON i.product_id = p.id";
        // 3. Low stock count
        String sqlLowStock = "SELECT COUNT(DISTINCT i.product_id) "
                           + "FROM inventories i "
                           + "GROUP BY i.product_id "
                           + "HAVING SUM(i.quantity_in_stock) <= MIN(i.min_stock_level)";

        try (Connection conn = DBConfig.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlProducts);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalProducts", rs.getInt(1));
                } else {
                    stats.put("totalProducts", 0);
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlStock);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalInventoryItems", rs.getInt("total_items"));
                    stats.put("totalInventoryValue", rs.getDouble("total_value"));
                } else {
                    stats.put("totalInventoryItems", 0);
                    stats.put("totalInventoryValue", 0.0);
                }
            }

            int lowStockCount = 0;
            try (PreparedStatement ps = conn.prepareStatement(sqlLowStock);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lowStockCount++;
                }
            }
            stats.put("lowStockCount", lowStockCount);
        }
        
        return stats;
    }

    public List<Map<String, Object>> getMonthlyInboundOutboundStats() throws SQLException {
        List<Map<String, Object>> result = new ArrayList<>();
        
        // Initialize monthly structures for the current year
        Map<Integer, Double> inboundMap = new HashMap<>();
        Map<Integer, Double> outboundMap = new HashMap<>();
        for (int i = 1; i <= 12; i++) {
            inboundMap.put(i, 0.0);
            outboundMap.put(i, 0.0);
        }

        String sqlInbound = "SELECT MONTH(r.created_at) AS month, "
                          + "SUM(rd.quantity * p.price) AS total_val "
                          + "FROM receipts r "
                          + "JOIN receipt_details rd ON r.id = rd.receipt_id "
                          + "JOIN products p ON rd.product_id = p.id "
                          + "WHERE r.status = 'COMPLETED' AND YEAR(r.created_at) = YEAR(CURDATE()) "
                          + "GROUP BY MONTH(r.created_at)";

        String sqlOutbound = "SELECT MONTH(s.created_at) AS month, "
                           + "SUM(sd.quantity * p.price) AS total_val "
                           + "FROM shipments s "
                           + "JOIN shipment_details sd ON s.id = sd.shipment_id "
                           + "JOIN products p ON sd.product_id = p.id "
                           + "WHERE s.status = 'COMPLETED' AND YEAR(s.created_at) = YEAR(CURDATE()) "
                           + "GROUP BY MONTH(s.created_at)";

        try (Connection conn = DBConfig.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlInbound);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    inboundMap.put(rs.getInt("month"), rs.getDouble("total_val"));
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(sqlOutbound);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    outboundMap.put(rs.getInt("month"), rs.getDouble("total_val"));
                }
            }
        }

        for (int i = 1; i <= 12; i++) {
            Map<String, Object> row = new HashMap<>();
            row.put("month", i);
            row.put("inboundValue", inboundMap.get(i));
            row.put("outboundValue", outboundMap.get(i));
            result.add(row);
        }

        return result;
    }

    public List<Map<String, Object>> getBrandValuationStats() throws SQLException {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT b.name AS brand_name, "
                   + "SUM(i.quantity_in_stock * p.price) AS valuation "
                   + "FROM inventories i "
                   + "JOIN products p ON i.product_id = p.id "
                   + "JOIN product_lines pl ON p.product_line_id = pl.id "
                   + "JOIN brands b ON pl.brand_id = b.id "
                   + "GROUP BY b.id, b.name "
                   + "ORDER BY valuation DESC";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("brandName", rs.getString("brand_name"));
                row.put("valuation", rs.getDouble("valuation"));
                result.add(row);
            }
        }
        return result;
    }

    public List<Map<String, Object>> getTopMovingProducts() throws SQLException {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT p.sku, p.name AS product_name, "
                   + "SUM(sd.quantity) AS total_qty "
                   + "FROM shipment_details sd "
                   + "JOIN shipments s ON sd.shipment_id = s.id "
                   + "JOIN products p ON sd.product_id = p.id "
                   + "WHERE s.status = 'COMPLETED' "
                   + "GROUP BY p.id, p.sku, p.name "
                   + "ORDER BY total_qty DESC "
                   + "LIMIT 5";

        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("sku", rs.getString("sku"));
                row.put("productName", rs.getString("product_name"));
                row.put("quantity", rs.getInt("total_qty"));
                result.add(row);
            }
        }
        return result;
    }

    public int getTodayTransactionsCount() throws SQLException {
        String sql = "SELECT "
                   + "  (SELECT COUNT(*) FROM receipts WHERE DATE(created_at) = CURDATE()) + "
                   + "  (SELECT COUNT(*) FROM shipments WHERE DATE(created_at) = CURDATE()) AS today_count";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<Map<String, Object>> getRecentTransactions() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT id, code, type, created_at, product_name, quantity FROM ("
                   + "  (SELECT id, receipt_code AS code, 'RECEIPT' AS type, created_at, "
                   + "          COALESCE((SELECT p.name FROM receipt_details rd JOIN products p ON rd.product_id = p.id WHERE rd.receipt_id = r.id LIMIT 1), 'Không rõ') AS product_name, "
                   + "          COALESCE((SELECT SUM(quantity) FROM receipt_details WHERE receipt_id = r.id), 0) AS quantity "
                   + "   FROM receipts r) "
                   + "  UNION ALL "
                   + "  (SELECT id, shipment_code AS code, 'SHIPMENT' AS type, created_at, "
                   + "          COALESCE((SELECT p.name FROM shipment_details sd JOIN products p ON sd.product_id = p.id WHERE sd.shipment_id = s.id LIMIT 1), 'Không rõ') AS product_name, "
                   + "          COALESCE((SELECT SUM(quantity) FROM shipment_details WHERE shipment_id = s.id), 0) AS quantity "
                   + "   FROM shipments s) "
                   + ") AS combined "
                   + "ORDER BY created_at DESC "
                   + "LIMIT 5";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("id", rs.getLong("id"));
                map.put("code", rs.getString("code"));
                map.put("type", rs.getString("type"));
                map.put("createdAt", rs.getTimestamp("created_at"));
                map.put("productName", rs.getString("product_name"));
                map.put("quantity", rs.getInt("quantity"));
                list.add(map);
            }
        }
        return list;
    }

    public List<Map<String, Object>> getLowStockProducts() throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT p.name, "
                   + "       SUM(i.quantity_in_stock) AS qty, "
                   + "       MIN(i.min_stock_level) AS min_qty "
                   + "FROM inventories i "
                   + "JOIN products p ON i.product_id = p.id "
                   + "GROUP BY p.id, p.name "
                   + "HAVING MIN(i.min_stock_level) > 0 AND SUM(i.quantity_in_stock) <= MIN(i.min_stock_level) "
                   + "ORDER BY qty ASC "
                   + "LIMIT 5";
        try (Connection conn = DBConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("name", rs.getString("name"));
                map.put("qty", rs.getInt("qty"));
                map.put("minQty", rs.getInt("min_qty"));
                list.add(map);
            }
        }
        return list;
    }
}
