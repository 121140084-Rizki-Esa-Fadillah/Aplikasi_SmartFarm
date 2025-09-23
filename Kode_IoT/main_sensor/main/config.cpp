#include "config.h"

// Wi-Fi
const char* ssid = "App Smartfarm";
const char* password = "12345678";

// Wi-Fi
//const char* ssid = "Prolink_PRT7011L_E3F7D";
//const char* password = "prolink12345";

// Firebase
FirebaseData firebaseData;
FirebaseJson Json;

// Temperature
OneWire oneWire(TEMPERATURE_SENSOR_PIN);
DallasTemperature sensors(&oneWire);

// Treshold Sensor
float temperatureLow, pHLow, salinityLow, turbidityLow;
float temperatureHigh, pHHigh, salinityHigh, turbidityHigh;

// Sensor Value
float temperature, pH, salinity, turbidity;