package com.zedox.meshtalk;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.view.View;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Button startMeshButton = findViewById(R.id.startMeshButton);
        Button openChatButton = findViewById(R.id.openChatButton);
        ImageView profileButton = findViewById(R.id.profileButton);

        if (startMeshButton != null) {
            startMeshButton.setOnClickListener(v -> {
                Intent intent = new Intent(MainActivity.this, DeviceListActivity.class);
                startActivity(intent);
            });
        }

        if (openChatButton != null) {
            openChatButton.setOnClickListener(v -> {
                Intent intent = new Intent(MainActivity.this, ChatActivity.class);
                startActivity(intent);
            });
        }

        if (profileButton != null) {
            profileButton.setOnClickListener(v -> {
                Intent intent = new Intent(MainActivity.this, ProfileActivity.class);
                startActivity(intent);
            });
        }

        View gridHealthButton = findViewById(R.id.gridHealthButton);
        if (gridHealthButton != null) {
            gridHealthButton.setOnClickListener(v -> {
                Intent intent = new Intent(MainActivity.this, GridHealthActivity.class);
                startActivity(intent);
            });
        }

        View openGuideButton = findViewById(R.id.openGuideButton);
        if (openGuideButton != null) {
            openGuideButton.setOnClickListener(v -> {
                Intent intent = new Intent(MainActivity.this, GuideActivity.class);
                startActivity(intent);
            });
        }

        updateIdentityLabel();
    }

    @Override
    protected void onResume() {
        super.onResume();
        updateIdentityLabel();
    }

    private void updateIdentityLabel() {
        TextView identityLabel = findViewById(R.id.radioIdentityLabel);
        if (identityLabel != null) {
            SharedPreferences prefs = getSharedPreferences("MeshTalkPrefs", MODE_PRIVATE);
            String name = prefs.getString("node_name", "ZedoxNode").toUpperCase();
            identityLabel.setText(name + "-9835");
        }
    }
}
