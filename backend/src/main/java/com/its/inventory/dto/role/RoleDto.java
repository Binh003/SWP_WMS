package com.its.inventory.dto.role;

public record RoleDto(
    Long id,
    String code,
    String name,
    boolean enabled
) {}
