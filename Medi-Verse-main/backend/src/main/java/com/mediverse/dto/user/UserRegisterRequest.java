package com.mediverse.dto.user;

import com.mediverse.domain.enums.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserRegisterRequest {

    @NotBlank(message = "Full name is required")
    @Size(min = 2, max = 150, message = "Full name must be between 2 and 150 characters")
    private String fullName;

    @NotBlank(message = "Email address is required")
    @Email(message = "Invalid email address format")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, max = 100, message = "Password must be at least 6 characters")
    private String password;

    @NotBlank(message = "Phone number is required")
    private String phoneNumber;

    private Role role; // Optional: PATIENT, DOCTOR, AMBULANCE_DRIVER, HOSPITAL_ADMIN, SYSTEM_ADMIN (Defaults to PATIENT)

    // Patient Specific Optional Attributes
    private Integer age;
    private String gender;
    private String bloodGroup;
    private String iceContactName;
    private String iceContactPhone;
    private Set<String> medicalConditions;
    private String allergies;
}
