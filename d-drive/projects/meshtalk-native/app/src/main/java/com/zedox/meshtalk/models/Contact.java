package com.zedox.meshtalk.models;

import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "contacts")
public class Contact {
    @PrimaryKey(autoGenerate = true)
    private int id;
    private String name;
    private String deviceId;
    private String ipAddress;
    private String preferredLanguage;

    public Contact(String name, String deviceId, String ipAddress, String preferredLanguage) {
        this.name = name;
        this.deviceId = deviceId;
        this.ipAddress = ipAddress;
        this.preferredLanguage = preferredLanguage;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public String getPreferredLanguage() {
        return preferredLanguage;
    }
}
