#include "config.h"

// Wi-Fi
// const char* ssid = "Galaxy A12 8FE5";
// const char* password = "123454321";

// Wi-Fi
const char* ssid = "Prolink_PRT7011L_E3F7D";
const char* password = "prolink12345";

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