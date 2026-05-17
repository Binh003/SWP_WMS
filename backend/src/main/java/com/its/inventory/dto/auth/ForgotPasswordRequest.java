package com.its.inventory.dto.auth;

import jakarta.validation.constraints.NotBlank;

public record ForgotPasswordRequest(
    @NotBlank String usernameOrEmail
) {}
