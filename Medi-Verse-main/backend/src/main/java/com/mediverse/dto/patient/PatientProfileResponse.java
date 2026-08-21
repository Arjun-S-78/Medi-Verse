package com.mediverse.dto.patient;

import com.mediverse.domain.enums.BloodGroup;
import com.mediverse.domain.enums.Gender;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PatientProfileResponse {

    private UUID id;
    private UUID userId;
    private String fullName;
    private String email;
    private String phoneNumber;
    private Integer age;
    private Gender gender;
    private BloodGroup bloodGroup;
    private String bloodGroupLabel;
    private String iceContactName;
    private String iceContactPhone;
    private Set<String> medicalConditions;
    private String allergies;
    private String currentVitals;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
