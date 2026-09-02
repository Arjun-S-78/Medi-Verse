package com.mediverse.service;

import com.mediverse.dto.user.OtpRequest;
import com.mediverse.dto.user.OtpResponse;
import com.mediverse.dto.user.OtpVerifyRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
@RequiredArgsConstructor
public class OtpService {

    private final SmsService smsService;
    private final SecureRandom secureRandom = new SecureRandom();

    private static final long OTP_EXPIRATION_SECONDS = 300; // 5 Minutes
    private final Map<String, OtpEntry> otpCache = new ConcurrentHashMap<>();

    private static class OtpEntry {
        final String code;
        final long expiresAt;

        OtpEntry(String code, long expiresAt) {
            this.code = code;
            this.expiresAt = expiresAt;
        }
    }

    /**
     * Generate and dispatch a 6-digit OTP to user's phone number.
     */
    public OtpResponse sendOtp(OtpRequest request) {
        String phoneNumber = request.getPhoneNumber().trim();
        String otpCode = String.format("%06d", secureRandom.nextInt(1000000));
        long expiresAt = Instant.now().getEpochSecond() + OTP_EXPIRATION_SECONDS;

        otpCache.put(phoneNumber, new OtpEntry(otpCode, expiresAt));

        String smsText = String.format("Your MediVerse Health verification code is: %s. Valid for 5 minutes. Do not share this code.", otpCode);
        String gatewayUsed = smsService.sendSms(phoneNumber, smsText);

        log.info("[OtpService] Generated OTP for phone {} (Gateway: {})", phoneNumber, gatewayUsed);

        return OtpResponse.builder()
                .success(true)
                .message("Verification code sent successfully to " + phoneNumber)
                .phoneNumber(phoneNumber)
                .sessionId("OTP-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase())
                .gatewayProvider(gatewayUsed)
                .debugOtpCode(gatewayUsed.contains("DEV") ? otpCode : null)
                .build();
    }

    /**
     * Verify if the supplied OTP matches the stored active entry.
     */
    public boolean verifyOtp(OtpVerifyRequest request) {
        String phoneNumber = request.getPhoneNumber().trim();
        String inputCode = request.getOtpCode().trim();

        OtpEntry entry = otpCache.get(phoneNumber);
        if (entry == null) {
            log.warn("[OtpService] No active OTP found for phone {}", phoneNumber);
            return false;
        }

        if (Instant.now().getEpochSecond() > entry.expiresAt) {
            otpCache.remove(phoneNumber);
            log.warn("[OtpService] Expired OTP attempted for phone {}", phoneNumber);
            return false;
        }

        if (!entry.code.equals(inputCode)) {
            log.warn("[OtpService] Invalid OTP code entered for phone {}", phoneNumber);
            return false;
        }

        // Consume OTP on successful match
        otpCache.remove(phoneNumber);
        log.info("[OtpService] OTP successfully verified for phone {}", phoneNumber);
        return true;
    }
}
