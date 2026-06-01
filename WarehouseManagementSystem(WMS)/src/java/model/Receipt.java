package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Receipt {
    private Long id;
    private String receiptCode;
    private Long supplierId;
    private Long createdBy;
    private String status;
    private String notes;
    private Timestamp createdAt;

    // Extended properties
    private Supplier supplier;
    private User creator;
    private List<ReceiptDetail> details = new ArrayList<>();

    public Receipt() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getReceiptCode() { return receiptCode; }
    public void setReceiptCode(String receiptCode) { this.receiptCode = receiptCode; }

    public Long getSupplierId() { return supplierId; }
    public void setSupplierId(Long supplierId) { this.supplierId = supplierId; }

    public Long getCreatedBy() { return createdBy; }
    public void setCreatedBy(Long createdBy) { this.createdBy = createdBy; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Supplier getSupplier() { return supplier; }
    public void setSupplier(Supplier supplier) { this.supplier = supplier; }

    public User getCreator() { return creator; }
    public void setCreator(User creator) { this.creator = creator; }

    public List<ReceiptDetail> getDetails() { return details; }
    public void setDetails(List<ReceiptDetail> details) { this.details = details; }
}