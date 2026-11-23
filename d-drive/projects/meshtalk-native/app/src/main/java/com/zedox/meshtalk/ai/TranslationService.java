package com.zedox.meshtalk.ai;

import com.google.mlkit.nl.translate.TranslateLanguage;
import com.google.mlkit.nl.translate.Translation;
import com.google.mlkit.nl.translate.Translator;
import com.google.mlkit.nl.translate.TranslatorOptions;

public class TranslationService {
    private LanguageManager languageManager;

    public TranslationService() {
        this.languageManager = new LanguageManager();
    }

    public void translateMessage(String text, String sourceLang, String targetLang,
            OnTranslationCompleteListener listener) {
        languageManager.isModelDownloaded(sourceLang, sourceDownloaded -> {
            languageManager.isModelDownloaded(targetLang, targetDownloaded -> {
                if (sourceDownloaded && targetDownloaded) {
                    performTranslation(text, sourceLang, targetLang, listener);
                } else {
                    listener.onError(new Exception("Models not downloaded for offline use"));
                }
            });
        });
    }

    private void performTranslation(String text, String sourceLang, String targetLang,
            OnTranslationCompleteListener listener) {
        TranslatorOptions options = new TranslatorOptions.Builder()
                .setSourceLanguage(sourceLang)
                .setTargetLanguage(targetLang)
                .build();

        final Translator translator = Translation.getClient(options);

        translator.translate(text)
                .addOnSuccessListener(translatedText -> {
                    listener.onSuccess(translatedText);
                    translator.close();
                })
                .addOnFailureListener(e -> {
                    listener.onError(e);
                    translator.close();
                });
    }

    public void downloadLanguage(String languageCode, LanguageManager.OnModelActionCompleteListener listener) {
        languageManager.downloadModel(languageCode, listener);
    }

    public interface OnTranslationCompleteListener {
        void onSuccess(String translatedText);

        void onError(Exception e);
    }
}
