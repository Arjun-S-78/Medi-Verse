package com.mediverse.service;

import com.mediverse.dto.patient.PatientProfileRequest;
import com.mediverse.dto.patient.PatientProfileResponse;

import java.util.UUID;

public interface PatientService {

    PatientProfileResponse getPatientProfileByUserId(UUID userId);

    PatientProfileResponse getPatientProfileByEmail(String email);

    PatientProfileResponse updatePatientProfile(UUID userId, PatientProfileRequest request);
}
