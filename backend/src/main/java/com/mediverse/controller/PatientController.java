package com.mediverse.controller;

import com.mediverse.dto.patient.PatientProfileRequest;
import com.mediverse.dto.patient.PatientProfileResponse;
import com.mediverse.exception.ErrorResponse;
import com.mediverse.service.PatientService;
import com.mediverse.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

import static com.mediverse.config.OpenApiConfig.SECURITY_SCHEME_NAME;

@RestController
@RequestMapping("/api/v1/patients")
@RequiredArgsConstructor
@Tag(name = "Patient Health Passport")
@SecurityRequirement(name = SECURITY_SCHEME_NAME)
public class PatientController {

    private final PatientService patientService;
    private final UserService userService;

    @GetMapping("/me/passport")
    @Operation(
            summary = "Get Authenticated Patient's Emergency Health Passport",
            description = "Retrieves current patient's encrypted emergency record including Blood Group, ICE Contact, Allergies, Medical Conditions, and Vitals."
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Emergency Health Passport record retrieved successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = PatientProfileResponse.class))
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Patient profile record not found",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    public ResponseEntity<PatientProfileResponse> getMyPassport(@AuthenticationPrincipal UserDetails userDetails) {
        PatientProfileResponse response = patientService.getPatientProfileByEmail(userDetails.getUsername());
        return ResponseEntity.ok(response);
    }

    @PutMapping("/me/passport")
    @Operation(
            summary = "Update Emergency Health Passport Record",
            description = "Updates emergency contact details, medical conditions, allergies, and real-time vital metrics."
    )
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Emergency Health Passport updated successfully",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = PatientProfileResponse.class))
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Validation failed for request fields",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    public ResponseEntity<PatientProfileResponse> updateMyPassport(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody PatientProfileRequest request
    ) {
        var user = userService.getUserByEmail(userDetails.getUsername());
        PatientProfileResponse response = patientService.updatePatientProfile(user.getId(), request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{userId}/passport")
    @Operation(
            summary = "Get Patient Health Passport by User ID (Paramedic / ER Medical Access)",
            description = "Allows verified medical staff (DOCTOR, AMBULANCE_DRIVER, HOSPITAL_ADMIN, SYSTEM_ADMIN) to view emergency health passport data."
    )
    @PreAuthorize("hasAnyRole('DOCTOR', 'AMBULANCE_DRIVER', 'HOSPITAL_ADMIN', 'SYSTEM_ADMIN')")
    @ApiResponses(value = {
            @ApiResponse(
                    responseCode = "200",
                    description = "Health Passport details retrieved",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = PatientProfileResponse.class))
            ),
            @ApiResponse(
                    responseCode = "403",
                    description = "Forbidden: Insufficient privileges (Requires ER / Responder role)",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    public ResponseEntity<PatientProfileResponse> getPassportByUserId(
            @Parameter(description = "Patient User UUID", required = true) @PathVariable UUID userId
    ) {
        PatientProfileResponse response = patientService.getPatientProfileByUserId(userId);
        return ResponseEntity.ok(response);
    }
}
