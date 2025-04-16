#include "sensor.h"
#include "firebase.h"
#include "config.h"

// Variabel kontrol
bool aeratorInDelayMode = false;  // Delay setelah feeding
bool firebaseAeratorOn = true;    // Diset dari Firebase

// Update Suhu
void updateTemperature() {
  sensors.requestTemperatures();
  temperature = sensors.getTempCByIndex(0);
}

// Update pH
void updatePH() {
  float tegangan_pH = 0;
  float totalVoltage = 0;
  int numSamples = 10;

  for (int i = 0; i < numSamples; i++) {
    int sensorValue = analogRead(PH_SENSOR_PIN);
    totalVoltage += sensorValue * (3.3 / 4095.0);
    delay(100);
  }

  tegangan_pH = totalVoltage / numSamples;
  pH = 7.00 + ((teganganPh7 - tegangan_pH) / phStep);
}

// Update Salinitas
void updateSalinity() {
  int analogValueEC = analogRead(SALINITY_PIN);
  float voltageEC = analogValueEC * (vRef / ADC_RESOLUTION);
  float compensatedVoltageEC = voltageEC / (1 + temperatureCompensation * (temperature - 25));
  salinity = compensatedVoltageEC * calibrationFactor;
}

// Update Turbiditas
void updateTurbidity() {
  WiFi.mode(WIFI_OFF); delay(100);
  int turbidityValue = analogRead(TURBIDITY_SENSOR_PIN);
  WiFi.mode(WIFI_STA); delay(100);
  float turbidityVoltage = turbidityValue * (MAX_VOLTAGE / ADC_RESOLUTION);
  turbidity = (MAX_TURBIDITY * (MAX_VOLTAGE - turbidityVoltage)) / MAX_VOLTAGE;
}

// Update Hujan
void updateRainStatus() {
  rainAnalogValue = analogRead(RAIN_SENSOR_ANALOG_PIN);
  isRaining = digitalRead(RAIN_SENSOR_DIGITAL_PIN) == LOW;
}

// Update Ultrasonik
int readUltrasonicDistance() {
  int distance = sonar.ping_cm();
  return (distance == 0) ? MAX_DISTANCE : distance;
}

// Feeder
void activateFeeder(int duration) {
  feedServo.write(100);
  digitalWrite(RELAY_PIN_PAKAN, LOW);
  delay(duration * 1000);
}

void forceActivateFeeder() {
  feedServo.write(100);
  digitalWrite(RELAY_PIN_PAKAN, LOW);
}

void deactivateFeeder() {
  feedServo.write(0);
  digitalWrite(RELAY_PIN_PAKAN, HIGH);
}

// Handle Pakan
void handleFeeding() {
  DateTime now = rtc.now();
  
  // Cek jadwal dan feeding manual dari Firebase
  for (int i = 0; i < 4; i++) {
    int scheduledHour = feedingSchedule[i].hour;
    int scheduledMinute = feedingSchedule[i].minute;
    int amount = feedingSchedule[i].amount;

    if (now.hour() == scheduledHour && now.minute() == scheduledMinute && !isFeeding) {
      feedingDuration = amount / 100;  
      isFeedingFromSchedule = true;

      if (firebaseAeratorOn) {
        deactivateAerator();
        aeratorInDelayMode = true;
        aeratorOffTimestamp = now;
      }

      activateFeeder(feedingDuration);
      lastFeedingTime = now;
      isFeeding = true;
    }
  }

  if (isFeeding && (now - lastFeedingTime).totalseconds() >= feedingDuration) {
    deactivateFeeder();
    delay(30000); // Biarkan pakan keluar total
    isFeeding = false;
    isFeedingFromSchedule = false;
  }

  if (isFeeding && !isFeedingFromSchedule) {
    forceActivateFeeder();
  } else {
    deactivateFeeder();
  }
}

// Cek Level Pakan
void checkFeedLevel() {
  float distance = readUltrasonicDistance();
  if (distance > FEED_DISTANCE) {
    feedEmpty = true;
    deactivateFeeder();
  } else {
    feedEmpty = false;
  }
  sendFeedStatusToFirebase(feedEmpty);
}

// Aerator
void activateAerator() {
  digitalWrite(RELAY_PIN_AERATOR, LOW);
}

void deactivateAerator() {
  digitalWrite(RELAY_PIN_AERATOR, HIGH);
}

// Manajemen Aerator
void manageAerator() {
  DateTime now = rtc.now();

  if (!firebaseAeratorOn) {
    // Override dari Firebase: aerator harus mati
    deactivateAerator();
    return;
  }

  if (aeratorInDelayMode) {
    TimeSpan diff = now - aeratorOffTimestamp;
    if (diff.minutes() >= aeratorOnMinutesAfter) {
      activateAerator();
      aeratorInDelayMode = false;
    }
  } else {
    // Normal operation dari Firebase
    activateAerator();
  }
}
