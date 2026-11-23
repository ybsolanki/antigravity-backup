package com.zedox.meshtalk;

import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import com.google.zxing.BarcodeFormat;
import com.journeyapps.barcodescanner.BarcodeEncoder;

public class ProfileActivity extends AppCompatActivity {
    private TextView nodeNameText;
    private ImageView qrCodeImage;
    private SharedPreferences prefs;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);

        prefs = getSharedPreferences("MeshTalkPrefs", MODE_PRIVATE);
        nodeNameText = findViewById(R.id.nodeNameText);
        qrCodeImage = findViewById(R.id.profileQRCode);

        // Load saved name
        String savedName = prefs.getString("node_name", "ZedoxNode");
        nodeNameText.setText(savedName);

        findViewById(R.id.backButton).setOnClickListener(v -> finish());

        findViewById(R.id.updateIdButton).setOnClickListener(v -> showNameEditDialog());

        findViewById(R.id.pairingButton).setOnClickListener(v -> {
            Intent intent = new Intent(ProfileActivity.this, ScannerActivity.class);
            startActivity(intent);
        });

        findViewById(R.id.viewPeersButton).setOnClickListener(v -> {
            Intent intent = new Intent(ProfileActivity.this, DeviceListActivity.class);
            startActivity(intent);
        });

        generateUserQR();
    }

    private void showNameEditDialog() {
        final EditText input = new EditText(this);
        input.setHint("Enter Node Name");
        input.setText(nodeNameText.getText());
        input.setPadding(64, 32, 64, 32);

        new AlertDialog.Builder(this, android.R.style.Theme_DeviceDefault_Dialog_Alert)
                .setTitle("Update Node Identity")
                .setView(input)
                .setPositiveButton("UPDATE", (dialog, which) -> {
                    String newName = input.getText().toString().trim();
                    if (!newName.isEmpty()) {
                        prefs.edit().putString("node_name", newName).apply();
                        nodeNameText.setText(newName);
                        generateUserQR();
                    }
                })
                .setNegativeButton("CANCEL", null)
                .show();
    }

    private void generateUserQR() {
        String name = nodeNameText.getText().toString();
        String qrContent = "ZEDOX|" + name + "|" + System.currentTimeMillis();

        try {
            BarcodeEncoder barcodeEncoder = new BarcodeEncoder();
            Bitmap bitmap = barcodeEncoder.encodeBitmap(qrContent, BarcodeFormat.QR_CODE, 400, 400);
            qrCodeImage.setImageBitmap(bitmap);
            qrCodeImage.setPadding(0, 0, 0, 0); // Remove placeholder padding
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
