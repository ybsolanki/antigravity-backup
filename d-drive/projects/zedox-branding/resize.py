from PIL import Image
try:
    img = Image.open(r'C:\Users\EI\Pictures\zedox_server_logo_1774431338296.png')
    img.resize((64, 64)).save(r'C:\Users\EI\.gemini\antigravity\scratch\zedox-branding\server-icon.png')
    print("Resized successfully.")
except Exception as e:
    print(f"Error: {e}")
