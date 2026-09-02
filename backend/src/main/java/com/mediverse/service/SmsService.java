package com.mediverse.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;

@Slf4j
@Service
public class SmsService {

    @Value("${TWILIO_ACCOUNT_SID:}")
    private String twilioAccountSid;

    @Value("${TWILIO_AUTH_TOKEN:}")
    private String twilioAuthToken;

    @Value("${TWILIO_PHONE_NUMBER:}")
    private String twilioFromNumber;

    @Value("${FAST2SMS_API_KEY:}")
    private String fast2smsApiKey;

    @Value("${SMS_API_KEY:}")
    private String smsApiKey;

    @Value("${FIREBASE_API_KEY:}")
    private String firebaseApiKey;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    /**
     * Dispatch SMS OTP to mobile number using configured SMS gateway (Firebase, Twilio, Fast2SMS, Textbelt, or Dev Console).
     */
    public String sendSms(String phoneNumber, String message) {
        String cleanPhone = phoneNumber.replaceAll("[^0-9+]", "");

        // 1. Try Firebase Phone Auth if configured
        if (isFirebaseConfigured()) {
            try {
                boolean sent = sendViaFirebase(cleanPhone, message);
                if (sent) {
                    log.info("[SmsService] Successfully dispatched SMS via Firebase Phone Auth to {}", cleanPhone);
                    return "FIREBASE_FREE";
                }
            } catch (Exception e) {
                log.error("[SmsService] Firebase Phone Auth dispatch failed: {}", e.getMessage());
            }
        }

        // 2. Try Twilio if configured
        if (isTwilioConfigured()) {
            try {
                boolean sent = sendViaTwilio(cleanPhone, message);
                if (sent) {
                    log.info("[SmsService] Successfully dispatched SMS via Twilio to {}", cleanPhone);
                    return "TWILIO";
                }
            } catch (Exception e) {
                log.error("[SmsService] Twilio SMS dispatch failed: {}", e.getMessage());
            }
        }

        // 3. Try Fast2SMS / SMS Gateway if configured
        if (isFast2SMSConfigured()) {
            try {
                boolean sent = sendViaFast2SMS(cleanPhone, message);
                if (sent) {
                    log.info("[SmsService] Successfully dispatched SMS via Fast2SMS Gateway to {}", cleanPhone);
                    return "FAST2SMS";
                }
            } catch (Exception e) {
                log.error("[SmsService] Fast2SMS SMS dispatch exception: {}", e.getMessage());
            }
        }

        // 4. Try Textbelt Free Instant SMS Gateway (No Key Required, 1 Free SMS/Day)
        try {
            boolean sent = sendViaTextbelt(cleanPhone, message);
            if (sent) {
                log.info("[SmsService] Successfully dispatched free real SMS via Textbelt to {}", cleanPhone);
                return "TEXTBELT_FREE";
            }
        } catch (Exception e) {
            log.warn("[SmsService] Textbelt Free Gateway limit reached or failed: {}", e.getMessage());
        }

        // 5. Fallback to Console Logger & Interactive Dev Simulator
        log.info("================================================================");
        log.info("📱 [REAL OTP SMS SIMULATOR - DEV GATEWAY]");
        log.info("Recipient Phone: {}", cleanPhone);
        log.info("Message: {}", message);
        log.info("================================================================");
        return "DEV_LOG";
    }

    private boolean isFirebaseConfigured() {
        return firebaseApiKey != null && !firebaseApiKey.isBlank();
    }

    private boolean isTwilioConfigured() {
        return twilioAccountSid != null && !twilioAccountSid.isBlank() &&
               twilioAuthToken != null && !twilioAuthToken.isBlank() &&
               twilioFromNumber != null && !twilioFromNumber.isBlank();
    }

    private boolean isFast2SMSConfigured() {
        String key = getActiveFast2SMSKey();
        return key != null && !key.isBlank();
    }

    private String getActiveFast2SMSKey() {
        if (fast2smsApiKey != null && !fast2smsApiKey.isBlank()) return fast2smsApiKey.trim();
        if (smsApiKey != null && !smsApiKey.isBlank()) return smsApiKey.trim();
        return null;
    }

    private boolean sendViaFirebase(String toPhone, String messageText) throws Exception {
        String url = "https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode?key=" + firebaseApiKey.trim();
        String jsonPayload = String.format("{\"phoneNumber\":\"%s\"}", toPhone);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        log.info("[SmsService] Firebase Identity Toolkit Response: {}", response.body());
        return response.statusCode() == 200 && response.body().contains("sessionInfo");
    }

    private boolean sendViaTwilio(String toPhone, String messageText) throws Exception {
        String url = String.format("https://api.twilio.com/2010-04-01/Accounts/%s/Messages.json", twilioAccountSid);
        String formBody = String.format("To=%s&From=%s&Body=%s",
                URLEncoder.encode(toPhone, StandardCharsets.UTF_8),
                URLEncoder.encode(twilioFromNumber, StandardCharsets.UTF_8),
                URLEncoder.encode(messageText, StandardCharsets.UTF_8));

        String authHeader = "Basic " + Base64.getEncoder().encodeToString(
                (twilioAccountSid + ":" + twilioAuthToken).getBytes(StandardCharsets.UTF_8));

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", authHeader)
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formBody))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        return response.statusCode() == 200 || response.statusCode() == 201;
    }

    private boolean sendViaFast2SMS(String toPhone, String messageText) throws Exception {
        String apiKey = getActiveFast2SMSKey();
        String number = toPhone.startsWith("+91") ? toPhone.substring(3) : toPhone.replaceAll("^\\+", "");
        
        String url = "https://www.fast2sms.com/dev/bulkV2";
        String formBody = String.format("route=v3&sender_id=TXTIND&message=%s&language=english&flash=0&numbers=%s",
                URLEncoder.encode(messageText, StandardCharsets.UTF_8),
                URLEncoder.encode(number, StandardCharsets.UTF_8));

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("authorization", apiKey)
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formBody))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        String body = response.body();
        log.info("[SmsService] Fast2SMS Gateway Status: {}, Response: {}", response.statusCode(), body);

        if (response.statusCode() == 200 && (body.contains("\"return\":true") || body.contains("success"))) {
            return true;
        }

        return false;
    }

    private boolean sendViaTextbelt(String toPhone, String messageText) throws Exception {
        String url = "https://textbelt.com/text";
        String formBody = String.format("phone=%s&message=%s&key=textbelt",
                URLEncoder.encode(toPhone, StandardCharsets.UTF_8),
                URLEncoder.encode(messageText, StandardCharsets.UTF_8));

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(formBody))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        String body = response.body();
        log.info("[SmsService] Textbelt Gateway Response: {}", body);
        return response.statusCode() == 200 && body.contains("\"success\":true");
    }
}
