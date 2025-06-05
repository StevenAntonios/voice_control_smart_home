
from nltk.tokenize import word_tokenize
from autocorrect import Speller
from spellchecker import SpellChecker
from transformers import AutoTokenizer, AutoModelForTokenClassification, pipeline
import nltk
from flask import Flask, request, jsonify
from flask_cors import CORS
import whisper
import os
import tempfile
import serial
import time
import wave
import pathlib
import threading
#import websocket
import json
import requests
#from langdetect import detect, LangDetectException
from nltk.tokenize import word_tokenize
import nltk
from pyarabic.araby import strip_tashkeel
from autocorrect import Speller
from spellchecker import SpellChecker
import re

app = Flask(__name__)
CORS(app)

# ✅ ESP32 Configuration
ESP_WS_IP = "ws://192.168.195.79/ws"  # ESP32 WebSocket Server
ESP_HTTP_IP = "http://192.168.195.79/control"  # ESP32 HTTP Control Endpoint

# ✅ Initialize Serial Connection to ESP32
esp = None
if os.environ.get("WERKZEUG_RUN_MAIN") == "true":
    try:
        esp = serial.Serial(port="COM9", baudrate=115200, timeout=1)
        print("✅ ESP32 connected on COM9")
    except serial.SerialException as e:
        print(f"❌ Error connecting to ESP32: {e}")

# ✅ Load Whisper Model
print("🔄 Loading Whisper model...")
model = whisper.load_model("medium")
print("✅ Whisper model loaded.")

# ✅ Download Required nltk Data
nltk.download('punkt', quiet=True)
nltk.download('punkt_tab', quiet=True)

# ✅ Store Real-Time Sensor Data
sensor_data = {"temperature": 0, "humidity": 0, "ldr": 0, "door": 0, "curtain": 0}
kitchen_data = {"light_kitchen": 0, "fan_kitchen": 0}
room_data = {"light_room": 0, "curtains_room": 0}
living_room_data = {"light1_livingRoom": 0, "light2_livingRoom": 0, "light3_livingRoom": 0, "light4_livingRoom": 0,
                    "main_door_livingRoom": 0, }
bathroom_data = {"light_bathroom": 0}

# ✅ Initialize spell checkers
spell_en = Speller(lang='en')
spell_checker_ar = SpellChecker(language='ar')

# ✅ Define Expanded Command Lists
actions_list_en = [
    "turn on", "turn off", "switch on", "switch off", "activate", "deactivate",
    "open", "close", "lock", "unlock", "increase", "decrease", "raise", "lower",
    "set", "adjust", "change", "dim", "brighten", "make brighter", "make dimmer",
    "change color to", "set brightness to", "set fan speed to", "start", "stop",
    "pause", "resume", "schedule", "set timer for", "turn on at", "turn off at",
    "enable", "disable", "sync", "connect", "show status", "check status",
    "is it on", "is it off", "good morning", "good night", "movie mode", "night mode"
]

devices_list_en = [
    "lights", "light", "leds", "lamp", "bulb", "ceiling light", "strip lights",
    "fan", "ceiling fan", "exhaust fan", "desk fan", "door", "front door",
    "main door", "back door", "garage door", "camera", "security camera", "cctv",
    "surveillance", "curtain", "blinds", "shades", "window covers"
]

rooms_list_en = [
    "living room", "hall", "lounge", "main room", "reception", "bedroom",
    "master bedroom", "guest room", "my room", "kitchen", "cooking area",
    "dining area", "bathroom", "restroom", "toilet", "washroom", "balcony",
    "terrace", "patio", "porch", "garage", "carport"
]

actions_list_ar = [
    "شغل", "أشغل", "افتح", "أفتح", "شغّل", "قم بتشغيل", "قم بإضاءة", "أطفئ",
    "اغلق", "إيقاف", "أوقف", "أغلق", "إطفاء", "وقف التشغيل", "ارفع", "خفض",
    "زود", "قلل", "زيد", "نقص", "غير", "اضبط", "عدل", "بدل", "قم بضبط",
    "قم بتعديل", "خفف", "سطع", "اجعل الإضاءة أقوى", "اجعل الإضاءة أضعف",
    "غير اللون إلى", "اضبط السطوع إلى", "اجعل السطوع", "اضبط سرعة المروحة إلى",
    "ابدأ", "أوقف", "استأنف", "استمرار", "وقف مؤقت", "اضبط مؤقت", "حدد وقت التشغيل",
    "شغل عند", "أطفئ عند", "قم بتمكين", "عطل", "اربط", "وصل", "اعرض الحالة",
    "تحقق من الحالة", "هل هو يعمل", "هل هو مغلق", "وضع النوم", "وضع السينما",
    "صباح الخير", "تصبح على خير"
]

