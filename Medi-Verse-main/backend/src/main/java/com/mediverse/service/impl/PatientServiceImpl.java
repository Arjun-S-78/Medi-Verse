package com.mediverse.service.impl;

import com.mediverse.domain.enums.BloodGroup;
import com.mediverse.domain.enums.Gender;
import com.mediverse.domain.model.Patient;
import com.mediverse.domain.repository.PatientRepository;
import com.mediverse.dto.patient.PatientProfileRequest;
import com.mediverse.dto.patient.PatientProfileResponse;
import com.mediverse.exception.ResourceNotFoundException;
import com.mediverse.service.PatientService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PatientServiceImpl implements PatientService {

    private final PatientRepository patientRepository;

    @Override
    @Transactional(readOnly = true)
    public PatientProfileResponse getPatientProfileByUserId(UUID userId) {
        log.debug("Fetching patient profile for user ID: {}", userId);
        Patient patient = patientRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Patient profile", "userId", userId));
        return mapToPatientResponse(patient);
    }

    @Override
    @Transactional(readOnly = true)
    public PatientProfileResponse getPatientProfileByEmail(String email) {
        log.debug("Fetching patient profile for user email: {}", email);
        Patient patient = patientRepository.findByUserEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("Patient profile", "email", email));
        return mapToPatientResponse(patient);
    }

    @Override
    @Transactional
    public PatientProfileResponse updatePatientProfile(UUID userId, PatientProfileRequest request) {
        log.info("Updating emergency health passport profile for user ID: {}", userId);

        Patient patient = patientRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Patient profile", "userId", userId));

        patient.setAge(request.getAge());
        patient.setGender(Gender.valueOf(request.getGender().toUpperCase()));
        patient.setBloodGroup(BloodGroup.fromLabel(request.getBloodGroup()));
        patient.setIceContactName(request.getIceContactName());
        patient.setIceContactPhone(request.getIceContactPhone());

        if (request.getMedicalConditions() != null) {
            patient.setMedicalConditions(new HashSet<>(request.getMedicalConditions()));
        }

        if (request.getAllergies() != null) {
            patient.setAllergies(request.getAllergies());
        }

        if (request.getCurrentVitals() != null) {
            patient.setCurrentVitals(request.getCurrentVitals());
        }

        Patient updatedPatient = patientRepository.save(patient);
        log.info("Successfully updated patient health passport for user ID: {}", userId);

        return mapToPatientResponse(updatedPatient);
    }

    private PatientProfileResponse mapToPatientResponse(Patient patient) {
        return PatientProfileResponse.builder()
                .id(patient.getId())
                .userId(patient.getUser().getId())
                .fullName(patient.getUser().getFullName())
                .email(patient.getUser().getEmail())
                .phoneNumber(patient.getUser().getPhoneNumber())
                .age(patient.getAge())
                .gender(patient.getGender())
                .bloodGroup(patient.getBloodGroup())
                .bloodGroupLabel(patient.getBloodGroup() != null ? patient.getBloodGroup().getLabel() : null)
                .iceContactName(patient.getIceContactName())
                .iceContactPhone(patient.getIceContactPhone())
                .medicalConditions(patient.getMedicalConditions())
                .allergies(patient.getAllergies())
                .currentVitals(patient.getCurrentVitals())
                .createdAt(patient.getCreatedAt())
                .updatedAt(patient.getUpdatedAt())
                .build();
    }
}
