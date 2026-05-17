package com.its.inventory.controller.role;

import com.its.inventory.dto.permission.PermissionDto;
import com.its.inventory.dto.role.CreateRoleRequest;
import com.its.inventory.dto.role.RoleDetailDto;
import com.its.inventory.dto.role.RoleDto;
import com.its.inventory.dto.role.UpdateRoleRequest;
import com.its.inventory.dto.role.UpdateRolePermissionsRequest;
import com.its.inventory.entity.Permission;
import com.its.inventory.entity.Role;
import com.its.inventory.repository.PermissionRepository;
import com.its.inventory.repository.RoleRepository;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN') or hasAuthority('ROLE_WRITE')")
public class RoleController {

  private final RoleRepository roleRepository;
  private final PermissionRepository permissionRepository;

  @GetMapping("/roles")
  @PreAuthorize("hasRole('ADMIN') or hasAuthority('ROLE_READ')")
  public List<RoleDto> listRoles() {
    return roleRepository.findAll().stream()
        .map(r -> new RoleDto(r.getId(), r.getCode(), r.getName(), r.isEnabled()))
        .toList();
  }

  @GetMapping("/roles/{id}")
  @PreAuthorize("hasRole('ADMIN') or hasAuthority('ROLE_READ')")
  public RoleDetailDto getRole(@PathVariable long id) {
    var r = roleRepository.findByIdWithPermissions(id)
        .orElseThrow(() -> new IllegalArgumentException("Role not found"));
    var permissionCodes = r.getPermissions().stream().map(Permission::getCode).sorted().toList();
    return new RoleDetailDto(r.getId(), r.getCode(), r.getName(), r.getDescription(), r.isEnabled(), permissionCodes);
  }

  @PostMapping("/roles")
  public RoleDto createRole(@Valid @RequestBody CreateRoleRequest req) {
    if (roleRepository.existsByCode(req.code())) {
      throw new IllegalArgumentException("Role code already exists");
    }
    Role r = Role.builder().code(req.code()).name(req.name()).build();
    var saved = roleRepository.save(r);
    return new RoleDto(saved.getId(), saved.getCode(), saved.getName(), saved.isEnabled());
  }

  @PutMapping("/roles/{id}")
  public RoleDto updateRole(@PathVariable long id, @Valid @RequestBody UpdateRoleRequest req) {
    var r = roleRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Role not found"));
    r.setName(req.name());
    r.setDescription(req.description());
    return new RoleDto(r.getId(), r.getCode(), r.getName(), r.isEnabled());
  }

  @PutMapping("/roles/{id}/enabled")
  public RoleDto setRoleEnabled(@PathVariable long id, @RequestParam boolean enabled) {
    var r = roleRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Role not found"));
    r.setEnabled(enabled);
    return new RoleDto(r.getId(), r.getCode(), r.getName(), r.isEnabled());
  }

  @PutMapping("/roles/{id}/permissions")
  public RoleDto setRolePermissions(@PathVariable long id, @Valid @RequestBody UpdateRolePermissionsRequest req) {
    var role = roleRepository.findByIdWithPermissions(id)
        .orElseThrow(() -> new IllegalArgumentException("Role not found"));
    var codes = req.permissionCodes() == null ? List.<String>of() : req.permissionCodes();
    var perms = codes.stream()
        .map(code -> permissionRepository.findByCode(code)
            .orElseThrow(() -> new IllegalArgumentException("Permission not found: " + code)))
        .toList();
    role.getPermissions().clear();
    role.getPermissions().addAll(perms);
    var saved = roleRepository.save(role);
    return new RoleDto(saved.getId(), saved.getCode(), saved.getName(), saved.isEnabled());
  }

  @GetMapping("/permissions")
  @PreAuthorize("hasRole('ADMIN') or hasAuthority('PERMISSION_READ')")
  public List<PermissionDto> listPermissions() {
    return permissionRepository.findAll().stream()
        .map(p -> new PermissionDto(p.getId(), p.getCode(), p.getName()))
        .toList();
  }
}
