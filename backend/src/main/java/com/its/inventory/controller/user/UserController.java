package com.its.inventory.controller.user;

import com.its.inventory.dto.user.CreateUserRequest;
import com.its.inventory.dto.user.UpdateUserRequest;
import com.its.inventory.dto.user.UpdateUserRolesRequest;
import com.its.inventory.dto.user.UserDto;
import com.its.inventory.service.UserService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN') or hasAuthority('USER_WRITE')")
public class UserController {

  private final UserService userService;

  @PostMapping
  public UserDto create(@Valid @RequestBody CreateUserRequest req) {
    return userService.create(req);
  }

  @GetMapping
  @PreAuthorize("hasRole('ADMIN') or hasAuthority('USER_READ') or hasAuthority('USER_WRITE')")
  public List<UserDto> list() {
    return userService.list();
  }

  @GetMapping("/{id}")
  @PreAuthorize("hasRole('ADMIN') or hasAuthority('USER_READ') or hasAuthority('USER_WRITE')")
  public UserDto get(@PathVariable long id) {
    return userService.get(id);
  }

  @PutMapping("/{id}")
  public UserDto update(@PathVariable long id, @Valid @RequestBody UpdateUserRequest req) {
    return userService.update(id, req);
  }

  @PutMapping("/{id}/roles")
  public UserDto setRoles(@PathVariable long id, @Valid @RequestBody UpdateUserRolesRequest req) {
    return userService.setRoles(id, req);
  }

  @PutMapping("/{id}/enabled")
  public UserDto setEnabled(@PathVariable long id, @RequestParam boolean enabled) {
    return userService.setEnabled(id, enabled);
  }
}
