package com.mediverse;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class MediVerseBackendApplicationTests {

    @Test
    @DisplayName("Context Loads Cleanly")
    void contextLoads() {
        // Verifies Spring Application Context loads without errors
    }
}