devices_list_ar = [
    "الأضواء", "الضوء", "المصابيح", "المصباح", "اللمبات", "اللمبة", "الليدات", "نور",
    "النور", "الإضاءة", "اللمبة الذكية", "مصباح السقف", "إضاءة الشريط", "المروحة",
    "المراوح", "مروحة السقف", "المروحة الذكية", "شفاط الهواء", "مروحة الطاولة", "الباب",
    "الأبواب", "الباب الرئيسي", "باب المدخل", "الباب الأمامي", "الباب الخلفي", "باب الجراج",
    "الكاميرا", "الكاميرات", "كاميرا المراقبة", "كاميرا الأمن", "كاميرا CCTV", "المراقبة",
    "الستائر", "الستارة", "البرادي", "الشيش", "الستائر الذكية", "الغالق", "مظلة النافذة" , "ستارة" , "ستائر"
]

locations_list_ar = [
    "غرفة المعيشة", "الصالة", "الصالون", "الريسيبشن", "الريسبشن", "الغرفة الرئيسية",
    "غرفة النوم", "غرفة النوم الرئيسية", "غرفة الضيوف", "غرفتي", "حجرتي", "المطبخ",
    "المطبخ الرئيسي", "منطقة الطهي", "مكان الأكل", "غرفة الطعام", "الحمام", "دورة المياه",
    "التواليت", "المرحاض", "الحمام الرئيسي", "الشرفة", "البلكونة", "التراس", "الفناء",
    "الباحة", "المساحة الخارجية", "الكراج", "الجراج", "مكان السيارة", "الموقف"
]


def listen_to_esp():
    def on_message(ws, message):
        global sensor_data, kitchen_data, room_data, living_room_data, bathroom_data
        try:
            data = json.loads(message)

            # Update sensor data
            sensor_data.update({
                "temperature": data.get("temperature", 0),
                "humidity": data.get("humidity", 0),
                "ldr": data.get("ldr", 0),
                "door": data.get("door", 0),
                "curtain": data.get("curtain", 0)
            })

            # Update device statuses
            kitchen_data.update({
                "light_kitchen": data.get("light_kitchen", 0),
                "fan_kitchen": data.get("fan_kitchen", 0)
            })

            room_data.update({
                "light_room": data.get("light_room", 0),
                "curtains_room": data.get("curtains_room", 0)
            })

            living_room_data.update({
                "light1_livingRoom": data.get("light1_livingRoom", 0),
                "light2_livingRoom": data.get("light2_livingRoom", 0),
                "light3_livingRoom": data.get("light3_livingRoom", 0),
                "light4_livingRoom": data.get("light4_livingRoom", 0),
                "main_door_livingRoom": data.get("main_door_livingRoom", 0)
            })

            bathroom_data.update({
                "light_bathroom": data.get("light_bathroom", 0)
            })

            print(f"🔄 Updated All Statuses:")
            print(f"Kitchen: {kitchen_data}")
            print(f"Room: {room_data}")
            print(f"Living Room: {living_room_data}")
            print(f"Bathroom: {bathroom_data}")
            print(f'sensor data:{sensor_data}')
        except json.JSONDecodeError:
            print(f"❌ JSON Parsing Error: {message}")

    def on_error(ws, error):
        print(f"❌ WebSocket Error: {error}")

    def on_close(ws, close_status_code, close_msg):
        print("🔌 WebSocket Disconnected. Retrying in 5 seconds...")
        time.sleep(5)
        start_websocket_listener()

    def on_open(ws):
        print("✅ WebSocket Connected to ESP32")

    ws = websocket.WebSocketApp(ESP_WS_IP, on_message=on_message, on_error=on_error, on_close=on_close)
    ws.on_open = on_open
    ws.run_forever()


