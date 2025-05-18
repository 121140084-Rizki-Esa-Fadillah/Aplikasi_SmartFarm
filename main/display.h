#ifndef DISPLAY_H
#define DISPLAY_H

#include "config.h"

// Fungsi tampilan utama
void updateDisplay(float rainAnalogValue, float temperature, float salinity, float turbidity, float pH,
                   bool isFeeding, bool feedEmpty, bool isRaining);

// Fungsi tampilan detail (jika memang mau digunakan dari luar)
void showSensorData(float temperature, float salinity, float turbidity, float pH);
void showRainStatus(float rainAnalogValue);
void showFeedWarning();

void updateLEDIndicators(float temperature, float salinity, float turbidity, float pH);
void updateShiftRegister(byte data);

#endif // DISPLAY_H
