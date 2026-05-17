package com.its.inventory.service.impl;

import com.its.inventory.dto.auth.LoginRequest;
import com.its.inventory.dto.auth.LoginResponse;
import com.its.inventory.dto.auth.ChangePasswordRequest;
import com.its.inventory.dto.auth.ChangePasswordResponse;
import com.its.inventory.dto.auth.ForgotPasswordRequest;
import com.its.inventory.dto.auth.ForgotPasswordResponse;
import com.its.inventory.dto.auth.ResetPasswordRequest;
import com.its.inventory.dto.auth.ResetPasswordResponse;
import com.its.inventory.dto.auth.RegisterRequest;
import com.its.inventory.dto.auth.RegisterResponse;
import com.its.inventory.dto.user.UserDto;
import com.its.inventory.entity.User;
import com.its.inventory.entity.PasswordResetToken;
import com.its.inventory.service.AuthService;
import com.its.inventory.security.JwtService;
import com.its.inventory.mapper.UserMapper;
import com.its.inventory.repository.PasswordResetTokenRepository;
import com.its.inventory.repository.RoleRepository;
import com.its.inventory.repository.UserRepository;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

  private final AuthenticationManager authenticationManager;
  private final JwtService jwtService;
  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;
  private final RoleRepository roleRepository;
  private final PasswordResetTokenRepository passwordResetTokenRepository;

  @Override
  @Transactional(readOnly = true)
  public LoginResponse login(LoginRequest req) {
    try {
      authenticationManager.authenticate(
          new UsernamePasswordAuthenticationToken(req.username(), req.password())
      );
    } catch (AuthenticationException ex) {
      throw ex;
    }

    var u = userRepository.findByUsername(req.username())
        .orElseThrow(() -> new IllegalArgumentException("User not found"));

    var token = jwtService.generateToken(u.getUsername());
    return new LoginResponse(token, "Bearer", UserMapper.toDto(u));
  }

  @Override
  @Transactional
  public RegisterResponse register(RegisterRequest req) {
    if (userRepository.existsByUsername(req.username())) {
      throw new IllegalArgumentException("Username already exists");
    }

    var viewerRole = roleRepository.findByCode("VIEWER")
        .orElseThrow(() -> new IllegalStateException("Default role VIEWER is not seeded"));

    // New accounts must be approved by an admin.
    User u = User.builder()
        .username(req.username())
        .fullName(req.username())
        .email(req.username())
        .passwordHash(passwordEncoder.encode(req.password()))
        .enabled(false)
        .build();
    u.getRoles().add(viewerRole);

    var saved = userRepository.save(u);
    return new RegisterResponse("pending_admin_approval", UserMapper.toDto(saved));
  }

  @Override
  public void logout() {
    // Stateless JWT: client deletes token. (Optional: implement token blacklist later.)
  }

  @Override
  @Transactional
  public ChangePasswordResponse changePassword(String username, ChangePasswordRequest req) {
    var u = userRepository.findByUsername(username)
        .orElseThrow(() -> new IllegalArgumentException("User not found"));

    if (!passwordEncoder.matches(req.currentPassword(), u.getPasswordHash())) {
      throw new IllegalArgumentException("Current password is incorrect");
    }

    u.setPasswordHash(passwordEncoder.encode(req.newPassword()));
    return new ChangePasswordResponse("ok");
  }

  @Override
  @Transactional
  public ForgotPasswordResponse forgotPassword(ForgotPasswordRequest req) {
    // Best-effort cleanup.
    passwordResetTokenRepository.deleteByExpiresAtBefore(Instant.now());

    var input = req.usernameOrEmail().trim();
    var u = userRepository.findByUsername(input).orElse(null);
    if (u == null) {
      // Try match by email.
      u = userRepository.findAll().stream()
          .filter(x -> x.getEmail() != null && x.getEmail().equalsIgnoreCase(input))
          .findFirst()
          .orElse(null);
    }
    if (u == null) {
      // Don't leak existence; still return ok with null token.
      return new ForgotPasswordResponse("ok", null);
    }

    var token = UUID.randomUUID().toString().replace("-", "");
    var expiresAt = Instant.now().plus(30, ChronoUnit.MINUTES);
    passwordResetTokenRepository.save(PasswordResetToken.builder()
        .user(u)
        .token(token)
        .expiresAt(expiresAt)
        .used(false)
        .build());

    return new ForgotPasswordResponse("ok", token);
  }

  @Override
  @Transactional
  public ResetPasswordResponse resetPassword(ResetPasswordRequest req) {
    var prt = passwordResetTokenRepository.findByToken(req.token())
        .orElseThrow(() -> new IllegalArgumentException("Invalid token"));
    if (prt.isUsed() || prt.getExpiresAt().isBefore(Instant.now())) {
      throw new IllegalArgumentException("Token expired or used");
    }

    var u = prt.getUser();
    u.setPasswordHash(passwordEncoder.encode(req.newPassword()));
    prt.setUsed(true);
    return new ResetPasswordResponse("ok");
  }

  @Override
  @Transactional(readOnly = true)
  public UserDto me(String username) {
    var u = userRepository.findByUsername(username)
        .orElseThrow(() -> new IllegalArgumentException("User not found"));
    return UserMapper.toDto(u);
  }
}
