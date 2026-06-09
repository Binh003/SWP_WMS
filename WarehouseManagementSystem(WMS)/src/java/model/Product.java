package model;

import java.sql.Timestamp;

public class Product {
    private Long id;
    private Long productLineId;
    private String sku;
    private String name;
    private String unit;
    private Double price;
    private String description;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    private String imageUrl;

    // Extended property to hold the related ProductLine
    private ProductLine productLine;

    public Product() {}

    public Product(Long id, Long productLineId, String sku, String name, String unit, Double price, String description, String imageUrl, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.productLineId = productLineId;
        this.sku = sku;
        this.name = name;
        this.unit = unit;
        this.price = price;
        this.description = description;
        this.imageUrl = imageUrl;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getProductLineId() { return productLineId; }
    public void setProductLineId(Long productLineId) { this.productLineId = productLineId; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }

    public Double getPrice() { return price; }
    public void setPrice(Double price) { this.price = price; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public ProductLine getProductLine() { return productLine; }
    public void setProductLine(ProductLine productLine) { this.productLine = productLine; }
}
