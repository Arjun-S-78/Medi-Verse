"""
Medically plausible templates, symptom-vital relationships, Coimbatore hospital databases, and realistic patient dialogue variations for MIRA Synthetic Data Pipeline.
"""

import random

# 28 Comprehensive Medical & Local Coimbatore Case Categories
CASE_CATEGORIES = [
    # Local Healthcare & Coimbatore Hospital Inquiries
    "Coimbatore Best Hospital Recommendation",
    "Coimbatore Emergency ICU Finder",
    "Coimbatore Doctor Consultation Inquiry",
    "Coimbatore Orthopedic & Trauma Care",
    "Coimbatore Cardiac Emergency Center",
    "Coimbatore Maternity & Pediatrics Inquiry",
    # Medical Triage & Clinical Emergency Scenarios
    "Chest Pain",
    "Breathing Difficulty",
    "Major Trauma",
    "Severe Bleeding",
    "Burns",
    "Fever",
    "Abdominal Pain",
    "Allergic Reaction",
    "Neurological Symptoms",
    "Seizures",
    "Unconsciousness",
    "Minor Injuries",
    "Low-Risk Complaints",
    "Multiple Simultaneous Symptoms",
    "Ambiguous Presentations",
    # General Medical & Specialty Q&A
    "Cardiology Q&A",
    "Neurology Q&A",
    "Dermatology & Skin Care Q&A",
    "Gastroenterology & Stomach Health",
    "Pediatric Health Q&A",
    "Diabetes & Chronic Disease Care",
    "General First Aid & Home Remedy",
    "Medication Usage & Dosage Advice"
]

# Patient conversation styles
CONVERSATION_STYLES = [
    "concise",
    "detailed",
    "colloquial",
    "typos",
    "anxious",
    "confused",
    "minimizer",
    "gradual"
]

# Coimbatore Areas for geographic diversity
COIMBATORE_AREAS = [
    "Peelamedu", "Avinashi Road", "Gandhipuram", "RS Puram", "Saravanampatti", 
    "Singanallur", "Mettupalayam Road", "Ukkadam", "Ramanathapuram", "Vadavalli",
    "Thudiyalur", "Hopes College", "Civil Aerodrome Post", "Neelambur", "Kovaipudur"
]

