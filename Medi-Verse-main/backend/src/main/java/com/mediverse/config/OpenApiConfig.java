package com.mediverse.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.tags.Tag;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    public static final String SECURITY_SCHEME_NAME = "BearerAuth";

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("MediVerse Emergency Healthcare API Documentation")
                        .version("v1.0.0")
                        .description("Production-grade OpenAPI documentation for MediVerse AI Assisted Emergency Healthcare, Triage, and Dispatch Engine.\n\n" +
                                "### Authentication\n" +
                                "Endpoints marked with a lock icon require a JWT Bearer token. Obtain a token by calling `/api/v1/auth/login` or `/api/v1/auth/register`, then click **Authorize** at top right and enter `Bearer <your_token>`.")
                        .contact(new Contact()
                                .name("MediVerse Engineering Team")
                                .email("dev@mediverse.health")
                                .url("https://mediverse.health"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0")))
                .servers(List.of(
                        new Server().url("http://localhost:8080").description("Local Development Server"),
                        new Server().url("https://api.mediverse.health").description("Production Gateway")
                ))
                .tags(List.of(
                        new Tag().name("Authentication Module").description("Role-based Registration, BCrypt Login, and JWT Token Management"),
                        new Tag().name("User Management Module").description("User Profile Inspection & Settings"),
                        new Tag().name("Patient Health Passport").description("Emergency Medical Record & ICE Contact Management"),
                        new Tag().name("System Health").description("Backend Health & Diagnostic Readiness Check")
                ))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME))
                .components(new Components()
                        .addSecuritySchemes(SECURITY_SCHEME_NAME, new SecurityScheme()
                                .name(SECURITY_SCHEME_NAME)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("Enter JWT Token obtained from `/api/v1/auth/login` or `/api/v1/auth/register`")));
    }
}
