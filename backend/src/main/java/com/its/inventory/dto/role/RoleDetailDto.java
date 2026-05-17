package com.its.inventory.dto.role;

import java.util.List;

public record RoleDetailDto(
    Long id,
    String code,
    String name,
    String description,
    boolean enabled,
    List<String> permissionCodes
) {}
