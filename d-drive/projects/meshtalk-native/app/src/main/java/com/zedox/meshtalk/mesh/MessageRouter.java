package com.zedox.meshtalk.mesh;

import android.util.Log;
import com.zedox.meshtalk.models.Message;
import java.util.HashSet;
import java.util.Set;

public class MessageRouter {
    private static final String TAG = "MessageRouter";
    private Set<String> processedMessageIds = new HashSet<>();

    public void handleIncomingMessage(Message message, String currentDeviceId) {
        if (processedMessageIds.contains(message.getId())) {
            // Already seen this message, ignore to prevent loops
            return;
        }

        processedMessageIds.add(message.getId());

        if (message.getRecipientId().equals(currentDeviceId)) {
            Log.d(TAG, "Message reached destination: " + message.getContent());
            // TODO: Deliver to UI
        } else {
            Log.d(TAG, "Relaying message: " + message.getId());
            relayMessage(message);
        }
    }

    private void relayMessage(Message message) {
        // Multi-hop logic: broadcast to all connected peers except the sender
        // TODO: Integrate with WiFiDirectManager's transmission logic
    }
}
