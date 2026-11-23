package com.zedox.meshtalk;

import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class LinkNodeActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_link_node);

        ImageView backButton = findViewById(R.id.backButton);
        backButton.setOnClickListener(v -> finish());

        // Handle Sync Code entry
        final EditText syncInput = findViewById(R.id.syncCodeInput);
        View actionBtn = findViewById(R.id.actionDescription);
        if (actionBtn != null) {
            actionBtn.setOnClickListener(v -> {
                if (syncInput == null)
                    return;
                String code = syncInput.getText().toString().trim();
                if (code.length() == 6) {
                    Toast.makeText(this, "NODE LINK INITIATED: " + code, Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(this, "INVALID SYNC CODE", Toast.LENGTH_SHORT).show();
                }
            });
        }

        // Tab switching logic (Mock)
        View optTab = findViewById(R.id.opticalTab);
        if (optTab != null)
            optTab.setOnClickListener(v -> selectTab("OPTICAL"));

        View radTab = findViewById(R.id.radioTab);
        if (radTab != null)
            radTab.setOnClickListener(v -> selectTab("RADIO"));

        View synTab = findViewById(R.id.syncTab);
        if (synTab != null)
            synTab.setOnClickListener(v -> selectTab("SYNC"));
    }

    private void selectTab(String tab) {
        // Future: Toggle visibility of pairing methods
        Toast.makeText(this, "SWITCHING TO " + tab + " PAIRING", Toast.LENGTH_SHORT).show();
    }
}