# Top Coimbatore Hospitals Knowledge Base
COIMBATORE_HOSPITALS = [
    {
        "name": "PSG Hospitals",
        "location": "Peelamedu, Avinashi Road, Coimbatore",
        "specialty": "Multi-Specialty & Level 1 Trauma Center",
        "key_doctors": ["Dr. S. Rajendran", "Dr. J. S. Bhuvaneswaran"],
        "phone": "+91 422 257 0170",
        "icu_beds": "24/7 ICU & Critical Bay",
        "best_for": "Trauma, Emergency ICU, Multi-Specialty Surgery, Cardiology"
    },
    {
        "name": "Ganga Hospital",
        "location": "313 Mettupalayam Road, Coimbatore",
        "specialty": "Orthopedics, Trauma & Plastic Surgery Center",
        "key_doctors": ["Dr. S. Raja Sabapathy", "Dr. S. Rajasekaran"],
        "phone": "+91 422 248 5000",
        "icu_beds": "Dedicated Trauma & Surgical ICU",
        "best_for": "Orthopedic Surgery, Joint Replacement, Spine Trauma, Plastic & Reconstructive Surgery"
    },
    {
        "name": "KMCH (Kovai Medical Center and Hospital)",
        "location": "Avinashi Road, Civil Aerodrome Post, Coimbatore",
        "specialty": "Multi-Specialty, Super Speciality & Cardiac Emergency",
        "key_doctors": ["Dr. Nalla G. Palaniswami", "Dr. Prashanth"],
        "phone": "+91 422 432 3800",
        "icu_beds": "Comprehensive Cardiac & Neuro ICU",
        "best_for": "Cardiology, Organ Transplant, Oncology, Neurology, Emergency Ambulance"
    },
    {
        "name": "Sri Ramakrishna Hospital",
        "location": "395 Sarojini Naidu Rd, Siddhapudur, Coimbatore",
        "specialty": "Multi-Specialty & Cancer Institute",
        "key_doctors": ["Dr. P. Guhan", "Dr. Isaac"],
        "phone": "+91 422 450 0000",
        "icu_beds": "Multi-Disciplinary ICU",
        "best_for": "Oncology, Nephrology, General Medicine, Pediatrics, Dialysis"
    },
    {
        "name": "G. Kuppuswamy Naidu Memorial Hospital (GKNM)",
        "location": "Pappanaickenpalayam, Coimbatore",
        "specialty": "Heart & Vascular Institute, Pediatrics & Maternity",
        "key_doctors": ["Dr. Ragupathy", "Dr. Kalyanasundaram"],
        "phone": "+91 422 224 5000",
        "icu_beds": "Pediatric & Neonatal ICU (NICU/PICU)",
        "best_for": "Pediatric Cardiology, Heart Surgeries, High-Risk Obstetrics & Newborn Care"
    },
    {
        "name": "Royal Care Super Speciality Hospital",
        "location": "1/574, Avinashi Rd, Neelambur, Coimbatore",
        "specialty": "Advanced Neuro & Cardiac Critical Care",
        "key_doctors": ["Dr. K. Madeswaran", "Dr. Chacko"],
        "phone": "+91 422 222 7000",
        "icu_beds": "State-of-the-Art Neuro ICU",
        "best_for": "Neurosurgery, Acute Stroke Intervention, Interventional Radiology, Critical Care"
    },
    {
        "name": "KG Hospital",
        "location": "Arts College Road, Coimbatore",
        "specialty": "Heart Center & Advanced Emergency Trauma",
        "key_doctors": ["Dr. G. Bakthavathsalam", "Dr. Coonoor"],
        "phone": "+91 422 221 2121",
        "icu_beds": "24/7 Cardiac Care Unit (CCU)",
        "best_for": "Cardiology, Dialysis, Emergency Trauma, Stroke Management"
    },
    {
        "name": "Coimbatore Medical College Hospital (CMCH)",
        "location": "Trichy Road, Gopalapuram, Coimbatore",
        "specialty": "Government Tertiary Super Speciality Hospital",
        "key_doctors": ["Duty Medical Officer", "Chief Resident Physician"],
        "phone": "+91 422 230 1393",
        "icu_beds": "Government Emergency Bay",
        "best_for": "Government Schemes, Public Trauma Care, Emergency Poison & Resuscitation"
    }
]

# Medical history options
MEDICAL_HISTORIES = [
    ["Hypertension", "Type 2 Diabetes"],
    ["Asthma"],
    ["Coronary Artery Disease", "High Cholesterol"],
    ["COPD"],
    ["Epilepsy"],
    ["Severe Peanut Allergy"],
    ["Previous Stroke"],
    ["GERD"],
    ["No known past medical history"]
]

# Common medications matching histories
MEDICATIONS_MAP = {
    "Hypertension": ["Amlodipine 5mg", "Telmisartan 40mg"],
    "Type 2 Diabetes": ["Metformin 500mg"],
    "Asthma": ["Salbutamol Inhaler"],
    "Coronary Artery Disease": ["Aspirin 75mg", "Atorvastatin 20mg"],
    "COPD": ["Tiotropium Inhaler"],
    "Epilepsy": ["Sodium Valproate 500mg"],
    "Previous Stroke": ["Clopidogrel 75mg"],
    "GERD": ["Pantoprazole 40mg"],
    "No known past medical history": []
}

