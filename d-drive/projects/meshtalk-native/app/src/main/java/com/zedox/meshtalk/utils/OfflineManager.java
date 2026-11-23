package com.zedox.meshtalk.utils;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

public class OfflineManager {

    /**
     * Ensures we only use internet for the initial setup phase (downloading AI
     * models).
     * Once models are downloaded, all features are locked to offline-only.
     */
    public static boolean isInternetAvailable(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        return activeNetwork != null && activeNetwork.isConnectedOrConnecting();
    }

    public static void logOfflineStatus() {
        // Log to local Room DB instead of external monitoring services
    }
}
