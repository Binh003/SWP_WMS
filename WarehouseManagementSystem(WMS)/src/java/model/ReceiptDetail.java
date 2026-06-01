package model;

public class ReceiptDetail {
    private Long id;
    private Long receiptId;
    private Long productId;
    private Integer quantity;

    // Extended properties
    private Product product;

    public ReceiptDetail() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getReceiptId() { return receiptId; }
    public void setReceiptId(Long receiptId) { this.receiptId = receiptId; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
}