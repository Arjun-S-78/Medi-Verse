package com.mediverse.controller;

import com.mediverse.dto.user.*;
import com.mediverse.exception.ErrorResponse;
import com.mediverse.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication Module")
public class AuthController {

    private final UserService userService;

    @PostMapping("/register")
    @SecurityRequirements // Public Endpoint - No JWT Token Required
    @Operation(
            summary = "Register New User Account",
            description = "Creates a new user profile with role assignment (PATIENT, DOCTOR, AMBULANCE_DRIVER, HOSPITAL_ADMIN, SYSTEM_ADMIN). " +
                    "If registering as a PATIENT, automatically creates a 1:1 linked Emergency Health Passport record. Returns JWT tokens upon creation."
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "201",
                    description = "User successfully registered and authenticated",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = AuthResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid input payload or field validation error",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class))
            ),
            @ApiResponse(
                    responseCode = "409",
                    description = "Conflict: Email address or phone number is already registered",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody UserRegisterRequest request) {
        AuthResponse response = userService.register(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PostMapping("/login")
    @SecurityRequirements // Public Endpoint - No JWT Token Required
    @Operation(
            summary = "Authenticate User Credentials & Issue JWT",
            description = "Verifies user email and BCrypt-encoded password. Upon successful authentication, returns an Access Token, Refresh Token, User ID, Role, and Expiration."
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Authentication successful - JWT tokens issued",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = AuthResponse.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized: Invalid email or password credentials",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody UserLoginRequest request) {
        AuthResponse response = userService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/send-otp")
    @SecurityRequirements // Public Endpoint
    @Operation(
            summary = "Dispatch SMS OTP to Mobile Phone",
            description = "Generates a 6-digit verification pin and sends it via real SMS gateway (Twilio / Fast2SMS) or Dev Logger."
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "OTP successfully dispatched to recipient phone number",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = OtpResponse.class))
            )
    })
    public ResponseEntity<OtpResponse> sendOtp(@Valid @RequestBody OtpRequest request) {
        OtpResponse response = userService.sendOtp(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/verify-otp")
    @SecurityRequirements // Public Endpoint
    @Operation(
            summary = "Verify OTP & Authenticate User Session",
            description = "Validates active 6-digit OTP pin and returns JWT access tokens for active user authentication."
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "OTP verified successfully - JWT tokens issued",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = OtpResponse.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Unauthorized: Invalid or expired OTP verification code",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    public ResponseEntity<OtpResponse> verifyOtp(@Valid @RequestBody OtpVerifyRequest request) {
        OtpResponse response = userService.verifyOtp(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh-token")
    @SecurityRequirements // Public Endpoint - Refresh Token Provided in Request Body
    @Operation(
            summary = "Refresh Expired Access Token",
            description = "Validates an unexpired refresh token and issues a new JWT Access Token for active user sessions."
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Refreshed access token successfully issued",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = AuthResponse.class))
            ),
            @ApiResponse(
                    responseCode = "401",
                    description = "Invalid or expired refresh token",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    public ResponseEntity<AuthResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = userService.refreshToken(request);
        return ResponseEntity.ok(response);
    }
}
