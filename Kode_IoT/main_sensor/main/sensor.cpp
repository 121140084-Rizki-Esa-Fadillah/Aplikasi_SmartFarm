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
    delay(100);
  }
  
  float tegangan_pH = totalVoltage / numSamples;

  // Kalibrasi berdasarkan regresi linear
  pH = round2Decimal(-6.0 * tegangan_pH + 22.0);

  Serial.print("pH Value: "); Serial.print(pH, 2);
  Serial.print(" | pH Voltage: "); Serial.println(tegangan_pH, 3);
}

void updateSalinity() {
  int analogValueEC = analogRead(SALINITY_PIN);
  float voltageEC = analogValueEC * (vRef / ADC_RESOLUTION);
  float compensatedVoltageEC = voltageEC / (1 + temperatureCompensation * (temperature - 25));

  // Kalibrasi baru berdasarkan dua titik data
  salinity = 29.58 * compensatedVoltageEC - 23.75;
  if (salinity < 0) salinity = 0;
  salinity = round2Decimal(salinity);

  Serial.print("Salinity (ppt): "); Serial.print(salinity, 2);
  Serial.print(" | Raw Voltage: "); Serial.print(voltageEC, 3);
  Serial.print(" | Compensated V: "); Serial.println(compensatedVoltageEC, 3);
}

void updateTurbidity() {
  int turbidityValue = analogRead(TURBIDITY_SENSOR_PIN);

  float turbidityVoltage = turbidityValue * (V_REF / ADC_RESOLUTION);

  // Kalibrasi linear dari dua titik
  turbidity = -123.82 * turbidityVoltage + 195.94;

  turbidity = round2Decimal(turbidity);
  if (turbidity < 0) turbidity = 0;
  if (turbidity > 100) turbidity = 100;

  Serial.print("Turbidity (NTU): "); Serial.print(turbidity);
  Serial.print(" | ADC: "); Serial.print(turbidityValue);
  Serial.print(" | Voltage: "); Serial.println(turbidityVoltage, 3);
  Serial.println();
}