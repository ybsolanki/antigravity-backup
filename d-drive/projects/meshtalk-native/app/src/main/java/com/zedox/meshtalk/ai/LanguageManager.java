package com.zedox.meshtalk.ai;

import android.util.Log;
import com.google.mlkit.common.model.DownloadConditions;
import com.google.mlkit.common.model.RemoteModelManager;
import com.google.mlkit.nl.translate.TranslateLanguage;
import com.google.mlkit.nl.translate.TranslateRemoteModel;
import java.util.Set;

public class LanguageManager {
    private static final String TAG = "LanguageManager";
    private RemoteModelManager modelManager;

    public LanguageManager() {
        modelManager = RemoteModelManager.getInstance();
    }

    public void downloadModel(String languageCode, OnModelActionCompleteListener listener) {
        TranslateRemoteModel model = new TranslateRemoteModel.Builder(languageCode).build();
        DownloadConditions conditions = new DownloadConditions.Builder()
                .requireWifi()
                .build();

        modelManager.download(model, conditions)
                .addOnSuccessListener(v -> {
                    Log.d(TAG, "Model downloaded: " + languageCode);
                    listener.onSuccess();
                })
                .addOnFailureListener(e -> {
                    Log.e(TAG, "Model download failed: " + languageCode, e);
                    listener.onError(e);
                });
    }

    public void isModelDownloaded(String languageCode, OnModelCheckListener listener) {
        TranslateRemoteModel model = new TranslateRemoteModel.Builder(languageCode).build();
        modelManager.isModelDownloaded(model)
                .addOnSuccessListener(listener::onResult)
                .addOnFailureListener(e -> listener.onResult(false));
    }

    public interface OnModelActionCompleteListener {
        void onSuccess();

        void onError(Exception e);
    }

    public interface OnModelCheckListener {
        void onResult(boolean isDownloaded);
    }
}
