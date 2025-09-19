#ifndef FIREBASE_H
#define FIREBASE_H

#include "config.h"

// Fungsi untuk menginisialisasi Firebase
void initializeFirebase();

// Fungsi untuk mengirim data sensor ke Firebase
void sendDataToFirebase(float temperature, float salinity, float turbidity, float pH);

#endif // FIREBASE_H