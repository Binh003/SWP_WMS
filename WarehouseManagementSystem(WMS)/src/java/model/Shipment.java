package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Shipment {
    private Long id;
    private String shipmentCode;
    private String destination;
    private Long createdBy;
    private String status;
    private String notes;
    private Timestamp createdAt;

    // Extended properties
    private User creator;
    private List<ShipmentDetail> details = new ArrayList<>();

    public Shipment() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getShipmentCode() { return shipmentCode; }
    public void setShipmentCode(String shipmentCode) { this.shipmentCode = shipmentCode; }

    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }

    public Long getCreatedBy() { return createdBy; }
    public void setCreatedBy(Long createdBy) { this.createdBy = createdBy; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public User getCreator() { return creator; }
    public void setCreator(User creator) { this.creator = creator; }

    public List<ShipmentDetail> getDetails() { return details; }
    public void setDetails(List<ShipmentDetail> details) { this.details = details; }
}
