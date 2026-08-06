package com.mediverse.domain.enums;

public enum Role {
    PATIENT,
    DOCTOR,
    AMBULANCE_DRIVER,
    HOSPITAL_ADMIN,
    SYSTEM_ADMIN;

    public String getAuthority() {
        return "ROLE_" + name();
    }
}
