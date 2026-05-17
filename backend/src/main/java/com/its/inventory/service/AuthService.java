package com.its.inventory.service;

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

public interface AuthService {
  LoginResponse login(LoginRequest req);

  RegisterResponse register(RegisterRequest req);

  ChangePasswordResponse changePassword(String username, ChangePasswordRequest req);

  ForgotPasswordResponse forgotPassword(ForgotPasswordRequest req);

  ResetPasswordResponse resetPassword(ResetPasswordRequest req);

  void logout();

  UserDto me(String username);
}
