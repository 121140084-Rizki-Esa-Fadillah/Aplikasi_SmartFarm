#ifndef FIREBASE_H
#define FIREBASE_H

#include "config.h"

void checkWiFiConnection();
// Fungsi untuk menginisialisasi Firebase
void initializeFirebase();

// Fungsi untuk memperbarui nilai threshold
void updateThresholds(FirebaseJson json);

// Fungsi untuk memperbarui jadwal pakan
void updateFeedingSchedule(FirebaseJson json);

// Fungsi untuk memperbarui konfigurasi aerator
void updateAeratorConfig(FirebaseJson json);

// Fungsi untuk mengirim data sensor ke Firebase
void sendDataToFirebase(float temperature, float salinity, float turbidity, float pH, DateTime now, bool isRaining);

// Fungsi untuk mengirim status feedEmpty ke Firebase
void sendFeedStatusToFirebase(bool feedEmpty);

// Fungsi untuk memperbaharui RTC ke FIrebase
void checkRTCUpdateFromFirebase();

#endif // FIREBASE_H
