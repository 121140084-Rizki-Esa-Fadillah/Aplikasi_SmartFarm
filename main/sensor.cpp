#include "sensor.h"
#include "firebase.h"
#include "config.h"

// Variabel kontrol
bool aeratorInDelayMode = false;  // Delay setelah feeding
float round2Decimal(float value) {
  return roundf(value * 100) / 100.0;
}


// Update Suhu
void updateTemperature() {
  sensors.requestTemperatures();
  temperature = round2Decimal(sensors.getTempCByIndex(0));
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
  pH = round2Decimal(-5.68 * tegangan_pH + 22.76);

  Serial.print("pH Voltage: "); Serial.print(tegangan_pH, 3);
  Serial.print(" | pH Value: "); Serial.println(pH, 2);
}

void updateSalinity() {
  int analogValueEC = analogRead(SALINITY_PIN);
  float voltageEC = analogValueEC * (vRef / ADC_RESOLUTION);
  float compensatedVoltageEC = voltageEC / (1 + temperatureCompensation * (temperature - 25));

  // Kalibrasi baru berdasarkan dua titik data
  salinity = 29.58 * compensatedVoltageEC - 23.75;
  if (salinity < 0) salinity = 0;
  salinity = round2Decimal(salinity);

  Serial.print("Raw Voltage: "); Serial.print(voltageEC, 3);
  Serial.print(" | Compensated V: "); Serial.print(compensatedVoltageEC, 3);
  Serial.print(" | Salinity (ppt): "); Serial.println(salinity, 2);
}

// Update Turbiditas
void updateTurbidity() {
  WiFi.mode(WIFI_OFF); 
  delay(100);
  int turbidityValue = analogRead(TURBIDITY_SENSOR_PIN);
  WiFi.mode(WIFI_STA); 
  delay(100);

  float turbidityVoltage = turbidityValue * (V_REF / ADC_RESOLUTION);

  // Kalibrasi linear dari dua titik
  turbidity = -123.82 * turbidityVoltage + 195.94;

  turbidity = round2Decimal(turbidity);
  if (turbidity < 0) turbidity = 0;
  if (turbidity > 100) turbidity = 100;

  Serial.print("ADC: "); Serial.println(turbidityValue);
  Serial.print("Voltage: "); Serial.println(turbidityVoltage, 3);
  Serial.print("Turbidity (NTU): "); Serial.println(turbidity);
}


// Update Hujan
void updateRainStatus() {
  rainAnalogValue = analogRead(RAIN_SENSOR_ANALOG_PIN);
  isRaining = digitalRead(RAIN_SENSOR_DIGITAL_PIN) == LOW;

  Serial.print("Rain Analog Value: ");
  Serial.println(rainAnalogValue);

  Serial.print("Rain Digital Status: ");
  Serial.println(isRaining ? "Hujan (LOW)" : "Tidak Hujan (HIGH)");
}


// Update Ultrasonik
int readUltrasonicDistance() {
  int distance = sonar.ping_cm();
  return (distance == 0) ? MAX_DISTANCE : distance;
}

// Feeder
void activateFeeder(int duration) {
  feedServo.write(50);
  digitalWrite(RELAY_PIN_PAKAN, LOW);
  delay(duration * 500);
}

void forceActivateFeeder() {
  feedServo.write(50);
  digitalWrite(RELAY_PIN_PAKAN, LOW);
}

void deactivateFeeder() {
  feedServo.write(0);
  digitalWrite(RELAY_PIN_PAKAN, HIGH);
}

void handleFeeding() {
  DateTime now = rtc.now();

  Serial.print("[RTC] Sekarang: ");
  Serial.print(now.hour());
  Serial.print(":");
  Serial.print(now.minute());
  Serial.print(":");
  Serial.println(now.second());


  if (feedEmpty) {
    deactivateFeeder();
    Serial.println("[Feeding] Feeding dibatalkan - Pakan habis.");
    return;
  }

  // Feeding manual dari Firebase (forceFeedNow = true)
  if (forceFeedNow) {
    forceActivateFeeder();
    Serial.println("[Feeding] Feeding manual dari Firebase AKTIF.");
    return;
  } else {
    deactivateFeeder();  // Matikan jika sebelumnya feeding manual
  }

  // Reset feedingDoneToday jika hari sudah berganti
  static int lastFeedingDay = -1;
  if (now.day() != lastFeedingDay) {
    for (int i = 0; i < 4; i++) {
      feedingDoneToday[i] = false;
    }
    lastFeedingDay = now.day();
    Serial.println("[Feeding] Hari baru, reset status feedingDoneToday.");
  }

  // Periksa setiap jadwal
  for (int i = 0; i < 4; i++) {
    int scheduledHour = feedingSchedule[i].hour;
    int scheduledMinute = feedingSchedule[i].minute;
    int amount = feedingSchedule[i].amount;

    Serial.print("[Feeding] Slot ");
    Serial.print(i);
    Serial.print(" | ");
    Serial.print("Scheduled: ");
    Serial.print(scheduledHour);
    Serial.print(":");
    Serial.print(scheduledMinute);
    Serial.print(" | FeedingDoneToday: ");
    Serial.println(feedingDoneToday[i] ? "true" : "false");

    if (!feedingDoneToday[i] && now.hour() == scheduledHour && now.minute() == scheduledMinute && now.second() <= 30 && !isFeeding) {

      feedingDuration = amount / 100;
      isFeeding = true;
      isFeedingFromSchedule = true;
      lastFeedingTime = now;
      feedingDoneToday[i] = true; // tandai sudah feeding hari ini

      if (forceAeratorNow) {
        deactivateAerator();
        aeratorInDelayMode = true;
        aeratorOffTimestamp = now;
      }

      activateFeeder(feedingDuration);
      Serial.print("[Feeding] Feeding slot ");
      Serial.print(i);
      Serial.println(" DIMULAI (otomatis).");
    }
  }

  // Cek apakah feeding otomatis selesai
  if (isFeeding && isFeedingFromSchedule &&
      (now - lastFeedingTime).totalseconds() >= feedingDuration) {
    deactivateFeeder();
    isFeeding = false;
    isFeedingFromSchedule = false;
    Serial.println("[Feeding] Feeding otomatis SELESAI.");
  }
}


// Cek Level Pakan
void checkFeedLevel() {
  float distance = readUltrasonicDistance();
  // Tambahkan print debug
  Serial.print("Jarak ultrasonik: ");
  Serial.print(distance);
  Serial.println(" cm");
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

  // Override: jika status Firebase mematikan aerator
  if (!forceAeratorNow) {
    deactivateAerator();
    return;
  }

  // Delay aktif (saat feeding dari jadwal, bukan manual)
  if (aeratorInDelayMode) {
    TimeSpan diff = now - aeratorOffTimestamp;
    if (diff.minutes() >= aeratorOnMinutesAfter) {
      aeratorInDelayMode = false;
      activateAerator();
      Serial.println("Aerator aktif kembali setelah delay.");
    } else {
      deactivateAerator();  // masih dalam delay
      Serial.println("Aerator dalam delay setelah feeding.");
    }
  } else {
    activateAerator();  // normal
  }
}

