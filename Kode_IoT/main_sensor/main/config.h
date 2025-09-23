#ifndef CONFIG_H
#define CONFIG_H

//Library
#include <FirebaseESP32.h>
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Wire.h>


// Base Path Firebase
#define FIREBASE_BASE_PATH "App_SmartFarm/ponds/SF-Pond-001"

// Konfigurasi Wi-Fi
extern const char* ssid;
extern const char* password;

// Konfigurasi Firebase
#define FIREBASE_HOST "https://app-smartfarm-bd7d2-default-rtdb.asia-southeast1.firebasedatabase.app//"
#define FIREBASE_AUTH "kJLCw4eRjO5HAxqIDxMFKjdX75Rp65CA2FeM8t5O"

extern FirebaseData firebaseData;
extern FirebaseJson Json;

//Temperature
#define TEMPERATURE_SENSOR_PIN 14
extern DallasTemperature sensors;

//PH
#define PH_SENSOR_PIN 32

//Turbidity
#define TURBIDITY_SENSOR_PIN 34
constexpr float V_REF = 3.3;
constexpr float ADC_RESOLUTION = 4095;

//Salinity
#define SALINITY_PIN 39
constexpr float vRef = 3.3;
constexpr float temperatureCompensation = 0.019;

// Threshold & Flags
extern float temperatureLow, pHLow, salinityLow, turbidityLow;
extern float temperatureHigh, pHHigh, salinityHigh, turbidityHigh;

extern float temperature, pH, salinity, turbidity;

#endif // CONFIG_H