def generate_vitals(severity: str, category: str) -> dict:
    """Generates medically realistic vital signs based on case severity and category."""
    if severity == "CRITICAL":
        if category in ["Chest Pain", "Major Trauma", "Unconsciousness", "Severe Bleeding", "Coimbatore Cardiac Emergency Center"]:
            return {
                "heart_rate": random.randint(120, 160),
                "spo2": random.randint(75, 88),
                "bp_systolic": random.randint(70, 90),
                "bp_diastolic": random.randint(40, 60),
                "temp_c": round(random.uniform(36.1, 37.8), 1)
            }
        elif category == "Breathing Difficulty":
            return {
                "heart_rate": random.randint(130, 155),
                "spo2": random.randint(78, 85),
                "bp_systolic": random.randint(150, 180),
                "bp_diastolic": random.randint(95, 110),
                "temp_c": round(random.uniform(36.5, 38.5), 1)
            }
        else:
            return {
                "heart_rate": random.randint(115, 145),
                "spo2": random.randint(84, 89),
                "bp_systolic": random.randint(80, 100),
                "bp_diastolic": random.randint(50, 65),
                "temp_c": round(random.uniform(36.0, 39.5), 1)
            }
    elif severity == "HIGH":
        return {
            "heart_rate": random.randint(105, 125),
            "spo2": random.randint(90, 93),
            "bp_systolic": random.randint(140, 165),
            "bp_diastolic": random.randint(90, 100),
            "temp_c": round(random.uniform(36.5, 38.8), 1)
        }
    elif severity == "MODERATE":
        return {
            "heart_rate": random.randint(85, 104),
            "spo2": random.randint(94, 96),
            "bp_systolic": random.randint(125, 138),
            "bp_diastolic": random.randint(80, 88),
            "temp_c": round(random.uniform(36.8, 38.2), 1)
        }
    else:  # LOW
        return {
            "heart_rate": random.randint(68, 84),
            "spo2": random.randint(97, 100),
            "bp_systolic": random.randint(110, 122),
            "bp_diastolic": random.randint(70, 80),
            "temp_c": round(random.uniform(36.4, 37.2), 1)
        }

