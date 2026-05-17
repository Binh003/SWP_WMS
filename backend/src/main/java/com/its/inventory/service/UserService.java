package com.its.inventory.service;

import com.its.inventory.dto.user.CreateUserRequest;
import com.its.inventory.dto.user.UpdateUserRequest;
import com.its.inventory.dto.user.UpdateUserRolesRequest;
import com.its.inventory.dto.user.UserDto;
import java.util.List;

public interface UserService {
  UserDto create(CreateUserRequest req);

  List<UserDto> list();

  UserDto get(long userId);

  UserDto update(long userId, UpdateUserRequest req);

  UserDto setRoles(long userId, UpdateUserRolesRequest req);

  UserDto setEnabled(long userId, boolean enabled);
}
