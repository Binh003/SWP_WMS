package com.its.inventory.dto.user;

import com.its.inventory.dto.role.RoleDto;
import java.util.List;

public record UserDto(
    Long id,
    String username,
    String fullName,
    String email,
    boolean enabled,
    List<RoleDto> roles
) {}