def start_websocket_listener():
    thread = threading.Thread(target=listen_to_esp, daemon=True)
    thread.start()


start_websocket_listener()  # 🔄 Start WebSocket Connection


# ✅ API Route: Get Device Status Per Room
@app.route('/get-devices-status', methods=['GET'])
def get_devices_status():
    return jsonify(device_status)


@app.route('/get-kitchen-status', methods=['GET'])
def get_light_kitchen():
    return jsonify({'light kitchen': kitchen_data.get("light_kitchen")})


def get_fan_kitchen():
    return jsonify({'fan kitchen': kitchen_data.get("fan_kitchen")})


@app.route('/get-room-status', methods=['GET'])
def get_curtains_room():
    return jsonify({'curtains room': room_data.get("curtains_room")})


def get_light_room():
    return jsonify({'light room': room_data.get("light_room")})


@app.route('/get-living-room-status', methods=['GET'])
def get_light1_living_room():
    return jsonify({'light1 living room': living_room_data.get("light1_livingRoom")})


def get_light2_living_room():
    return jsonify({'light2 living room': living_room_data.get("light2_livingRoom")})


def get_light3_living_room():
    return jsonify({'light3 living room': living_room_data.get("light3_livingRoom")})


def get_light4_living_room():
    return jsonify({'light4 living room': living_room_data.get("light4_livingRoom")})


def get_maindoor_living_room():
    return jsonify({'main door living room': living_room_data.get("main_door_livingRoom")})


@app.route('/get-bathroom-status', methods=['GET'])
def get_light_bathroom():
    return jsonify({'light bathroom': bathroom_data.get("light_bathroom")})


# # ✅ API Route: Get Temperature Data
@app.route('/get-temperature', methods=['GET'])
def get_temperature():
    return jsonify({'temperature': sensor_data.get("temperature", "No data")})


# ✅ Process English Commands (Updated)
ACTION_KEYWORDS = {
    "open": {
        "open", "unlock", "activate", "enable", "turn on", "switch on", "start",
        "schedule", "set timer for", "turn on at", "sync", "connect", "good morning",
        "movie mode", "night mode", "شغل", "أشغل", "افتح", "أفتح", "شغّل", "قم بتشغيل",
        "قم بإضاءة", "ابدأ", "استأنف", "استمرار", "حدد وقت التشغيل", "شغل عند",
        "قم بتمكين", "اربط", "وصل", "صباح الخير", "وضع السينما", "وضع النوم"
    },
    "close": {
        "close", "lock", "deactivate", "disable", "turn off", "switch off", "stop",
        "pause", "turn off at", "أطفئ", "اغلق", "إيقاف", "أوقف", "أغلق", "إطفاء",
        "وقف التشغيل", "وقف مؤقت", "أوقف", "أطفئ عند", "عطل", "اقفل","أقفل"},
    "increase": {
        "increase", "raise", "brighten", "make brighter", "set brightness to",
        "set fan speed to", "زود", "ارفع", "زيد", "اضبط السطوع إلى", "اجعل السطوع",
        "سطع", "اجعل الإضاءة أقوى", "اضبط سرعة المروحة إلى"
    },
    "decrease": {
        "decrease", "lower", "dim", "make dimmer", "قلل", "نقص", "خفض", "اخفض",
        "خفف", "اجعل الإضاءة أضعف"
    },
}

DEVICE_KEYWORDS = {
    "light": {
        "light", "lights", "lamp", "bulb", "leds", "ceiling light", "strip lights",
        "الأضواء", "الضوء", "المصابيح", "المصباح", "اللمبات", "اللمبة", "الليدات",
        "نور", "النور", "الإضاءة", "اللمبة الذكية", "مصباح السقف", "إضاءة الشريط"
    },
    "fan": {
        "fan", "ceiling fan", "exhaust fan", "desk fan", "المروحة", "المراوح", "مروحة السقف",
        "المروحة الذكية", "شفاط الهواء", "مروحة الطاولة"
    },
    "door": {
        "door", "front door", "main door", "back door", "garage door", "الباب", "الأبواب",
        "الباب الرئيسي", "باب المدخل", "الباب الأمامي", "الباب الخلفي", "باب الجراج"
    },
    "curtain": {
        "curtain", "curtains", "blinds", "shades", "window covers", "الستارة",  "ستائر", "الستائر",
        "البرادي", "الشيش", "الستائر الذكية", "الغالق", "مظلة النافذة"
    },
    "camera": {
        "camera", "security camera", "cctv", "surveillance", "الكاميرا", "الكاميرات",
        "كاميرا المراقبة", "كاميرا الأمن", "كاميرا cctv", "المراقبة"
    }
}

