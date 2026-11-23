package com.zedox.meshtalk;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.zedox.meshtalk.ai.TranslationService;
import com.zedox.meshtalk.models.Message;
import java.util.ArrayList;
import java.util.List;

public class ChatActivity extends AppCompatActivity {
    private RecyclerView recyclerView;
    private EditText messageInput;
    private ImageView sendButton;
    private MessageAdapter adapter;
    private List<Message> messageList = new ArrayList<>();

    private Button broadcastToggle, privateLinkToggle;
    private TextView languageText;
    private boolean isPrivateMode = false;
    private String currentLanguage = "ENGLISH";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);

        recyclerView = findViewById(R.id.chatRecyclerView);
        messageInput = findViewById(R.id.messageInput);
        sendButton = findViewById(R.id.sendButton);
        broadcastToggle = findViewById(R.id.broadcastToggle);
        privateLinkToggle = findViewById(R.id.privateLinkToggle);
        languageText = findViewById(R.id.languageText);

        if (recyclerView != null) {
            adapter = new MessageAdapter(messageList);
            recyclerView.setLayoutManager(new LinearLayoutManager(this));
            recyclerView.setAdapter(adapter);
        }

        if (sendButton != null) {
            sendButton.setOnClickListener(v -> sendMessage());
        }

        findViewById(R.id.backButton).setOnClickListener(v -> finish());

        if (broadcastToggle != null) {
            broadcastToggle.setOnClickListener(v -> setChatMode(false));
        }

        if (privateLinkToggle != null) {
            privateLinkToggle.setOnClickListener(v -> setChatMode(true));
        }

        findViewById(R.id.languageButton).setOnClickListener(v -> toggleLanguage());
        findViewById(R.id.deleteChatButton).setOnClickListener(v -> clearChat());
    }

    private void setChatMode(boolean privateMode) {
        this.isPrivateMode = privateMode;
        if (privateMode) {
            privateLinkToggle.setBackgroundResource(R.drawable.btn_rounded_orange);
            privateLinkToggle.setTextColor(getResources().getColor(R.color.white));
            broadcastToggle.setBackgroundResource(R.drawable.btn_rounded_dark);
            broadcastToggle.setTextColor(getResources().getColor(R.color.text_secondary));
            Toast.makeText(this, "SWITCHED TO PRIVATE LINK", Toast.LENGTH_SHORT).show();
        } else {
            broadcastToggle.setBackgroundResource(R.drawable.btn_rounded_orange);
            broadcastToggle.setTextColor(getResources().getColor(R.color.white));
            privateLinkToggle.setBackgroundResource(R.drawable.btn_rounded_dark);
            privateLinkToggle.setTextColor(getResources().getColor(R.color.text_secondary));
            Toast.makeText(this, "SWITCHED TO MESH BROADCAST", Toast.LENGTH_SHORT).show();
        }
    }

    private void toggleLanguage() {
        if (currentLanguage.equals("ENGLISH")) {
            currentLanguage = "HINDI";
        } else {
            currentLanguage = "ENGLISH";
        }
        languageText.setText(currentLanguage);
        Toast.makeText(this, "TRANSLATION: " + currentLanguage, Toast.LENGTH_SHORT).show();
    }

    private void clearChat() {
        messageList.clear();
        adapter.notifyDataSetChanged();
        findViewById(R.id.noTrafficText).setVisibility(View.VISIBLE);
    }

    private void sendMessage() {
        String content = messageInput.getText().toString().trim();
        if (content.isEmpty())
            return;

        findViewById(R.id.noTrafficText).setVisibility(View.GONE);

        Message msg = new Message(
                String.valueOf(System.currentTimeMillis()),
                "ME",
                isPrivateMode ? "PRIVATE" : "BROADCAST",
                content,
                false);

        messageList.add(msg);
        adapter.notifyItemInserted(messageList.size() - 1);
        recyclerView.smoothScrollToPosition(messageList.size() - 1);
        messageInput.setText("");
    }

    private static class MessageAdapter extends RecyclerView.Adapter<MessageAdapter.ViewHolder> {
        private final List<Message> messages;

        MessageAdapter(List<Message> messages) {
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
            Message msg = messages.get(position);
            holder.text.setText(msg.getContent());
            holder.text.setTextColor(0xFFFFFFFF);
            holder.text.setPadding(32, 16, 32, 16);
            if (msg.getSenderId().equals("ME")) {
                holder.text.setGravity(android.view.Gravity.END);
            } else {
                holder.text.setGravity(android.view.Gravity.START);
            }
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
