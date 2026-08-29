"""
Medically plausible templates, symptom-vital relationships, and realistic patient dialogue variations for MIRA Synthetic Data Pipeline.
"""

import random

# 15 Emergency Case Categories
CASE_CATEGORIES = [
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
    "Ambiguous Presentations"
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
        if category in ["Chest Pain", "Major Trauma", "Unconsciousness", "Severe Bleeding"]:
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
    """Generates realistic, varied patient dialogue and corresponding red flags."""
    red_flags = []

    if category == "Chest Pain":
        if severity == "CRITICAL" or severity == "HIGH":
            red_flags = ["Crushing Chest Pain", "Radiation to Left Arm", "Sudden Onset"]
            if style == "concise":
                msg = "My chest really hurts and I can't breathe."
            elif style == "typos":
                msg = "My chst feels like an elephant is sittin on it. arm hurts bad."
            elif style == "anxious":
                msg = "Oh God please help me, there's this terrible crushing pressure in my chest and my left arm is going numb!!"
            elif style == "colloquial":
                msg = "I feel weird and my chest has this severe squeezing feeling since 20 mins ago."
            elif style == "minimizer":
                msg = "I thought it was just heartburn from dinner, but my chest feels tight and my jaw hurts."
            else:
                msg = "I don't know what's happening but my chest started hurting suddenly while sitting on the couch."
        else:
            if style == "concise":
                msg = "Mild discomfort in my upper chest after eating."
            else:
                msg = "I've had a slight dull ache near my ribs for two days when I stretch."

    elif category == "Breathing Difficulty":
        if severity in ["CRITICAL", "HIGH"]:
            red_flags = ["Severe Respiratory Distress", "Inability to speak full sentences"]
            msg = "I'm struggling... to get... any air in..." if style != "typos" else "cant breath... need air fast"
        else:
            msg = "I'm feeling a bit short of breath after walking up the stairs."

    elif category == "Unconsciousness":
        red_flags = ["Recent Loss of Consciousness", "Unresponsive Period"]
        if style == "minimizer":
            msg = "I passed out for a minute earlier, but I'm fine now."
        else:
            msg = "My husband collapsed on the floor and was completely unresponsive for 3 minutes."

    elif category == "Neurological Symptoms" or category == "Seizures":
        red_flags = ["Facial Droop", "Speech Slurring", "Active Seizure"]
        msg = "My mother suddenly can't speak properly and her left arm won't move."

    elif category == "Severe Bleeding":
        red_flags = ["Active Heavy Arterial Bleeding"]
        msg = "I cut my arm deep with a power tool and blood is pulsing out everywhere!"

    elif category == "Allergic Reaction":
        red_flags = ["Anaphylaxis", "Lip/Tongue Swelling"]
        msg = "I ate peanuts by mistake, my lips are swelling up fast and my throat feels tight!"

    elif category == "Major Trauma" or category == "Burns":
        red_flags = ["High Mechanism Trauma", "Full Thickness Burn"]
        msg = "Fell off a 12 foot ladder onto concrete, severe hip and neck pain."

    elif category == "Abdominal Pain":
        if severity == "HIGH":
            red_flags = ["Severe Right Lower Quadrant Pain", "Rigid Abdomen"]
            msg = "Unbearable sharp pain in my lower right stomach, vomiting since morning."
        else:
            msg = "Mild stomach cramps and feeling nauseous."

    elif category == "Fever":
        msg = "High temperature 39.5C with shivering and body pain."

    elif category == "Minor Injuries":
        msg = "Stubbed my pinky toe on the bed frame, it's bruised."

    elif category == "Ambiguous Presentations":
        if severity in ["HIGH", "CRITICAL"]:
            red_flags = ["Ambiguous Presentation with Hidden Cardiac Risk"]
            msg = "I just feel extremely weak, sweating heavily, and my upper stomach feels strange."
        else:
            msg = "I feel slightly off today, maybe tired."

    else:  # Multiple Simultaneous Symptoms / Low Risk
        msg = "I have a mild runny nose and slight headache."

    return msg, red_flags
