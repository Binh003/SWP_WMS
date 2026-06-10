package model;

import java.sql.Timestamp;

public class ReceiptHistory {
    private Long id;
    private Long receiptId;
    private String fromStatus;
    private String toStatus;
    private Long changedBy;
    private Timestamp changedAt;
    private String notes;

    // Extended property
    private User updater;

    public ReceiptHistory() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getReceiptId() { return receiptId; }
    public void setReceiptId(Long receiptId) { this.receiptId = receiptId; }

    public String getFromStatus() { return fromStatus; }
    public void setFromStatus(String fromStatus) { this.fromStatus = fromStatus; }

    public String getToStatus() { return toStatus; }
    public void setToStatus(String toStatus) { this.toStatus = toStatus; }

    public Long getChangedBy() { return changedBy; }
    public void setChangedBy(Long changedBy) { this.changedBy = changedBy; }

    public Timestamp getChangedAt() { return changedAt; }
    public void setChangedAt(Timestamp changedAt) { this.changedAt = changedAt; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public User getUpdater() { return updater; }
    public void setUpdater(User updater) { this.updater = updater; }
}
