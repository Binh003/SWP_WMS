package com.its.inventory.dto.role;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;
import org.hibernate.validator.constraints.UniqueElements;

public record UpdateRolePermissionsRequest(
    @UniqueElements List<@NotBlank @Size(max = 100) String> permissionCodes
) {}
