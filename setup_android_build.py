import os
import shutil
from PIL import Image

logo = Image.open("assets/symbols/app_logo.png").convert("RGBA")

# 1. Configure Android (if present)
manifest_path = "android/app/src/main/AndroidManifest.xml"
if os.path.exists(manifest_path):
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

    if "android.permission.CAMERA" not in content:
        content = content.replace("<application", injections + "\n    <application")
    content = content.replace('android:label="genesis_speech_tab"', 'android:label="Genesis Speech Tab"')
    with open(manifest_path, "w") as f:
        f.write(content)

    # Replace all Android APK launcher icons with our custom app_logo.png
    res_dir = "android/app/src/main/res"
    if os.path.exists(res_dir):
        for folder in os.listdir(res_dir):
            if folder.startswith("mipmap-anydpi"):
                shutil.rmtree(os.path.join(res_dir, folder), ignore_errors=True)

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

# 2. Configure Windows Desktop (if present)
win_ico_path = "windows/runner/resources/app_icon.ico"
if os.path.exists("windows/runner"):
    os.makedirs(os.path.dirname(win_ico_path), exist_ok=True)
    logo.save(
        win_ico_path,
        format="ICO",
        sizes=[(256, 256), (128, 128), (64, 64), (48, 48), (32, 32), (16, 16)],
    )
    win_main_cpp = "windows/runner/main.cpp"
    if os.path.exists(win_main_cpp):
        with open(win_main_cpp, "r") as f:
            cpp = f.read()
        cpp = cpp.replace('L"genesis_speech_tab"', 'L"Genesis Speech Tab"')
        with open(win_main_cpp, "w") as f:
            f.write(cpp)
    win_cmake = "windows/CMakeLists.txt"
    if os.path.exists(win_cmake):
        with open(win_cmake, "r") as f:
            cm = f.read()
        cm = cm.replace('set(BINARY_NAME "genesis_speech_tab")', 'set(BINARY_NAME "GenesisSpeechTab")')
        with open(win_cmake, "w") as f:
            f.write(cm)
    print("Windows Desktop icon (.ico), binary name (GenesisSpeechTab.exe), and window title configured!")

# 3. Configure Linux Desktop (if present)
linux_app_cc = "linux/my_application.cc"
if os.path.exists(linux_app_cc):
    with open(linux_app_cc, "r") as f:
        cc = f.read()
    cc = cc.replace('"genesis_speech_tab"', '"Genesis Speech Tab"')
    with open(linux_app_cc, "w") as f:
        f.write(cc)
    linux_cmake = "linux/CMakeLists.txt"
    if os.path.exists(linux_cmake):
        with open(linux_cmake, "r") as f:
            cm = f.read()
        cm = cm.replace('set(BINARY_NAME "genesis_speech_tab")', 'set(BINARY_NAME "GenesisSpeechTab")')
        with open(linux_cmake, "w") as f:
            f.write(cm)
    print("Linux Desktop binary name (GenesisSpeechTab) and window title configured!")
