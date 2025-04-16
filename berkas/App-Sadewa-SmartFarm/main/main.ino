#include "config.h"
#include "sensor.h"
#include "display.h"
#include "firebase.h"
#include "data_logger.h"

void setup() {
  Serial.begin(115200);
  sensors.begin();
  lcd.begin();
  lcd.backlight();

  // Inisialisasi WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected!");

  // Inisialisasi Firebase
  initializeFirebase();

  // Stream dari path yang sesuai
  Firebase.beginStream(firebaseData, FIREBASE_BASE_PATH "/device_config/thresholds");
  Firebase.beginStream(firebaseData, FIREBASE_BASE_PATH "/device_config/aerator");
  Firebase.beginStream(firebaseData, FIREBASE_BASE_PATH "/device_config/feeding_schedule");

  // NTP & RTC
  timeClient.begin();
  timeClient.update();
  if (!rtc.begin()) {
    Serial.println("Couldn't find RTC");
    while (1);
  }
  rtc.adjust(DateTime(timeClient.getEpochTime()));

  // SD Card
  sdCardAvailable = SD.begin(CS_PIN);
  if (!sdCardAvailable) {
    Serial.println("Card failed, or not present. Please check");
  } else {
    Serial.println("SD card initialized.");
  }

  // ADC
  analogReadResolution(12);

  // Pin I/O
  pinMode(PH_SENSOR_PIN, INPUT);
  pinMode(RAIN_SENSOR_ANALOG_PIN, INPUT);
  pinMode(RAIN_SENSOR_DIGITAL_PIN, INPUT);
  pinMode(TRIGGER_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(RELAY_PIN_AERATOR, OUTPUT);
  pinMode(RELAY_PIN_PAKAN, OUTPUT);
  pinMode(DS_PIN, OUTPUT);
  pinMode(STCP_PIN, OUTPUT);
  pinMode(SHCP_PIN, OUTPUT);

  feedServo.attach(SERVO_PIN_TABUNG_PAKAN);
  digitalWrite(RELAY_PIN_AERATOR, LOW);
  digitalWrite(RELAY_PIN_PAKAN, HIGH);

  updateShiftRegister(0b00000000);

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("System Ready");
  delay(1000);
}

void loop() {
  checkWiFiConnection();

  if (Firebase.get(firebaseData, FIREBASE_BASE_PATH "/device_config/thresholds")) {
    if (firebaseData.dataType() == "json") {
      FirebaseJson json = firebaseData.jsonObject();
      updateThresholds(json);
    }
  }

  if (Firebase.get(firebaseData, FIREBASE_BASE_PATH "/device_config/feeding_schedule")) {
    if (firebaseData.dataType() == "json") {
      FirebaseJson json = firebaseData.jsonObject();
      updateFeedingSchedule(json);
    }
  }

  if (Firebase.get(firebaseData, FIREBASE_BASE_PATH "/device_config/aerator")) {
    if (firebaseData.dataType() == "json") {
      FirebaseJson json = firebaseData.jsonObject();
      updateAeratorConfig(json);
    }
  }

  DateTime now = rtc.now();
  updateTemperature();
  updatePH();
  updateSalinity();
  updateTurbidity();
  updateRainStatus();
  int rainAnalogValue = analogRead(RAIN_SENSOR_ANALOG_PIN);

  updateDisplay(rainAnalogValue, temperature, salinity, turbidity, pH, isFeeding, feedEmpty, isRaining);
  checkFeedLevel();
  handleFeeding();
  manageAerator();
  updateLEDIndicators(temperature, salinity, turbidity, pH);
  logDataIfNeeded(now, temperature, salinity, turbidity, pH, isRaining);

  // Kirim data ke Firebase
  sendDataToFirebase(temperature, salinity, turbidity, pH, now, isRaining);

  delay(5000);
}

void checkWiFiConnection() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi not connected. Attempting to reconnect...");
    WiFi.disconnect();
    WiFi.reconnect();
    delay(500);
  } else {
    Serial.println("WiFi is connected");
  }
}

String getDateTimeString(DateTime dt) {
  char buf[20];
  sprintf(buf, "%04d-%02d-%02d %02d:%02d:%02d",
          dt.year(), dt.month(), dt.day(),
          dt.hour(), dt.minute(), dt.second());
  return String(buf);
}