LOCATION_KEYWORDS = {
    "kitchen": {
        "kitchen", "cooking area", "منطقة الطهي", "المطبخ", "المطبخ الرئيسي"
    },
    "bathroom": {
        "bathroom", "restroom", "toilet", "washroom", "الحمام", "دورة المياه",
        "التواليت", "المرحاض", "الحمام الرئيسي"
    },
    "room": {
         "my room", "غرفة",  "غرفتي", "حجرتي", "guest room",
        "bedroom", "غرفة النوم", "master bedroom", "غرفة النوم الرئيسية"
    },
    "living room": {
        "living room", "hall", "lounge", "main room", "reception", "صالة", "الصالون",
        "الريسيبشن", "الريسبشن", "الغرفة الرئيسية", "غرفة الضيوف","غرفة المعيشة"
    },

}


# # ====== Normalization Helpers ======
def match_all_from_dict(text: str, keyword_dict: dict) -> list[str]:
    matches = []
    for key, variations in keyword_dict.items():
        for v in variations:
            if v in text:
                matches.append(key)
                break  # Avoid duplicates if multiple synonyms match
    return matches

# # ====== Command Processors ======
def process_english_command(command: str) -> tuple[list[str], list[str], list[str]]:
    command = re.sub(r'[^\w\s]', '', command.lower())
    print("process_english_command is : " , command)
    actions = match_all_from_dict(command, ACTION_KEYWORDS)
    devices = match_all_from_dict(command, DEVICE_KEYWORDS)
    locations = match_all_from_dict(command, LOCATION_KEYWORDS)
    print("actions is : " , actions ,"devices is : " , devices ,"locations is : " , locations )
    return actions, devices, locations

def process_arabic_command(command: str) -> tuple[list[str], list[str], list[str]]:
    command = re.sub(r'[^\w\s\u0600-\u06FF]', '', command.lower())

    actions = match_all_from_dict(command, ACTION_KEYWORDS)
    devices = match_all_from_dict(command, DEVICE_KEYWORDS)
    locations = match_all_from_dict(command, LOCATION_KEYWORDS)

    return actions, devices, locations



# ✅ API Route: Process Audio Command
@app.route('/process-command', methods=['POST'])
def handle_command():
    if 'audio' not in request.files:
        return jsonify({'error': 'No audio file provided'}), 400

    audio_file = request.files['audio']
    if audio_file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
            temp_file_path = temp_audio.name
            audio_file.save(temp_file_path)

        result = process_audio_en(temp_file_path)
        os.remove(temp_file_path)

        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/process-command-ar', methods=['POST'])
def handle_command_ar():
    if 'audio' not in request.files:
        return jsonify({'error': 'No audio file provided'}), 400

    audio_file = request.files['audio']
    if audio_file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
            temp_file_path = temp_audio.name
            audio_file.save(temp_file_path)

        result = process_audio_ar(temp_file_path)
        os.remove(temp_file_path)

        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# ✅ Process Audio and Extract Commands
