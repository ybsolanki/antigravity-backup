package com.zedox.meshtalk.ai;

import android.content.Context;
import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.mlkit.nl.smartreply.SmartReply;
import com.google.mlkit.nl.smartreply.SmartReplyGenerator;
import com.google.mlkit.nl.smartreply.SmartReplySuggestion;
import com.google.mlkit.nl.smartreply.SmartReplySuggestionResult;
import com.google.mlkit.nl.smartreply.TextMessage;
import java.util.ArrayList;
import java.util.List;

public class NeuralGuideService {
    private final SmartReplyGenerator smartReply;
    private final List<TextMessage> conversationContext = new ArrayList<>();

    public NeuralGuideService() {
        this.smartReply = SmartReply.getClient();
    }

    public void processQuery(String query, OnSolutionListener listener) {
        // Fallback for specific disaster solutions (Offline Expert System)
        String expertSolution = checkExpertSystem(query);
        if (expertSolution != null) {
            listener.onSolutionFound(expertSolution);
            return;
        }

        // Use ML Kit for general interaction
        conversationContext.add(TextMessage.createForRemoteUser(query, System.currentTimeMillis(), "USER"));

        smartReply.suggestReplies(conversationContext)
                .addOnCompleteListener(new OnCompleteListener<SmartReplySuggestionResult>() {
                    @Override
                    public void onComplete(@NonNull Task<SmartReplySuggestionResult> task) {
                        if (task.isSuccessful()) {
                            SmartReplySuggestionResult result = task.getResult();
                            if (result.getStatus() == SmartReplySuggestionResult.STATUS_SUCCESS) {
                                StringBuilder response = new StringBuilder();
                                for (SmartReplySuggestion suggestion : result.getSuggestions()) {
                                    response.append(suggestion.getText()).append("\n");
                                }
                                if (response.length() > 0) {
                                    listener.onSolutionFound(response.toString().trim());
                                } else {
                                    listener.onSolutionFound(
                                            "Neural link active. I'm monitoring the mesh for solutions.");
                                }
                            } else {
                                listener.onSolutionFound(
                                        "Offline protocols active. How can I assist with your mesh node?");
                            }
                        } else {
                            listener.onError(task.getException());
                        }
                    }
                });
    }

    private String checkExpertSystem(String query) {
        String q = query.toLowerCase();
        if (q.contains("medical") || q.contains("hurt") || q.contains("doctor")) {
            return "MEDICAL PROTOCOL: Apply pressure to wounds. Keep patient warm. Broadcast location on MESH Channel 1.";
        }
        if (q.contains("fire") || q.contains("smoke")) {
            return "FIRE PROTOCOL: Evacuate immediately. Stay low. Alert nearby nodes using EMERGENCY BROADCAST.";
        }
        if (q.contains("mesh link") || q.contains("connection") || q.contains("no peers")) {
            return "MESH OPTIMIZATION: Move to higher ground. Check Sub-GHz antenna. Ensure RADIO IDENTITY is synced.";
        }
        if (q.contains("who are you") || q.contains("zedox")) {
            return "I am the Zedox Neural Guide, an offline AI module designed to assist in connectivity and disaster recovery.";
        }
        return null; // Let ML Kit handle general conversation
    }

    public interface OnSolutionListener {
        void onSolutionFound(String solution);

        void onError(Exception e);
    }
}
