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

  // NTP & RTC
  timeClient.begin();
  timeClient.update();

  if (!rtc.begin()) {
    Serial.println("Couldn't find RTC");
    while (1);
  }
  //int timezoneOffset = 7 * 3600;
  DateTime now = DateTime(timeClient.getEpochTime());
  rtc.adjust(now);

  // Inisialisasi Firebase
  initializeFirebase();

  // Stream dari path yang sesuai
  Firebase.beginStream(firebaseData, FIREBASE_BASE_PATH "/device_config/thresholds");
  Firebase.beginStream(firebaseData, FIREBASE_BASE_PATH "/device_config/aerator");
  Firebase.beginStream(firebaseData, FIREBASE_BASE_PATH "/device_config/feeding_schedule");

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
  Serial.println("Menunggu Firebase siap...");
  unsigned long startTime = millis();
  while (!Firebase.ready() && millis() - startTime < 10000) { // max 10 detik tunggu
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  if (Firebase.ready()) {
    Serial.println("Firebase siap digunakan.");
  } else {
    Serial.println("Timeout: Firebase belum siap. Lanjutkan ke loop dengan hati-hati.");
  }
}

void loop() {
  unsigned long startLoopTime = millis();
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
  
  unsigned long endLoopTime = millis(); // Akhir timing loop
  Serial.print("Waktu eksekusi loop: ");
  Serial.print(endLoopTime - startLoopTime);
  Serial.println(" ms");

  delay(100);
}

String getDateTimeString(DateTime dt) {
  char buf[20];
  sprintf(buf, "%04d-%02d-%02d %02d:%02d:%02d",
          dt.year(), dt.month(), dt.day(),
          dt.hour(), dt.minute(), dt.second());
  return String(buf);
}