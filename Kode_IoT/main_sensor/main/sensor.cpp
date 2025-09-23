#include "sensor.h"
#include "firebase.h"
#include "config.h"

float round2Decimal(float value) {
  return roundf(value * 100) / 100.0;
}

void updateTemperature() {
  sensors.requestTemperatures();
  temperature = round2Decimal(sensors.getTempCByIndex(0));

  Serial.println();
  Serial.print("temperature: "); Serial.println(temperature);
}

void updatePH() {
  float totalVoltage = 0;
  int numSamples = 10;

  for (int i = 0; i < numSamples; i++) {
    int sensorValue = analogRead(PH_SENSOR_PIN);
    totalVoltage += sensorValue * (3.3 / 4095.0);
    delay(300);
  }
  
  float tegangan_pH = totalVoltage / numSamples;

  // Kalibrasi berdasarkan regresi linear
  pH = -10.31 * tegangan_pH + 13.25;

  // Batasi ke rentang 0 - 14
  if (pH < 0) pH = 0;
  if (pH > 14) pH = 14;

  pH = round2Decimal(pH);

  Serial.print("pH Value: "); Serial.print(pH, 2);
  Serial.print(" | pH Voltage: "); Serial.println(tegangan_pH, 3);
}


void updateSalinity() {
  float totalVoltage = 0;
  int numSamples = 10;

  for (int i = 0; i < numSamples; i++) {
    int analogValueEC = analogRead(SALINITY_PIN);
    totalVoltage += analogValueEC * (vRef / ADC_RESOLUTION);
    delay(300);
  }

  float voltageEC = totalVoltage / numSamples;
  float compensatedVoltageEC = voltageEC / (1 + temperatureCompensation * (temperature - 25));

  // Kalibrasi berdasarkan dua titik data
  salinity = 33.23 * compensatedVoltageEC - 13.96;

  if (salinity < 0) salinity = 0;
  salinity = round2Decimal(salinity);

  Serial.print("Salinity (ppt): "); Serial.print(salinity, 2);
  Serial.print(" | Raw Voltage: "); Serial.print(voltageEC, 3);
  Serial.print(" | Compensated V: "); Serial.println(compensatedVoltageEC, 3);
}

void updateTurbidity() {
  float totalVoltage = 0;
  int numSamples = 10;

  for (int i = 0; i < numSamples; i++) {
    int turbidityValue = analogRead(TURBIDITY_SENSOR_PIN);
    totalVoltage += turbidityValue * (V_REF / ADC_RESOLUTION);
    delay(300);
  }

  float turbidityVoltage = totalVoltage / numSamples;

  // Kalibrasi linear dari dua titik
  turbidity = -238.42 * turbidityVoltage + 394.32;

  turbidity = round2Decimal(turbidity);
  if (turbidity < 0) turbidity = 0;
  if (turbidity > 1000) turbidity = 1000;

  Serial.print("Turbidity (NTU): "); Serial.print(turbidity);
  Serial.print(" | Voltage: "); Serial.println(turbidityVoltage, 3);
  Serial.println();
}
