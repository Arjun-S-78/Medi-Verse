package com.mediverse.domain.model;

import com.mediverse.domain.enums.BloodGroup;
import com.mediverse.domain.enums.Gender;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "patient_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Patient {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Column(name = "age", nullable = false)
    private Integer age;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender", nullable = false, length = 20)
    private Gender gender;

    @Enumerated(EnumType.STRING)
    @Column(name = "blood_group", nullable = false, length = 20)
    private BloodGroup bloodGroup;

    @Column(name = "ice_contact_name", nullable = false, length = 150)
    private String iceContactName;

    @Column(name = "ice_contact_phone", nullable = false, length = 30)
    private String iceContactPhone;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "patient_medical_conditions", joinColumns = @JoinColumn(name = "patient_id"))
    @Column(name = "condition_name")
    @Builder.Default
    private Set<String> medicalConditions = new HashSet<>();

    @Column(name = "allergies", length = 255)
    private String allergies;

    @Column(name = "current_vitals", length = 100)
    private String currentVitals;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
