#ifndef SENSOR_H
#define SENSOR_H

#include "config.h"

// Fungsi update nilai sensor
void updateTemperature();
void updatePH();
void updateSalinity();
void updateTurbidity();

float round2Decimal(float value);

#endif // SENSOR_H