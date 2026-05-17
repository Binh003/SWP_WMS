package com.its.inventory.dto.user;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;
import org.hibernate.validator.constraints.UniqueElements;

public record UpdateUserRolesRequest(
    @UniqueElements List<@NotBlank @Size(max = 50) String> roleCodes
) {}
