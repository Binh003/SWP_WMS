package com.its.inventory.dto.auth;

import com.its.inventory.dto.user.UserDto;

public record LoginResponse(
    String accessToken,
    String tokenType,
    UserDto user
) {}
