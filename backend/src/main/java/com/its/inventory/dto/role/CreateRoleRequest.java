package com.its.inventory.dto.role;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateRoleRequest(
    @NotBlank @Size(max = 50) String code,
    @NotBlank @Size(max = 200) String name
) {}
