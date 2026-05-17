package com.its.inventory.service.impl;

import com.its.inventory.dto.user.CreateUserRequest;
import com.its.inventory.dto.user.UpdateUserRequest;
import com.its.inventory.dto.user.UpdateUserRolesRequest;
import com.its.inventory.dto.user.UserDto;
import com.its.inventory.entity.User;
import com.its.inventory.mapper.UserMapper;
import com.its.inventory.repository.RoleRepository;
import com.its.inventory.repository.UserRepository;
import com.its.inventory.service.UserService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;
  private final RoleRepository roleRepository;

  @Override
  @Transactional
  public UserDto create(CreateUserRequest req) {
    if (userRepository.existsByUsername(req.username())) {
      throw new IllegalArgumentException("Username already exists");
    }

    // Basic uniqueness for email in dev (no DB constraint yet).
    // If needed, we can add a unique index later.

    var roleCodes = (req.roleCodes() == null || req.roleCodes().isEmpty())
        ? List.of("VIEWER")
        : req.roleCodes();

    var roles = roleCodes.stream()
        .map(code -> roleRepository.findByCode(code)
            .orElseThrow(() -> new IllegalArgumentException("Role not found: " + code)))
        .toList();

    var u = User.builder()
        .username(req.username())
        .fullName(req.fullName())
        .email(req.email())
        .passwordHash(passwordEncoder.encode(req.password()))
        .enabled(true)
        .build();
    u.getRoles().addAll(roles);

    return UserMapper.toDto(userRepository.save(u));
  }

  @Override
  @Transactional(readOnly = true)
  public List<UserDto> list() {
    // Ensure roles are available for DTO serialization.
    return userRepository.findAll().stream().map(UserMapper::toDto).toList();
  }

  @Override
  @Transactional(readOnly = true)
  public UserDto get(long userId) {
    var u = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
    return UserMapper.toDto(u);
  }

  @Override
  @Transactional
  public UserDto update(long userId, UpdateUserRequest req) {
    var u = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
    u.setFullName(req.fullName());
    u.setEmail(req.email());
    return UserMapper.toDto(u);
  }

  @Override
  @Transactional
  public UserDto setRoles(long userId, UpdateUserRolesRequest req) {
    var u = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));

    var roleCodes = req.roleCodes() == null ? List.<String>of() : req.roleCodes();
    var roles = roleCodes.stream()
        .map(code -> roleRepository.findByCode(code)
            .orElseThrow(() -> new IllegalArgumentException("Role not found: " + code)))
        .toList();

    u.getRoles().clear();
    u.getRoles().addAll(roles);
    return UserMapper.toDto(u);
  }

  @Override
  @Transactional
  public UserDto setEnabled(long userId, boolean enabled) {
    var u = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
    u.setEnabled(enabled);
    return UserMapper.toDto(u);
  }
}
