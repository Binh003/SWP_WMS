package model;

import java.sql.Timestamp;

public class ProductLine {
    private Long id;
    private Long brandId;
    private String code;
    private String name;
    private String description;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Thuộc tính mở rộng để tiện lợi hiển thị tên Hãng ngoài giao diện
    private Brand brand;

    public ProductLine() {
    }

    public ProductLine(Long id, Long brandId, String code, String name, String description, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.brandId = brandId;
        this.code = code;
        this.name = name;
        this.description = description;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getBrandId() { return brandId; }
    public void setBrandId(Long brandId) { this.brandId = brandId; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public Brand getBrand() { return brand; }
    public void setBrand(Brand brand) { this.brand = brand; }
}
