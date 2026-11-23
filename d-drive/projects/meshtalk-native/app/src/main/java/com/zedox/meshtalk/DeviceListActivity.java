package com.zedox.meshtalk;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.zedox.meshtalk.mesh.WiFiDirectManager;
import java.util.ArrayList;
import java.util.List;

public class DeviceListActivity extends AppCompatActivity {
    private WiFiDirectManager wifiDirectManager;
    private RecyclerView recyclerView;
    private PeerAdapter adapter;
    private List<PeerNode> peerList = new ArrayList<>();
    private View emptyState;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_device_list);

        recyclerView = findViewById(R.id.peerRecyclerView);
        emptyState = findViewById(R.id.emptyState);

        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        adapter = new PeerAdapter(peerList);
        recyclerView.setAdapter(adapter);

        findViewById(R.id.backButton).setOnClickListener(v -> finish());
        findViewById(R.id.linkDeviceButton).setOnClickListener(v -> {
            Intent intent = new Intent(DeviceListActivity.this, LinkNodeActivity.class);
            startActivity(intent);
        });

        wifiDirectManager = new WiFiDirectManager(this);
        // In a real app, we'd listen for peer changes from wifiDirectManager
        // For now, let's add a dummy discovered peer to show the UI
        simulatePeerDiscovery();
    }

    private void simulatePeerDiscovery() {
        peerList.add(new PeerNode("ZEDOX-NODE-A", "ACTIVE", "EXCELLENT"));
        peerList.add(new PeerNode("SPECTRA-NODE-03", "MESH-LINK", "GOOD"));
        adapter.notifyDataSetChanged();

        if (!peerList.isEmpty() && emptyState != null) {
            emptyState.setVisibility(View.GONE);
            recyclerView.setVisibility(View.VISIBLE);
        }
    }

    private static class PeerNode {
        String name;
        String status;
        String strength;

        PeerNode(String n, String s, String st) {
            this.name = n;
            this.status = s;
            this.strength = st;
        }
    }

    private static class PeerAdapter extends RecyclerView.Adapter<PeerAdapter.ViewHolder> {
        private final List<PeerNode> nodes;

        PeerAdapter(List<PeerNode> nodes) {
            this.nodes = nodes;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(android.R.layout.simple_list_item_2, parent,
                    false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            PeerNode node = nodes.get(position);
            holder.text1.setText(node.name);
            holder.text2.setText(node.status + " | SPECTRA: " + node.strength);
            holder.text1.setTextColor(0xFFFFFFFF);
            holder.text1.setTextColor(0xFFFFFFFF);
            holder.text2.setTextColor(0xFF4DB6AC); // Using teal_accent
        }

        @Override
        public int getItemCount() {
            return nodes.size();
        }

        static class ViewHolder extends RecyclerView.ViewHolder {
            TextView text1, text2;

            ViewHolder(View v) {
                super(v);
                text1 = v.findViewById(android.R.id.text1);
                text2 = v.findViewById(android.R.id.text2);
            }
        }
    }
}
