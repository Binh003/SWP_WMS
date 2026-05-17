package com.its.inventory.dto.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import java.util.List;
import org.hibernate.validator.constraints.UniqueElements;

public record CreateUserRequest(
    @NotBlank @Size(max = 100) String username,
    @NotBlank @Size(max = 200) String fullName,
    @NotBlank @Email @Size(max = 200) String email,
    @NotBlank @Size(min = 6, max = 100) String password,
    @UniqueElements List<@NotBlank @Size(max = 50) String> roleCodes
) {}
