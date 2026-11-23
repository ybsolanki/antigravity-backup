import asyncio
import edge_tts
import os

AUDIO_DIR = r"C:\Users\EI\.gemini\antigravity\scratch\vishvarupa_animation\audio"
os.makedirs(AUDIO_DIR, exist_ok=True)

# Hindi Voice Actors
# hi-IN-MadhurNeural for Krishna and Arjuna with different pitch/rate settings
DIALOGUES = [
    {
        "filename": "arjuna_line_1.mp3",
        "text": "माधव... मैं आपको अपना सखा जानता हूँ। पर आप स्वयं को हर सृष्टि का स्रोत बताते हैं... यदि यही सत्य है, तो मुझे अपना दिव्य स्वरूप देखने दें।",
        "voice": "hi-IN-MadhurNeural",
        "rate": "-5%",
        "pitch": "+5Hz"
    },
    {
        "filename": "krishna_line_1.mp3",
        "text": "तुम सत्य देखना चाहते हो, पार्थ? तो फिर इन चर्मचक्षुओं से परे देखो... जो केवल मैं तुम्हें दिखा सकता हूँ।",
        "voice": "hi-IN-MadhurNeural",
        "rate": "-10%",
        "pitch": "-10Hz"
    },
    {
        "filename": "krishna_line_2.mp3",
        "text": "देखो... मेरे भीतर ही वो सब है जो था... जो है... और जो सदैव रहेगा।",
        "voice": "hi-IN-MadhurNeural",
        "rate": "-15%",
        "pitch": "-12Hz"
    },
    {
        "filename": "arjuna_line_2.mp3",
        "text": "मैं आकाश... पृथ्वी... और समूचे ब्रह्मांड को आपके भीतर देख रहा हूँ... सब कुछ आप ही में है!",
        "voice": "hi-IN-MadhurNeural",
        "rate": "-5%",
        "pitch": "+8Hz"
    },
    {
        "filename": "krishna_line_3.mp3",
        "text": "उठो, पार्थ। भय को त्यागो और अपने धर्म का पालन करो।",
        "voice": "hi-IN-MadhurNeural",
        "rate": "-12%",
        "pitch": "-10Hz"
    }
]

async def generate_all():
    for item in DIALOGUES:
        filepath = os.path.join(AUDIO_DIR, item["filename"])
        communicate = edge_tts.Communicate(
            text=item["text"],
            voice=item["voice"],
            rate=item["rate"],
            pitch=item["pitch"]
        )
        await communicate.save(filepath)
        print(f"Generated: {item['filename']}")

if __name__ == "__main__":
    asyncio.run(generate_all())