def process_audio_en(file_path):
    print(f"🔍 Processing file: {file_path}")

    if not os.path.exists(file_path):
        print("❌ Error: File not found!")
        return {'error': 'File not found'}

    try:
        # ✅ Transcribe audio using Whisper
        start_time1 = time.time()
        result = model.transcribe(file_path, language="en")
        transcribed_text = result.get('text', '').strip()
        end_time1 = time.time()
        print("the time that wisper take is : ",round(end_time1-start_time1) )
        start_time2 = time.time()
        if not transcribed_text:
            print("⚠ Warning: Whisper did not return any text!")
            return {'error': 'No speech detected'}

        print(f"📝 Transcribed Text: {transcribed_text}")

        # ✅ Split the transcribed text into multiple commands (assuming ',' or 'and' separate commands)
        commands = transcribed_text.lower().replace(" and ", ",").split(",")

        sent_commands = []
        esp_responses = []

        for command in commands:
            command = command.strip()
            tokens = word_tokenize(command)
            corrected_tokens = [spell_en(t) for t in tokens]

            actions,devices,rooms  = process_english_command(" ".join(corrected_tokens))

            if not actions or not devices:
                print(f"⚠ Warning: Invalid command detected - {command}")
                continue  # Skip invalid commands

            location = rooms[0] if rooms else ""
            command_to_esp = f"{actions[0]} {devices[0]} {location}".strip() 
            print(f"🚀 Sending to ESP32: {command_to_esp}")

            response = send_command_to_esp(command_to_esp)

            sent_commands.append(command_to_esp)
            esp_responses.append(response)
        end_time2 = time.time()
        print("the time that nlp take is : ", round(end_time2 -start_time2 ))

        return {
            'text': transcribed_text,
            'sent_commands': sent_commands,
            'esp_responses': esp_responses
        }


    except Exception as e:
        return {'error': str(e)}

bert_model = "UBC-NLP/MARBERTv2"
tokenizer = AutoTokenizer.from_pretrained(bert_model)
model_bert = AutoModelForTokenClassification.from_pretrained(bert_model)
ner_pipeline = pipeline("ner", model=model_bert, tokenizer=tokenizer)

def process_audio_ar(file_path):
    print(f"🔍 Processing file: {file_path}")

    if not os.path.exists(file_path):
        print("❌ Error: File not found!")
        return {'error': 'File not found'}

    try:
        # ⏱ Start Whisper timing
        start_time1 = time.time()
        result = model.transcribe(file_path, language="ar")
        end_time1 = time.time()
        transcribed_text = result.get('text', '').strip()

        print("🕐 Whisper Time:", round(end_time1 - start_time1, 3), "sec")

        # ⏱ Start NLP timing
        start_time2 = time.time()

        if not transcribed_text:
            print("⚠ Warning: Whisper did not return any text!")
            return {'error': 'No speech detected'}

        print(f"📝 Transcribed Text: {transcribed_text}")

        # 🧠 MARBERT Named Entity Recognition
        ner_results = ner_pipeline(transcribed_text)
        print("🔍 MARBERT NER Results:", ner_results)

        entities = [entity['word'] for entity in ner_results if entity['score'] > 0.95]
        print(f"✨ Detected Entities: {entities}")

        # ✅ Split multiple commands
        commands = transcribed_text.replace(" و ", ",").replace("،", ",").split(",")

        sent_commands = []
        esp_responses = []

        for command in commands:
            command = command.strip()
            if not command:
                continue

            tokens = word_tokenize(command)
            corrected_tokens = [spell_checker_ar.correction(t) for t in tokens]

            actions, devices, rooms = process_arabic_command(" ".join(corrected_tokens))

            if not actions or not devices:
                print(f"⚠ Skipping invalid command: {command}")
                continue

            location = rooms[0] if rooms else ""
            command_to_esp = f"{actions[0]} {devices[0]} {location}".strip()
            print(f"🚀 Sending to ESP32: {command_to_esp}")

            response = send_command_to_esp(command_to_esp)

            sent_commands.append(command_to_esp)
            esp_responses.append(response)

        end_time2 = time.time()
        print("🕐 NLP Time:", round(end_time2 - start_time2, 3), "sec")

        return {
            'text': transcribed_text,
            'entities': entities,
            'sent_commands': sent_commands,
            'esp_responses': esp_responses,
            'whisper_time_sec': round(end_time1 - start_time1, 3),
            'nlp_time_sec': round(end_time2 - start_time2, 3)
        }

    except Exception as e:
        print(f"❌ Error: {e}")
        return {'error': str(e)}

# ✅ Send HTTP Command to ESP32
def send_command_to_esp(command):
    try:
        response = requests.get(ESP_HTTP_IP, params={"command": command})
        return response.text
    except Exception as e:
        return "Failed to send command"


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)