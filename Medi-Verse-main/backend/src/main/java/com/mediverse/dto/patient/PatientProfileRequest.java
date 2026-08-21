package com.mediverse.dto.patient;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PatientProfileRequest {

    @NotNull(message = "Age is required")
    private Integer age;

    @NotBlank(message = "Gender is required")
    private String gender;

    @NotBlank(message = "Blood group is required")
    private String bloodGroup;

    @NotBlank(message = "ICE Contact Name is required")
    private String iceContactName;

    @NotBlank(message = "ICE Contact Phone is required")
    private String iceContactPhone;

    private Set<String> medicalConditions;

    private String allergies;

    private String currentVitals;
}
