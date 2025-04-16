#ifndef SENSOR_H
#define SENSOR_H

#include "config.h"

// Fungsi update nilai sensor
void updateTemperature();
void updatePH();
void updateSalinity();
void updateTurbidity();
void updateRainStatus();

// Fungsi feeder
void handleFeeding();
void activateFeeder(int duration);
void deactivateFeeder();
void checkFeedLevel();

// Fungsi aerator
void manageAerator();
void activateAerator();
void deactivateAerator();

// Fungsi tambahan
int readUltrasonicDistance();

#endif // SENSOR_H
