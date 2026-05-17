package com.its.inventory.mapper;

import com.its.inventory.dto.user.UserDto;
import com.its.inventory.dto.role.RoleDto;
import com.its.inventory.entity.User;

public final class UserMapper {
  private UserMapper() {}

  public static UserDto toDto(User u) {
    var roles = u.getRoles().stream()
        .map(r -> new RoleDto(r.getId(), r.getCode(), r.getName(), r.isEnabled()))
        .toList();
    return new UserDto(u.getId(), u.getUsername(), u.getFullName(), u.getEmail(), u.isEnabled(), roles);
  }
}
