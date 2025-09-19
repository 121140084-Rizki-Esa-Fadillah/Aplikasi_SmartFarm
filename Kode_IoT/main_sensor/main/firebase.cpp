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

// Kirim data sensor
void sendDataToFirebase(float temperature, float salinity, float turbidity, float pH) {
  if (Firebase.ready()) {
    String path = String(FIREBASE_BASE_PATH) + "/sensor_data";

    FirebaseJson json;
    json.set("temperature", temperature);
    json.set("salinity", salinity);
    json.set("turbidity", turbidity);
    json.set("ph", pH);

    if (Firebase.updateNode(firebaseData, path, json)) {
      Serial.println("Data sensor berhasil dikirim.");
    } else {
      Serial.print("Gagal mengirim data sensor: ");
      Serial.println(firebaseData.errorReason());
    }
  }
}
