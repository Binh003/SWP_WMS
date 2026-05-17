package com.its.inventory.dto.role;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateRoleRequest(
    @NotBlank @Size(max = 200) String name,
    @Size(max = 500) String description
) {}
