#include "config.h"
#include "sensor.h"
#include "firebase.h"

void setup() {
  Serial.begin(115200);

  // Inisialisasi WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi terhubung");
  Serial.println("IP Address: " + WiFi.localIP().toString());
  
  // OneWire
  sensors.begin();
  analogSetPinAttenuation(TURBIDITY_SENSOR_PIN, ADC_11db); 

  // ADC
  analogReadResolution(12);

  // Inisialisasi Firebase
  initializeFirebase();

  // Pin I/O
  pinMode(TEMPERATURE_SENSOR_PIN, INPUT);
  pinMode(PH_SENSOR_PIN, INPUT);
  pinMode(TURBIDITY_SENSOR_PIN, INPUT);
  pinMode(SALINITY_PIN, INPUT); 
}

void loop() {
  updateTemperature();
  updatePH();
  updateSalinity();
  updateTurbidity();

  sendDataToFirebase(temperature, salinity, turbidity, pH);

  delay(100);
}
