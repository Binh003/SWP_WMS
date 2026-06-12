package model;

import java.sql.Timestamp;

public class InventoryHistory {
    private String transactionType; // "IMPORT" or "EXPORT"
    private Long transactionId;
    private String transactionCode;
    private Timestamp transactionDate;
    private Integer quantity;
    private String partnerName; // Supplier name for Import, Destination for Export
    private String creatorName;
    private String notes;

    public InventoryHistory() {}

    public InventoryHistory(String transactionType, Long transactionId, String transactionCode, 
                            Timestamp transactionDate, Integer quantity, String partnerName, 
                            String creatorName, String notes) {
        this.transactionType = transactionType;
        this.transactionId = transactionId;
        this.transactionCode = transactionCode;
        this.transactionDate = transactionDate;
        this.quantity = quantity;
        this.partnerName = partnerName;
        this.creatorName = creatorName;
        this.notes = notes;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public Long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(Long transactionId) {
        this.transactionId = transactionId;
    }

    public String getTransactionCode() {
        return transactionCode;
    }

    public void setTransactionCode(String transactionCode) {
        this.transactionCode = transactionCode;
    }

    public Timestamp getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(Timestamp transactionDate) {
        this.transactionDate = transactionDate;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public String getPartnerName() {
        return partnerName;
    }

    public void setPartnerName(String partnerName) {
        this.partnerName = partnerName;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}
