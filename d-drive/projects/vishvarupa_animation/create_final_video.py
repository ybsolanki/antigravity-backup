import os
import glob
from PIL import Image, ImageDraw, ImageFont
import numpy as np
from moviepy import ImageClip, AudioFileClip, CompositeVideoClip, CompositeAudioClip, ColorClip

IMAGE_DIR = r"C:\Users\EI\.gemini\antigravity\brain\13d52481-d3c4-4476-8133-e31dba6b63cb"
AUDIO_DIR = r"C:\Users\EI\.gemini\antigravity\scratch\vishvarupa_animation\audio"
OUTPUT_MP4 = r"C:\Users\EI\.gemini\antigravity\scratch\vishvarupa_animation\VISHVARUPA_42s_ANIMATED_ENTRY.mp4"

def find_image(prefix):
    matches = glob.glob(os.path.join(IMAGE_DIR, f"{prefix}_*.jpg"))
    return matches[0] if matches else None

img_scene1 = find_image("scene_1_battlefield")
img_scene2 = find_image("scene_2_arjuna_asks")
img_scene3 = find_image("scene_3_krishna_answers")
img_scene4 = find_image("scene_4_transformation_begins")
img_scene5 = find_image("hero_vishvarupa_ref")
img_scene6 = find_image("scene_6_arjuna_realization")
img_scene7 = img_scene5

SHOTS = [
    {"img": img_scene1, "duration": 5.0, "audio": None},
    {"img": img_scene2, "duration": 5.0, "audio": os.path.join(AUDIO_DIR, "arjuna_line_1.mp3")},
    {"img": img_scene3, "duration": 5.0, "audio": os.path.join(AUDIO_DIR, "krishna_line_1.mp3")},
    {"img": img_scene4, "duration": 6.0, "audio": os.path.join(AUDIO_DIR, "krishna_line_2.mp3")},
    {"img": img_scene5, "duration": 10.0, "audio": os.path.join(AUDIO_DIR, "arjuna_line_2.mp3")},
    {"img": img_scene6, "duration": 5.0, "audio": None},
    {"img": img_scene7, "duration": 4.0, "audio": os.path.join(AUDIO_DIR, "krishna_line_3.mp3")},
]

clips = []
audio_clips = []
current_time = 0.0

for shot in SHOTS:
    img_path = shot["img"]
    dur = shot["duration"]
    
    # Load image clip and resize to 1920x1080
    clip = ImageClip(img_path).with_duration(dur).resized((1920, 1080))
    clip = clip.with_start(current_time)
    clips.append(clip)
    
    if shot["audio"] and os.path.exists(shot["audio"]):
        a_clip = AudioFileClip(shot["audio"]).with_start(current_time + 0.5)
        audio_clips.append(a_clip)
        
    current_time += dur

# Title Card (2s black screen with title)
title_bg = ColorClip(size=(1920, 1080), color=(0, 0, 0)).with_duration(2.0).with_start(current_time)
clips.append(title_bg)

# Combine video & audio
video = CompositeVideoClip(clips)
if audio_clips:
    final_audio = CompositeAudioClip(audio_clips)
    video = video.with_audio(final_audio)

print("Rendering final MP4 video...")
video.write_videofile(OUTPUT_MP4, fps=24, codec="libx264", audio_codec="aac")
print(f"COMPLETE! Video saved at: {OUTPUT_MP4}")
