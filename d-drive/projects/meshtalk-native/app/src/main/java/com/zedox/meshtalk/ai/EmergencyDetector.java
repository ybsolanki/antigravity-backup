package com.zedox.meshtalk.ai;

import java.util.Arrays;
import java.util.List;

public class EmergencyDetector {
    private static final List<String> EMERGENCY_KEYWORDS = Arrays.asList(
            "help", "emergency", "hurt", "injured", "medical", "doctor",
            "ambulance", "fire", "danger", "police", "trapped", "bleeding");

    public boolean isEmergency(String text) {
        if (text == null || text.isEmpty())
            return false;

        String lowerText = text.toLowerCase();
        for (String keyword : EMERGENCY_KEYWORDS) {
            if (lowerText.contains(keyword)) {
                return true;
            }
        }
        return false;
    }
}
