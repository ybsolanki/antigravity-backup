package com.zedox.meshtalk.models;

public class Message {
    private String id;
    private String senderId;
    private String recipientId;
    private String content;
    private long timestamp;
    private boolean isEmergency;

    public Message(String id, String senderId, String recipientId, String content, boolean isEmergency) {
        this.id = id;
        this.senderId = senderId;
        this.recipientId = recipientId;
        this.content = content;
        this.timestamp = System.currentTimeMillis();
        this.isEmergency = isEmergency;
    }

    public String getId() {
        return id;
    }

    public String getSenderId() {
        return senderId;
    }

    public String getRecipientId() {
        return recipientId;
    }

    public String getContent() {
        return content;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public boolean isEmergency() {
        return isEmergency;
    }
}
