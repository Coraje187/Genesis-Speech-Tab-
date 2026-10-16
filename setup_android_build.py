import os
import shutil
from PIL import Image

manifest_path = "android/app/src/main/AndroidManifest.xml"
with open(manifest_path, "r") as f:
    content = f.read()

injections = """
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <queries>
        <intent>
            <action android:name="android.intent.action.TTS_SERVICE" />
        </intent>
        <package android:name="com.ivona.tts.oem" />
        <package android:name="com.google.android.tts" />
    </queries>
"""

content = content.replace("<application", injections + "\n    <application")
content = content.replace('android:label="genesis_speech_tab"', 'android:label="Genesis Speech Tab"')
with open(manifest_path, "w") as f:
    f.write(content)

# Replace all Android APK launcher icons with our custom app_logo.png
res_dir = "android/app/src/main/res"
for folder in os.listdir(res_dir):
    if folder.startswith("mipmap-anydpi"):
        shutil.rmtree(os.path.join(res_dir, folder), ignore_errors=True)

logo = Image.open("assets/symbols/app_logo.png").convert("RGBA")
sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
for folder, px in sizes.items():
    target_dir = os.path.join(res_dir, folder)
    os.makedirs(target_dir, exist_ok=True)
    resized = logo.resize((px, px), Image.Resampling.LANCZOS)
    resized.save(os.path.join(target_dir, "ic_launcher.png"), "PNG")
    resized.save(os.path.join(target_dir, "ic_launcher_round.png"), "PNG")

print("Android manifest and custom APK launcher icons configured successfully!")
