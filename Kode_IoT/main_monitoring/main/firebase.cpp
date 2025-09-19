#include "firebase.h"
#include "config.h"
#include <addons/TokenHelper.h>

// Inisialisasi Firebase
void initializeFirebase() {
  Serial.println("Menghubungkan ke Firebase...");

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);

  delay(1000); // beri waktu koneksi stabil

  if (Firebase.ready()) {
    Serial.println("Firebase siap digunakan.");
  } else {
    Serial.println("Gagal terhubung ke Firebase.");
  }
}

// Kirim data waktu
void sendDataToFirebase(DateTime now, bool isRaining) {
  if (Firebase.ready()) {
    String path = String(FIREBASE_BASE_PATH) + "/sensor_data";
    String rtcTime = String(now.year()) + "-" + String(now.month()) + "-" + String(now.day()) + " " +
                     String(now.hour()) + ":" + String(now.minute()) + ":" + String(now.second());

    FirebaseJson json;
    json.set("rtc_time", rtcTime);
    json.set("rain_status", isRaining);

    if (Firebase.updateNode(firebaseData, path, json)) {
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
      Serial.print("Status isi pakan berhasil dikirim. feedEmpty: ");
      Serial.println(feedEmpty ? "true" : "false");
    } else {
      Serial.print("Gagal mengirim status isi pakan: ");
      Serial.println(firebaseData.errorReason());
    }
  } else {
    Serial.println("Firebase belum siap. Status pakan tidak dikirim.");
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

  bool previousStatus = forceAeratorNow;  // sebelumnya forceAeratorNow

  // Ambil status aerator (yang sekarang dikendalikan hanya dari forceAeratorNow)
  if (json.get(jsonData, "status/on")) {
    forceAeratorNow = jsonData.boolValue;

    // Deteksi perubahan dari OFF ke ON
    if (!previousStatus && forceAeratorNow) {
      Serial.println("Override: Aerator ON dari Firebase");
      aeratorOffTimestamp = rtc.now();
    }
  }

  Serial.println("Aerator Config Updated:");
  Serial.print("Aerator Delay (menit): "); Serial.println(aeratorOnMinutesAfter);
  Serial.print("Aerator Status: "); Serial.println(forceAeratorNow ? "ON" : "OFF");
}

void updateFeedingSchedule(FirebaseJson json) {
  FirebaseJsonData jsonData;
  int feedAmount = 100;

  // Ambil amount
  if (json.get(jsonData, "amount")) {
    feedAmount = jsonData.intValue;
    Serial.print("Feeding Amount: ");
    Serial.println(feedAmount);
  }

  // Ambil array schedule dari string, lalu parsing sebagai FirebaseJsonArray
  if (json.get(jsonData, "schedule")) {
    FirebaseJsonArray scheduleArray;
    scheduleArray.setJsonArrayData(jsonData.stringValue);

    for (int i = 0; i < scheduleArray.size(); i++) {
      if (scheduleArray.get(jsonData, i)) {
        String time = jsonData.stringValue;
        int hour = time.substring(0, 2).toInt();
        int minute = time.substring(3, 5).toInt();
        feedingSchedule[i] = {hour, minute, feedAmount};

        Serial.print("Feeding Schedule ");
        Serial.print(i);
        Serial.print(": ");
        Serial.print(hour);
        Serial.print(":");
        Serial.println(minute);
      } else {
        Serial.print("Gagal mendapatkan schedule index ");
        Serial.println(i);
      }
    }
  } else {
    Serial.println("Schedule array tidak ditemukan.");
  }

  // Status pakan
  if (json.get(jsonData, "status/on")) {
    forceFeedNow = jsonData.boolValue;
    Serial.print("Pakan Status: ");
    Serial.println(forceFeedNow ? "ON" : "OFF");
  }
}

bool getDataFromFirebase(float &temperature, float &salinity, float &turbidity, float &pH) {
  if (Firebase.ready()) {
    String path = String(FIREBASE_BASE_PATH) + "/sensor_data";

    if (Firebase.getJSON(firebaseData, path)) {
      FirebaseJson &json = firebaseData.jsonObject();
      FirebaseJsonData result;

      if (json.get(result, "temperature")) temperature = result.to<float>();
      if (json.get(result, "salinity")) salinity = result.to<float>();
      if (json.get(result, "turbidity")) turbidity = result.to<float>();
      if (json.get(result, "ph")) pH = result.to<float>();

      Serial.println("Data sensor berhasil dibaca dari Firebase.");
      return true;
    } else {
      Serial.print("Gagal membaca dari Firebase: ");
      Serial.println(firebaseData.errorReason());
    }
  }
  return false;
}

