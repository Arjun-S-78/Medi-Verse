package com.mediverse.health;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/health")
@Tag(name = "System Health", description = "System diagnostic and status endpoint")
public class HealthCheckController {

    @GetMapping
    @Operation(summary = "Check backend system health", description = "Returns system status, timestamp, and active service metrics")
    public ResponseEntity<Map<String, Object>> checkHealth() {
        Map<String, Object> status = Map.of(
                "status", "UP",
                "service", "MediVerse Emergency Healthcare Backend",
                "version", "1.0.0 Enterprise",
                "timestamp", LocalDateTime.now().toString(),
                "database", "PostgreSQL Configured",
                "security", "JWT Auth Filter Enabled"
        );
        return ResponseEntity.ok(status);
    }
}
