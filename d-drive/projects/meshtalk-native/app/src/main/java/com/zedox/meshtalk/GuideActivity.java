package com.zedox.meshtalk;

import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.zedox.meshtalk.ai.NeuralGuideService;
import java.util.ArrayList;
import java.util.List;

public class GuideActivity extends AppCompatActivity {
    private NeuralGuideService neuralGuide;
    private RecyclerView chatHistory;
    private EditText queryInput;
    private TextView statusText;
    private ChatAdapter adapter;
    private final List<ChatMessage> messages = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_guide);

        neuralGuide = new NeuralGuideService();
        chatHistory = findViewById(R.id.aiChatHistory);
        queryInput = findViewById(R.id.aiQueryInput);
        statusText = findViewById(R.id.aiStatusText);
        ImageView backButton = findViewById(R.id.backButton);
        ImageView sendButton = findViewById(R.id.sendQueryButton);

        adapter = new ChatAdapter(messages);
        chatHistory.setLayoutManager(new LinearLayoutManager(this));
        chatHistory.setAdapter(adapter);

        backButton.setOnClickListener(v -> finish());
        sendButton.setOnClickListener(v -> handleUserQuery());

        // Initial greeting
        addMessage("Zedox Neural Guide initialized. How can I assist your mesh operation?", false);
    }

    private void handleUserQuery() {
        String query = queryInput.getText().toString().trim();
        if (query.isEmpty())
            return;

        addMessage(query, true);
        queryInput.setText("");
        statusText.setText("NEURAL LINK: PROCESSING...");

        neuralGuide.processQuery(query, new NeuralGuideService.OnSolutionListener() {
            @Override
            public void onSolutionFound(String solution) {
                runOnUiThread(() -> {
                    addMessage(solution, false);
                    statusText.setText("NEURAL LINK: STANDBY");
                });
            }

            @Override
            public void onError(Exception e) {
                runOnUiThread(() -> {
                    addMessage("Error accessing neural core. System operating in manual mode.", false);
                    statusText.setText("NEURAL LINK: OFFLINE");
                });
            }
        });
    }

    private void addMessage(String text, boolean isUser) {
        messages.add(new ChatMessage(text, isUser));
        adapter.notifyItemInserted(messages.size() - 1);
        chatHistory.smoothScrollToPosition(messages.size() - 1);
    }

    // Simple Inner Classes for Chat UI
    private static class ChatMessage {
        String text;
        boolean isUser;

        ChatMessage(String text, boolean isUser) {
            this.text = text;
            this.isUser = isUser;
        }
    }

    private static class ChatAdapter extends RecyclerView.Adapter<ChatAdapter.ViewHolder> {
        private final List<ChatMessage> messages;

        ChatAdapter(List<ChatMessage> messages) {
            this.messages = messages;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(android.R.layout.simple_list_item_1, parent,
                    false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            ChatMessage msg = messages.get(position);
            holder.text.setText((msg.isUser ? "YOU: " : "AI: ") + msg.text);
            holder.text.setTextColor(msg.isUser ? 0xFFFFFFFF : 0xFF26C1C1);
            holder.text.setPadding(0, 8, 0, 8);
        }

        @Override
        public int getItemCount() {
            return messages.size();
        }

        static class ViewHolder extends RecyclerView.ViewHolder {
            TextView text;

            ViewHolder(View v) {
                super(v);
                text = v.findViewById(android.R.id.text1);
            }
        }
    }
}
