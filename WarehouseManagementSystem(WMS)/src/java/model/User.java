package model;

import java.util.ArrayList;
import java.util.List;

public class User {
    private long id;
    private String username;
    private String fullName;
    private String email;
    private String passwordHash;
    private boolean enabled = false;
    private String status = "PENDING";
    private List<Role> roles = new ArrayList<>();

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public boolean isEnabled() {
        return "ACTIVE".equalsIgnoreCase(status);
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
        this.status = enabled ? "ACTIVE" : "LOCKED";
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
        this.enabled = "ACTIVE".equalsIgnoreCase(status);
    }

    public List<Role> getRoles() {
        return roles;
    }

    public void setRoles(List<Role> roles) {
        this.roles = roles;
    }

    public boolean hasRole(String code) {
        for (Role role : roles) {
            if (code.equalsIgnoreCase(role.getCode())) {
                return true;
            }
        }
        return false;
    }

    public boolean hasPermission(String permissionCode) {
        for (Role role : roles) {
            if (role.getPermissionCodes() != null && role.getPermissionCodes().contains(permissionCode)) {
                return true;
            }
        }
        return false;
    }
}
