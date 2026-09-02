package com.mediverse.dto.user;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OtpResponse {

    private boolean success;
    private String message;
    private String phoneNumber;
    private String sessionId;
    private String gatewayProvider; // TWILIO, FAST2SMS, DEV_LOG
    private String debugOtpCode; // Populated in dev/simulation mode for instant UX testing
    private AuthResponse authResponse; // Populated if verification completes login
}