def generate_patient_utterance(category: str, severity: str, style: str) -> tuple[str, list[str]]:
    """Generates realistic, highly varied patient dialogue and corresponding red flags."""
    red_flags = []
    area = random.choice(COIMBATORE_AREAS)
    hosp_sample = random.choice(COIMBATORE_HOSPITALS)["name"]

    if category == "Coimbatore Best Hospital Recommendation":
        templates = [
            f"Which is the best hospital in Coimbatore near {area} for emergency medical treatment?",
            f"Can you recommend the top rated multi-specialty hospital near {area} in Coimbatore?",
            f"Looking for the best hospital in Coimbatore for full body health checkup.",
            f"What are the top 3 best hospitals in Coimbatore with high quality ICU beds?",
            f"Is {hosp_sample} or KMCH considered the best hospital near {area} in Coimbatore?",
            f"Need urgent advice: best hospital in Coimbatore for 24/7 care near {area}."
        ]
        msg = random.choice(templates)

    elif category == "Coimbatore Emergency ICU Finder":
        red_flags = ["Emergency ICU Requirement"] if severity in ["HIGH", "CRITICAL"] else []
        templates = [
            f"Need immediate 24/7 ICU beds in Coimbatore around {area}. Which hospital has open beds?",
            f"Emergency ICU room finder near {area} Coimbatore for critical patient.",
            f"Which hospital near {area} Coimbatore has Level 1 Trauma ICU and ambulance support?",
            f"Looking for urgent cardiac ICU bed availability near {area} in Coimbatore right now!"
        ]
        msg = random.choice(templates)

    elif category == "Coimbatore Orthopedic & Trauma Care":
        red_flags = ["Trauma / Fracture Risk"] if severity in ["HIGH", "CRITICAL"] else []
        templates = [
            f"What is the best orthopedic and fracture hospital near {area} in Coimbatore?",
            f"My relative had an accident near {area}. Is Ganga Hospital or PSG Hospitals best for bone surgery?",
            f"Top spine surgeon and joint replacement hospital in Coimbatore?",
            f"Emergency bone trauma hospital recommendation in Coimbatore near {area}."
        ]
        msg = random.choice(templates)

    elif category == "Coimbatore Cardiac Emergency Center":
        red_flags = ["Crushing Chest Pain", "Sudden Onset"] if severity in ["HIGH", "CRITICAL"] else []
        templates = [
            f"Which is the top cardiac emergency hospital in Coimbatore near {area} for heart attack?",
            f"Urgent: chest pain patient near {area}. Need nearest hospital with 24/7 cath lab in Coimbatore.",
            f"Best cardiologist doctor and heart care center near {area} Coimbatore?",
            f"Looking for emergency CCU cardiac unit near {area} in Coimbatore."
        ]
        msg = random.choice(templates)

    elif category == "Coimbatore Maternity & Pediatrics Inquiry":
        templates = [
            f"Which hospital in Coimbatore near {area} is best for delivery and newborn NICU care?",
            f"Is GKNM Hospital or Sri Ramakrishna Hospital better for maternity care in Coimbatore?",
            f"Top pediatric specialist doctor and child hospital in Coimbatore near {area}.",
            f"Emergency 24/7 pediatric hospital in Coimbatore for high fever in toddler."
        ]
        msg = random.choice(templates)

    elif category == "Coimbatore Doctor Consultation Inquiry":
        templates = [
            f"How can I book doctor appointment at {hosp_sample} or KMCH in Coimbatore?",
            f"Looking for experienced general physician near {area} Coimbatore.",
            f"Top neurology and cardiology doctors available in Coimbatore town today?",
            f"Can MIRA assist in finding doctor consultation timings near {area} in Coimbatore?"
        ]
        msg = random.choice(templates)

    # General Medical & Specialty Q&A
    elif category == "Cardiology Q&A":
        templates = [
            "What are the early warning signs of a heart attack versus hyperacidity?",
            "Blood pressure is 145/92 mmHg today. What steps should I take?",
            "How can I lower LDL cholesterol naturally with diet and exercise?",
            "Why do I feel rapid heart palpitations when resting after dinner?"
        ]
        msg = random.choice(templates)

    elif category == "Neurology Q&A":
        red_flags = ["Speech Slurring", "Facial Droop"] if severity in ["HIGH", "CRITICAL"] else []
        templates = [
            "What are the key signs of acute stroke using FAST assessment?",
            "Severe migraine headache on left side with light sensitivity for 4 hours.",
            "What causes sudden vertigo and lightheadedness when turning head?",
            "Tingling sensation and numbness in fingers for past 2 days."
        ]
        msg = random.choice(templates)

    elif category == "Dermatology & Skin Care Q&A":
        templates = [
            "Red itchy skin rash developed after starting new antibiotic medicine.",
            "What is the best home relief for mild thermal sunburn?",
            "How to identify fungal ringworm infection versus skin eczema?",
            "Mosquito bite swelled up with mild redness and itching."
        ]
        msg = random.choice(templates)

    elif category == "Gastroenterology & Stomach Health":
        templates = [
            "Burning pain in upper stomach and throat after spicy meal.",
            "Sharp pain in right lower abdomen accompanied by nausea.",
            "How to manage mild gastric disturbance and diarrhea at home?",
            "Feeling bloated with constipation for 3 consecutive days."
        ]
        msg = random.choice(templates)

    elif category == "Pediatric Health Q&A":
        templates = [
            "My 5-year-old child has fever 38.6C and mild cough. What is safe paracetamol dose?",
            "Child has mild loose motion but drinking ORS solution well.",
            "Natural remedies to ease infant stomach colic and gas distress?",
            "When does fever in toddlers require emergency hospital visit?"
        ]
        msg = random.choice(templates)

    elif category == "Diabetes & Chronic Disease Care":
        templates = [
            "Fasting blood glucose reading is 175 mg/dL, what lifestyle changes help?",
            "What are the warning signs of hypoglycemia low sugar episode?",
            "How frequently should HbA1c blood test be repeated for diabetics?",
            "Is leg numbness common in long-term diabetes management?"
        ]
        msg = random.choice(templates)

    elif category == "General First Aid & Home Remedy":
        templates = [
            "First aid steps for minor steam burn on hand?",
            "Proper technique to stop nosebleed at home safely?",
            "RICE protocol steps for acute ankle sprain injury?",
            "What is the correct recovery position if someone faints?"
        ]
        msg = random.choice(templates)

    elif category == "Medication Usage & Dosage Advice":
        templates = [
            "Can antacid and painkiller be taken together after food?",
            "What are common side effects of amlodipine blood pressure pills?",
            "Why is completing full antibiotic course important?",
            "How to correctly use rescue asthma inhaler during wheezing?"
        ]
        msg = random.choice(templates)

    # Core Triage & Clinical Emergency Categories
    elif category == "Chest Pain":
        if severity in ["CRITICAL", "HIGH"]:
            red_flags = ["Crushing Chest Pain", "Radiation to Left Arm", "Sudden Onset"]
            templates = [
                "My chest really hurts and I can't breathe.",
                "Crushing pressure in my chest radiating to left arm and jaw since 15 minutes.",
                "Chest pain feels like heavy weight on my heart with cold sweat.",
                "Sudden severe squeezing chest discomfort while resting."
            ]
            msg = random.choice(templates)
        else:
            msg = "Mild dull pain in upper chest after eating heavy meal."

    elif category == "Breathing Difficulty":
        if severity in ["CRITICAL", "HIGH"]:
            red_flags = ["Severe Respiratory Distress", "Inability to speak full sentences"]
            msg = "I'm struggling... to get... any air in... gasping for breath."
        else:
            msg = "Feeling slightly winded and short of breath after climbing two flights of stairs."

    elif category == "Unconsciousness":
        red_flags = ["Recent Loss of Consciousness", "Unresponsive Period"]
        msg = "My family member collapsed suddenly and was unconscious for 2 minutes."

    elif category == "Neurological Symptoms" or category == "Seizures":
        red_flags = ["Facial Droop", "Speech Slurring", "Active Seizure"]
        msg = "Patient has sudden facial droop, slurred speech, and weakness in right arm."

    elif category == "Severe Bleeding":
        red_flags = ["Active Heavy Arterial Bleeding"]
        msg = "Deep laceration on forearm with heavy pulsing bleeding that won't stop with pressure."

    elif category == "Allergic Reaction":
        red_flags = ["Anaphylaxis", "Lip/Tongue Swelling"]
        msg = "Accidentally consumed peanuts, experiencing rapid lip swelling and throat tightness!"

    elif category == "Major Trauma" or category == "Burns":
        red_flags = ["High Mechanism Trauma", "Full Thickness Burn"]
        msg = "Fell from 10 foot height onto hard ground, severe hip and back pain."

    elif category == "Abdominal Pain":
        if severity == "HIGH":
            red_flags = ["Severe Right Lower Quadrant Pain", "Rigid Abdomen"]
            msg = "Severe sharp pain in right lower stomach with vomiting and inability to touch belly."
        else:
            msg = "Mild abdominal cramps and nausea since yesterday."

    elif category == "Fever":
        msg = "High body temperature 39.4C accompanied by chills, shivering, and body ache."

    elif category == "Minor Injuries":
        msg = "Minor cut on thumb while chopping vegetables, bleeding controlled."

    elif category == "Ambiguous Presentations":
        if severity in ["HIGH", "CRITICAL"]:
            red_flags = ["Ambiguous Presentation with Hidden Cardiac Risk"]
            msg = "Feeling unexplainably exhausted, heavy sweating, and mild epigastric discomfort."
        else:
            msg = "Feeling slightly fatigued and off balance today."

    else:  # Multiple Simultaneous Symptoms / Low Risk
        msg = "Mild runny nose, sneezing, and light headache."

    return msg, red_flags
