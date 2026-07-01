package model;

import java.sql.Timestamp;

public class Inventory {
    private Long id;
    private Long productId;
    private String batchCode;
    private String barcode;
    private Integer quantityInStock;
    private Integer minStockLevel;
    private Timestamp lastUpdated;

    // Extended property
    private Product product;

    public Inventory() {}

    public Inventory(Long id, Long productId, String batchCode, String barcode, Integer quantityInStock, Integer minStockLevel, Timestamp lastUpdated) {
        this.id = id;
        this.productId = productId;
        this.batchCode = batchCode;
        this.barcode = barcode;
        this.quantityInStock = quantityInStock;
        this.minStockLevel = minStockLevel;
        this.lastUpdated = lastUpdated;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public String getBatchCode() { return batchCode; }
    public void setBatchCode(String batchCode) { this.batchCode = batchCode; }

    public String getBarcode() { return barcode; }
    public void setBarcode(String barcode) { this.barcode = barcode; }

    public Integer getQuantityInStock() { return quantityInStock; }
    public void setQuantityInStock(Integer quantityInStock) { this.quantityInStock = quantityInStock; }

    public Integer getMinStockLevel() { return minStockLevel; }
    public void setMinStockLevel(Integer minStockLevel) { this.minStockLevel = minStockLevel; }

    public Timestamp getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(Timestamp lastUpdated) { this.lastUpdated = lastUpdated; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
}
