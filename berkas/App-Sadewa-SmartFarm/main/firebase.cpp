#include "firebase.h"
#include "config.h"

// Inisialisasi Firebase
void initializeFirebase() {
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);

  if (Firebase.ready()) {
    Serial.println("Koneksi ke Firebase berhasil.");
  } else {
    Serial.print("Gagal terhubung ke Firebase: ");
    Serial.println(firebaseData.errorReason());
  }
}

// Kirim data sensor
void sendDataToFirebase(float temperature, float salinity, float turbidity, float pH, DateTime now, bool isRaining) {
  if (Firebase.ready()) {
    String path = String(FIREBASE_BASE_PATH) + "/sensor_data";
    String rtcTime = String(now.year()) + "-" + String(now.month()) + "-" + String(now.day()) + " " +
                     String(now.hour()) + ":" + String(now.minute()) + ":" + String(now.second());

    FirebaseJson json;
    json.set("temperature", temperature);
    json.set("salinity", salinity);
    json.set("turbidity", turbidity);
    json.set("ph", pH);
    json.set("rain_status", isRaining);
    json.set("rtc_time", rtcTime);

    if (Firebase.setJSON(firebaseData, path, json)) {
      Serial.println("Data sensor berhasil dikirim.");
    } else {
      Serial.print("Gagal mengirim data sensor: ");
      Serial.println(firebaseData.errorReason());
    }
  }
}

// Kirim status pakan
void sendFeedStatusToFirebase(bool feedEmpty) {
  if (Firebase.ready()) {
    String path = String(FIREBASE_BASE_PATH) + "/isi_pakan";

    if (Firebase.setBool(firebaseData, path, feedEmpty)) {
      Serial.println("Status isi pakan berhasil dikirim.");
    } else {
      Serial.print("Gagal mengirim status isi pakan: ");
      Serial.println(firebaseData.errorReason());
    }
  }
}

// Update thresholds
void updateThresholds(FirebaseJson json) {
  FirebaseJsonData jsonData;

  if (json.get(jsonData, "ph/high")) pHHigh = jsonData.floatValue;
  if (json.get(jsonData, "ph/low")) pHLow = jsonData.floatValue;

  if (json.get(jsonData, "salinity/high")) salinityHigh = jsonData.floatValue;
  if (json.get(jsonData, "salinity/low")) salinityLow = jsonData.floatValue;

  if (json.get(jsonData, "temperature/high")) temperatureHigh = jsonData.floatValue;
  if (json.get(jsonData, "temperature/low")) temperatureLow = jsonData.floatValue;

  if (json.get(jsonData, "turbidity/high")) turbidityHigh = jsonData.floatValue;
  if (json.get(jsonData, "turbidity/low")) turbidityLow = jsonData.floatValue;

  // Optional: print untuk debug
  Serial.println("Thresholds updated:");
  Serial.print("pH: "); Serial.print(pHLow); Serial.print(" - "); Serial.println(pHHigh);
  Serial.print("Salinity: "); Serial.print(salinityLow); Serial.print(" - "); Serial.println(salinityHigh);
  Serial.print("Temperature: "); Serial.print(temperatureLow); Serial.print(" - "); Serial.println(temperatureHigh);
  Serial.print("Turbidity: "); Serial.print(turbidityLow); Serial.print(" - "); Serial.println(turbidityHigh);
}

// Update konfigurasi aerator
void updateAeratorConfig(FirebaseJson json) {
  FirebaseJsonData jsonData;

  // Ambil delay aerator
  if (json.get(jsonData, "aerator_delay")) {
    aeratorOnMinutesAfter = jsonData.intValue;
  }

  bool previousStatus = isAeratorOn;

  // Ambil status aerator
  if (json.get(jsonData, "status/on")) {
    isAeratorOn = jsonData.boolValue;

    if (!previousStatus && isAeratorOn) {
      Serial.println("Override: Aerator ON dari Firebase");
      aeratorOffTimestamp = rtc.now();
    }
  }

  Serial.println("Aerator Config Updated:");
  Serial.print("Aerator Delay (menit): "); Serial.println(aeratorOnMinutesAfter);
  Serial.print("Aerator Status: "); Serial.println(isAeratorOn ? "ON" : "OFF");
}

// Update jadwal pakan
void updateFeedingSchedule(FirebaseJson json) {
  FirebaseJsonData jsonData;
  int feedAmount = 100;

  if (json.get(jsonData, "amount")) {
    feedAmount = jsonData.intValue;
    Serial.print("Feeding Amount: ");
    Serial.println(feedAmount);
  }

  for (int i = 0; i < 4; i++) {
    String path = "schedule/" + String(i);
    if (json.get(jsonData, path)) {
      String time = jsonData.stringValue;
      int hour = time.substring(0, 2).toInt();
      int minute = time.substring(3, 5).toInt();
      feedingSchedule[i] = {hour, minute, feedAmount};
    }
  }

  if (json.get(jsonData, "status/on")) {
    isFeeding = jsonData.boolValue;
    Serial.print("Auto Feeding Status: ");
    Serial.println(isFeeding ? "ON" : "OFF");
  }
}
