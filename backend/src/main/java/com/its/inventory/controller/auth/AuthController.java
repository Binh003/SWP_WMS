package com.its.inventory.controller.auth;

import com.its.inventory.dto.auth.LoginRequest;
import com.its.inventory.dto.auth.LoginResponse;
import com.its.inventory.dto.auth.LogoutResponse;
import com.its.inventory.dto.auth.ChangePasswordRequest;
import com.its.inventory.dto.auth.ChangePasswordResponse;
import com.its.inventory.dto.auth.ForgotPasswordRequest;
import com.its.inventory.dto.auth.ForgotPasswordResponse;
import com.its.inventory.dto.auth.ResetPasswordRequest;
import com.its.inventory.dto.auth.ResetPasswordResponse;
import com.its.inventory.dto.auth.RegisterRequest;
import com.its.inventory.dto.auth.RegisterResponse;
import com.its.inventory.dto.user.UserDto;
import com.its.inventory.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

  private final AuthService authService;

  @PostMapping("/login")
  public LoginResponse login(@Valid @RequestBody LoginRequest req) {
    return authService.login(req);
  }

  @PostMapping("/register")
  public RegisterResponse register(@Valid @RequestBody RegisterRequest req) {
    return authService.register(req);
  }

  @PostMapping("/forgot-password")
  public ForgotPasswordResponse forgotPassword(@Valid @RequestBody ForgotPasswordRequest req) {
    return authService.forgotPassword(req);
  }

  @PostMapping("/reset-password")
  public ResetPasswordResponse resetPassword(@Valid @RequestBody ResetPasswordRequest req) {
    return authService.resetPassword(req);
  }

  @PostMapping("/logout")
  public LogoutResponse logout() {
    authService.logout();
    return new LogoutResponse("ok");
  }

  @PostMapping("/change-password")
  public ChangePasswordResponse changePassword(
      @AuthenticationPrincipal UserDetails principal,
      @Valid @RequestBody ChangePasswordRequest req
  ) {
    return authService.changePassword(principal.getUsername(), req);
  }

  @GetMapping("/me")
  public UserDto me(@AuthenticationPrincipal UserDetails principal) {
    return authService.me(principal.getUsername());
  }
}
