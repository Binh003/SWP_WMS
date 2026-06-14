package model;

import java.sql.Timestamp;

public class ShipmentHistory {
    private Long id;
    private Long shipmentId;
    private String fromStatus;
    private String toStatus;
    private Long changedBy;
    private Timestamp changedAt;
    private String notes;

    // Extended properties
    private User updater;

    public ShipmentHistory() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getShipmentId() { return shipmentId; }
    public void setShipmentId(Long shipmentId) { this.shipmentId = shipmentId; }

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
