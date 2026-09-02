package com.mediverse.service;

import com.mediverse.dto.user.*;

import java.util.UUID;

public interface UserService {

    AuthResponse register(UserRegisterRequest request);

    AuthResponse login(UserLoginRequest request);

    AuthResponse refreshToken(RefreshTokenRequest request);

    OtpResponse sendOtp(OtpRequest request);

    OtpResponse verifyOtp(OtpVerifyRequest request);

    UserResponse getUserById(UUID id);

    UserResponse getUserByEmail(String email);
}
