package com.its.inventory.dto.auth;

import com.its.inventory.dto.user.UserDto;

public record RegisterResponse(
    String message,
    UserDto user
) {}
