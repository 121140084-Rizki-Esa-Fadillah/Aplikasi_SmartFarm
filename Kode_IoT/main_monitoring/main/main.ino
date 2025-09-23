#include "config.h"
#include "aktuator.h"
#include "display.h"
#include "firebase.h" 
#include "data_logger.h"

void setup() {
  Serial.begin(115200);
  
  lcd.begin();
  lcd.backlight();

  // Inisialisasi WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi terhubung");
  Serial.println("IP Address: " + WiFi.localIP().toString());

  // NTP & RTC
  timeClient.begin();
  delay(1000);  // Memberi waktu untuk inisialisasi

  Serial.println("Sinkronisasi waktu NTP...");
  bool ntpUpdated = false;
  for (int i = 0; i < 10; i++) {
    if (timeClient.update()) {
      ntpUpdated = true;
      break;
    }
    Serial.print(".");
    delay(500);
  }

  rtcAvailable = rtc.begin();   // cek apakah RTC tersedia

  if (!rtcAvailable) {
    Serial.println("RTC tidak terdeteksi! Sistem akan gunakan NTP langsung.");
  }

  if (ntpUpdated) {
    time_t epochTime = timeClient.getEpochTime();
    if (epochTime > 1600000000UL) {  // validasi tahun > 2020
      DateTime now = DateTime(epochTime);
      rtc.adjust(now);
      Serial.print("RTC disetel ke: ");
      Serial.println(getDateTimeString(now));
    } else {
      Serial.println("Waktu NTP tidak valid.");
    }
  } else {
    Serial.println("Gagal sinkronisasi waktu NTP.");
  }

  // SD Card
  initSDCard();

  // Inisialisasi Firebase
  initializeFirebase();
  Firebase.beginStream(firebaseData, FIREBASE_BASE_PATH "/device_config/thresholds");
  Firebase.beginStream(firebaseData, FIREBASE_BASE_PATH "/device_config/aerator");
  Firebase.beginStream(firebaseData, FIREBASE_BASE_PATH "/device_config/feeding_schedule");

  // ADC
  analogReadResolution(12);

  // Pin I/O
  pinMode(TRIGGER_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(RELAY_PIN_AERATOR, OUTPUT);
  pinMode(RELAY_PIN_PAKAN, OUTPUT);

  feedServo.attach(SERVO_PIN_TABUNG_PAKAN);
  digitalWrite(RELAY_PIN_AERATOR, LOW);
  digitalWrite(RELAY_PIN_PAKAN, HIGH);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("System Ready");
}

void loop() {
  if (Firebase.get(firebaseData, FIREBASE_BASE_PATH "/device_config/thresholds")) {
    if (firebaseData.dataType() == "json") {
      FirebaseJson json = firebaseData.jsonObject();
      updateThresholds(json);
    }
  }

  if (Firebase.get(firebaseData, FIREBASE_BASE_PATH "/device_config/feeding_schedule")) {
    if (firebaseData.dataType() == "json") {
      Serial.println("Received update for /device_config/feeding_schedule");
      FirebaseJson json = firebaseData.jsonObject();
      updateFeedingSchedule(json);
    } else {
      Serial.println("Data for /device_config/feeding_schedule is not JSON.");
    }
  } else {
    Serial.print("Failed to get /device_config/feeding_schedule: ");
    Serial.println(firebaseData.errorReason());
  }

  if (Firebase.get(firebaseData, FIREBASE_BASE_PATH "/device_config/aerator")) {
    if (firebaseData.dataType() == "json") {
      FirebaseJson json = firebaseData.jsonObject();
      updateAeratorConfig(json);
    }
  }

  DateTime now;
  if (rtcAvailable) {
    now = rtc.now();
  } else {
    time_t epochTime = timeClient.getEpochTime();
    now = DateTime(epochTime);
  }

  Serial.print("Waktu sekarang: ");
  Serial.println(getDateTimeString(now));

  updateRainStatus();
  sendDataToFirebase(now, isRaining);
  getDataFromFirebase(temperature, salinity, turbidity, pH);
  updateDisplay(rainAnalogValue, temperature, salinity, turbidity, pH, isFeeding, feedEmpty, isRaining);
  checkFeedLevel();
  handleFeeding();
  manageAerator();
  CreatelogData(now, temperature, salinity, turbidity, pH, isRaining);

  delay(100);
}

String getDateTimeString(DateTime dt) {
  char buf[20];
  sprintf(buf, "%04d-%02d-%02d %02d:%02d:%02d",
          dt.year(), dt.month(), dt.day(),
          dt.hour(), dt.minute(), dt.second());
  return String(buf);
}
