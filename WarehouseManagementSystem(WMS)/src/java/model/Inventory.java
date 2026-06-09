package model;

import java.sql.Timestamp;

public class Inventory {
    private Long productId;
    private Integer quantityInStock;
    private Integer minStockLevel;
    private Timestamp lastUpdated;

    // Extended property
    private Product product;

    public Inventory() {}

    public Inventory(Long productId, Integer quantityInStock, Integer minStockLevel, Timestamp lastUpdated) {
        this.productId = productId;
        this.quantityInStock = quantityInStock;
        this.minStockLevel = minStockLevel;
        this.lastUpdated = lastUpdated;
    }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public Integer getQuantityInStock() { return quantityInStock; }
    public void setQuantityInStock(Integer quantityInStock) { this.quantityInStock = quantityInStock; }

    public Integer getMinStockLevel() { return minStockLevel; }
    public void setMinStockLevel(Integer minStockLevel) { this.minStockLevel = minStockLevel; }

    public Timestamp getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(Timestamp lastUpdated) { this.lastUpdated = lastUpdated; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
}
