package com.its.inventory.dto.auth;

// Dev-friendly response: returns token so FE can show/copy it.
public record ForgotPasswordResponse(
    String message,
    String resetToken
) {}
