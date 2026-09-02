package com.mediverse.service.impl;

import com.mediverse.config.JwtProperties;
import com.mediverse.domain.enums.BloodGroup;
import com.mediverse.domain.enums.Gender;
import com.mediverse.domain.enums.Role;
import com.mediverse.domain.model.Patient;
import com.mediverse.domain.model.User;
import com.mediverse.domain.repository.UserRepository;
import com.mediverse.dto.user.*;
import com.mediverse.exception.ApiException;
import com.mediverse.exception.ResourceNotFoundException;
import com.mediverse.exception.UnauthorizedException;
import com.mediverse.security.JwtTokenProvider;
import com.mediverse.service.OtpService;
import com.mediverse.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final JwtProperties jwtProperties;
    private final OtpService otpService;

    @Override
    @Transactional
    public AuthResponse register(UserRegisterRequest request) {
        log.info("Processing registration request for email: {} with role: {}", request.getEmail(), request.getRole());

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new ApiException("Email address is already registered in MediVerse", HttpStatus.CONFLICT);
        }

        if (userRepository.existsByPhoneNumber(request.getPhoneNumber())) {
            throw new ApiException("Phone number is already associated with an account", HttpStatus.CONFLICT);
        }

        Role role = (request.getRole() != null) ? request.getRole() : Role.PATIENT;

        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail().toLowerCase().trim())
                .password(passwordEncoder.encode(request.getPassword()))
                .phoneNumber(request.getPhoneNumber())
                .role(role)
                .enabled(true)
                .build();

        if (role == Role.PATIENT && request.getAge() != null) {
            Patient patientProfile = Patient.builder()
                    .user(user)
                    .age(request.getAge())
                    .gender(request.getGender() != null ? Gender.valueOf(request.getGender().toUpperCase()) : Gender.OTHER)
                    .bloodGroup(request.getBloodGroup() != null ? BloodGroup.fromLabel(request.getBloodGroup()) : BloodGroup.O_POSITIVE)
                    .iceContactName(request.getIceContactName() != null ? request.getIceContactName() : "Not Provided")
                    .iceContactPhone(request.getIceContactPhone() != null ? request.getIceContactPhone() : request.getPhoneNumber())
                    .medicalConditions(request.getMedicalConditions() != null ? request.getMedicalConditions() : new HashSet<>())
                    .allergies(request.getAllergies())
                    .currentVitals("Normal")
                    .build();

            user.setPatientProfile(patientProfile);
        }

        User savedUser = userRepository.save(user);
        log.info("User registered successfully with ID: {} and Role: {}", savedUser.getId(), savedUser.getRole());

        return buildAuthResponse(savedUser);
    }

    @Override
    @Transactional(readOnly = true)
    public AuthResponse login(UserLoginRequest request) {
        log.info("Authenticating login request for email: {}", request.getEmail());

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail().toLowerCase().trim(),
                        request.getPassword()
                )
        );

        User user = userRepository.findByEmail(request.getEmail().toLowerCase().trim())
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", request.getEmail()));

        log.info("User authenticated successfully: {} [Role: {}]", user.getId(), user.getRole());

        return buildAuthResponse(user);
    }

    @Override
    @Transactional(readOnly = true)
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();

        if (!tokenProvider.validateToken(refreshToken)) {
            throw new UnauthorizedException("Invalid or expired refresh token");
        }

        String email = tokenProvider.getEmailFromToken(refreshToken);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));

        log.info("Issued refreshed JWT tokens for user: {}", user.getEmail());

        return buildAuthResponse(user);
    }

    @Override
    public OtpResponse sendOtp(OtpRequest request) {
        return otpService.sendOtp(request);
    }

    @Override
    @Transactional
    public OtpResponse verifyOtp(OtpVerifyRequest request) {
        boolean isValid = otpService.verifyOtp(request);
        if (!isValid) {
            throw new ApiException("Invalid or expired 6-digit OTP verification code", HttpStatus.UNAUTHORIZED);
        }

        String phone = request.getPhoneNumber().trim();
        Optional<User> userOpt = userRepository.findByPhoneNumber(phone);

        User user;
        if (userOpt.isPresent()) {
            user = userOpt.get();
        } else {
            // Auto-provision user on first OTP phone login
            String generatedEmail = "user_" + phone.replaceAll("[^0-9]", "") + "@mediverse.health";
            user = User.builder()
                    .fullName("MediVerse Patient (" + phone + ")")
                    .email(generatedEmail)
                    .password(passwordEncoder.encode(UUID.randomUUID().toString()))
                    .phoneNumber(phone)
                    .role(Role.PATIENT)
                    .enabled(true)
                    .build();

            Patient patientProfile = Patient.builder()
                    .user(user)
                    .age(28)
                    .gender(Gender.OTHER)
                    .bloodGroup(BloodGroup.O_POSITIVE)
                    .iceContactName("Emergency Contact")
                    .iceContactPhone(phone)
                    .currentVitals("Normal")
                    .build();
            user.setPatientProfile(patientProfile);
            user = userRepository.save(user);
            log.info("[UserService] Created new OTP patient user profile for phone: {}", phone);
        }

        AuthResponse authResponse = buildAuthResponse(user);
        return OtpResponse.builder()
                .success(true)
                .message("Phone number successfully verified. Authenticated into MediVerse!")
                .phoneNumber(phone)
                .authResponse(authResponse)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public UserResponse getUserById(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));
        return mapToUserResponse(user);
    }

    @Override
    @Transactional(readOnly = true)
    public UserResponse getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
        return mapToUserResponse(user);
    }

    private AuthResponse buildAuthResponse(User user) {
        String accessToken = tokenProvider.generateAccessToken(user);
        String refreshToken = tokenProvider.generateRefreshToken(user);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .userId(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .role(user.getRole())
                .expiresInMs(jwtProperties.getExpirationMs())
                .build();
    }

    private UserResponse mapToUserResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .phoneNumber(user.getPhoneNumber())
                .role(user.getRole())
                .enabled(user.isEnabled())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
