#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <FS.h>
#include <SD.h>
#include <SPI.h>
#include <RTClib.h>
#include <WiFi.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <NewPing.h>
#include <ESP32_Servo.h>
#include <FirebaseESP32.h>
#include <TimeLib.h> 


// Konfigurasi Wi-Fi
const char* ssid = "realme";
const char* password = "12345678";

// Konfigurasi Firebase
#define FIREBASE_HOST "https://app-sadewa-smartfarm-default-rtdb.asia-southeast1.firebasedatabase.app/"  
#define FIREBASE_AUTH "5J7D9ikZ2kAenTPKVNKTR41QcJyokSxPmTA0vZyA" 


FirebaseData firebaseData;  // Deklarasi objek Firebase data
FirebaseConfig firebaseConfig;  // Objek untuk konfigurasi Firebase
FirebaseAuth firebaseAuth;  // Objek untuk autentikasi Firebase
FirebaseJson Json;

// Deklarasi pin dan setup untuk sensor suhu
const int oneWireBusPin = 4;
OneWire oneWire(oneWireBusPin);
DallasTemperature sensors(&oneWire);
float temperature; // Variabel untuk menyimpan nilai suhu

// Deklarasi pin dan setup untuk sensor turbidity
#define TURBIDITY_SENSOR_PIN 14   
#define MAX_VOLTAGE 4.5      
#define MAX_TURBIDITY 100.0       // Nilai NTU maksimum sensor
#define ADC_RESOLUTION 4095.0     // Resolusi ADC 12-bit pada ESP32
float turbidity;

// Deklarasi pin dan setup untuk sensor salinitas
const int ecPin = 39; 
const float vRef = 3.3; // Tegangan referensi
const float temperatureCompensation = 0.019; // Konstanta kompensasi suhu untuk air laut
float calibrationFactor = 8.51;  // Faktor kalibrasi untuk salinitas (sesuaikan dengan kalibrasi)
float salinity;

// Deklarasi pin dan setup dan variabel untuk sensor pH
const int pHSensorPin = 36;  // Pin ADC pada ESP32
float tegangan_pH = 0;      // Variabel untuk menyimpan tegangan dari sensor
float pH = 0;               // Variabel untuk menyimpan nilai pH
float teganganPh7 = 2.6;    // Tegangan pada pH 7, biasanya sekitar 2.5V
float teganganPh4 = 3.1;    // Tegangan pada pH 4
float phStep = (teganganPh4 - teganganPh7) / 3;  // Menghitung sensitivitas pH per volt

// Deklarasi pin dan setup untuk sensor hujan
#define RAIN_SENSOR_ANALOG_PIN 33
#define RAIN_SENSOR_DIGITAL_PIN 13
const int rainThreshold = 1000; // Threshold untuk mendeteksi hujan
bool isRaining = false; // Flag untuk status hujan
int rainAnalogValue;

// Deklarasi pin dan setup untuk sensor Ultrasonik
#define TRIGGER_PIN 26
#define ECHO_PIN 25
#define MAX_DISTANCE 200  // Maksimal jarak pembacaan (dalam cm)
const int maxDistance = 14; // Maksimal jarak (cm) untuk mengaktifkan pemberian pakan
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);  // NewPing(trigPin, echoPin, maxDist)

// Deklarasi pin dan setup untuk servo 
#define SERVO_PIN 12
Servo feedServo;
bool isFeeding = false; // Inisialisasi Servo

// Deklarasi pin dan setup Relay
#define RelayPin 16 //Kinncir Air
bool isAeratorOff = false;
int aeratorOffMinutesBefore = 5;
int aeratorOnMinutesAfter = 5;
#define RelayPin2 17 //Pakan Udang
int feedingDuration = 0; // Durasi aktif pelontar pakan
DateTime lastFeedingTime;

// Deklarasi pin dan setup LCD
#define LCD_ADDRESS 0x27
#define LCD_COLUMNS 20
#define LCD_ROWS 4
LiquidCrystal_I2C lcd(LCD_ADDRESS, LCD_COLUMNS, LCD_ROWS);

// Deklarasi pin IC
int DS_PIN = 0;     // DS pin of 74HC595 (Data)
int STCP_PIN = 15;   // STCP pin of 74HC595 (Storage Register Clock)
int SHCP_PIN = 27;  // SHCP pin of 74HC595 (Shift Register Clock)

// Buat instance RTC
RTC_DS3231 rtc;

// Setup NTP (Network Time Protocol) Client
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 7 * 3600, 60000); // Offset waktu UTC+7, pembaruan setiap 60 detik

// Deklarasi pin dan setup SD Card
#define CS_PIN 5
bool sdCardAvailable = false; // Flag untuk memeriksa keberadaan SD card
unsigned long previousMillis = 0; // Waktu sebelumnya untuk penyimpanan SD card
// Variabel untuk menyimpan nilai threshold
float pHHigh, pHLow, salinityHigh, salinityLow, temperatureHigh, temperatureLow, turbidityHigh, turbidityLow;

// Variabel global untuk status sensor
bool phSensorEnabled = true;
bool salinitySensorEnabled = true;
bool temperatureSensorEnabled = true;
bool turbiditySensorEnabled = true;

// Deklarasi fungsi readSalinity
float readSalinity();


void setup() {
  Serial.begin(115200);
  sensors.begin();
  lcd.begin();
  lcd.backlight();

  // Inisialisasi Wi-Fi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected!");


  // Inisialisasi Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);

  // Memeriksa koneksi ke Firebase
  if (Firebase.ready()) {
      Serial.println("Koneksi ke Firebase berhasil.");
  } else {
      Serial.print("Gagal terhubung ke Firebase: ");
      Serial.println(firebaseData.errorReason());
  }
  
  // Inisialisasi NTP Client
  timeClient.begin();
  timeClient.update();

  // Inisialisasi RTC
  if (!rtc.begin()) {
    Serial.println("Couldn't find RTC");
    while (1);
  }

  // Setel waktu RTC dengan waktu dari NTP
  DateTime now = DateTime(timeClient.getEpochTime());
  rtc.adjust(now);

  // Inisialisasi SD card
  sdCardAvailable = SD.begin(CS_PIN);
  if (!sdCardAvailable) {
    Serial.println("Card failed, or not present. Please check");
  } else {
    Serial.println("SD card initialized.");
    addCSVHeader();
  }

  // Konfigurasi ADC ESP32 jika diperlukan
  analogReadResolution(12);  // Set resolusi ADC ESP32 ke 12 bit (0 - 4095)

  // Inisialisasi pin sensor pH
  pinMode(pHSensorPin, INPUT);

  // Inisialisasi pin sensor hujan
  pinMode(RAIN_SENSOR_ANALOG_PIN, INPUT);
  pinMode(RAIN_SENSOR_DIGITAL_PIN, INPUT);

  // Inisialisasi sensor ultrasonik
  pinMode(TRIGGER_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // Inisialisasi servo dan relay
  feedServo.attach(SERVO_PIN);
  pinMode(RelayPin, OUTPUT);
  pinMode(RelayPin2, OUTPUT);

  // Matikan relay saat awal
  digitalWrite(RelayPin, LOW);
  digitalWrite(RelayPin2, HIGH);

  // Set pin modes
  pinMode(DS_PIN, OUTPUT);
  pinMode(STCP_PIN, OUTPUT);
  pinMode(SHCP_PIN, OUTPUT);

  // Initialize with all LEDs off
  updateShiftRegister(0b00000000); // All LEDs off

  Firebase.beginStream(firebaseData, "/thresholds");
  Firebase.beginStream(firebaseData, "/status_sensor");
  Firebase.beginStream(firebaseData, "/aerator");
  Firebase.beginStream(firebaseData, "/feeding_schedule");
}

void loop() {
    // Periksa koneksi WiFi
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("WiFi not connected. Attempting to reconnect...");
        WiFi.reconnect();
        delay(500); // Tunggu sebentar sebelum mencoba lagi
    } else {
        // Mendapatkan data dari Firebase
        if (Firebase.get(firebaseData, "/thresholds")) {
            if (firebaseData.dataType() == "json") {
                Serial.println("Received update for /thresholds");
                FirebaseJson json = firebaseData.jsonObject();  // Mendapatkan objek JSON
                updateThresholds(json);
            } else {
                Serial.println("Data is not JSON.");
            }
        } else {
            Serial.print("Failed to get thresholds: ");
            Serial.println(firebaseData.errorReason());
        }

        if (Firebase.get(firebaseData, "/status_sensor")) {
            if (firebaseData.dataType() == "json") {
                Serial.println("Received update for /status_sensor");
                FirebaseJson json = firebaseData.jsonObject();
                updateSensorStatus(json);
            } else {
                Serial.println("Data is not JSON.");
            }
        } else {
            Serial.print("Failed to get sensor status: ");
            Serial.println(firebaseData.errorReason());
        }

        if (Firebase.get(firebaseData, "/feeding_schedule")) {
            if (firebaseData.dataType() == "json") {
                Serial.println("Received update for /feeding_schedule");
                FirebaseJson json = firebaseData.jsonObject();
                updateFeedingSchedule(json);
            } else {
                Serial.println("Data is not JSON.");
            }
        } else {
            Serial.print("Failed to get feeding schedule: ");
            Serial.println(firebaseData.errorReason());
        }

        if (Firebase.get(firebaseData, "/aerator")) {
            if (firebaseData.dataType() == "json") {
                Serial.println("Received update for /aerator");
                FirebaseJson json = firebaseData.jsonObject();
                updateAeratorConfig(json);
            } else {
                Serial.println("Data is not JSON.");
            }
        } else {
            Serial.print("Failed to get aerator config: ");
            Serial.println(firebaseData.errorReason());
        }

        // Tambahkan delay untuk mencegah permintaan terlalu cepat
        delay(5000); // Tunggu 5 detik sebelum melakukan pengambilan data berikutnya
    }

  DateTime now = rtc.now();

  // Variabel untuk menyimpan data sensor
    float temperature = temperatureSensorEnabled ? readTemperature() : 0;
    float pH = phSensorEnabled ? readPH() : 0;
    float salinity = salinitySensorEnabled ? calculateSalinity(temperature) : 0;
    float turbidity = turbiditySensorEnabled ? readTurbidity() : 0;

  
  int rainAnalogValue = analogRead(RAIN_SENSOR_ANALOG_PIN);
  bool isRaining = checkRainStatus();
  rain_display(rainAnalogValue, temperature, salinity, turbidity, pH);
  checkFeedLevel();
  manageAerator();
  handleFeeding();
  logDataIfNeeded(now, temperature, salinity, turbidity, pH, isRaining);
  updateLEDIndicators(temperature, salinity, turbidity, pH);
  displayTimeAndGearboxStatus(now);

  // Send sensor data to Firebase
  sendDataToFirebase(temperature, salinity, turbidity, pH, now);

  delay(100);
}

void checkWiFiConnection() {
    if (WiFi.status() != WL_CONNECTED) {
        Serial.println("WiFi not connected. Attempting to reconnect...");
        WiFi.disconnect(); // Disconnect first
        WiFi.reconnect();  // Try to reconnect
        delay(500);       // Wait for 5 seconds
    } else {
        Serial.println("WiFi is connected");
    }
}

// Fungsi untuk membaca suhu
float readTemperature() {
  sensors.requestTemperatures();
  return sensors.getTempCByIndex(0);
}

// Fungsi untuk membaca nilai turbidity
float readTurbidity() {
  WiFi.mode(WIFI_OFF);
  delay(100);
  int turbidityValue = analogRead(TURBIDITY_SENSOR_PIN);
  WiFi.mode(WIFI_STA);
  delay(100);
  float turbidityVoltage = turbidityValue * (MAX_VOLTAGE / ADC_RESOLUTION);
  return (MAX_TURBIDITY * (MAX_VOLTAGE - turbidityVoltage)) / MAX_VOLTAGE;
}

// Fungsi untuk menghitung salinitas
float calculateSalinity(float temperature) {
  int analogValueEC = analogRead(ecPin);
  float voltageEC = analogValueEC * (vRef / ADC_RESOLUTION);
  float compensatedVoltageEC = voltageEC / (1 + temperatureCompensation * (temperature - 25));
  return compensatedVoltageEC * calibrationFactor;
}

// Fungsi untuk mengecek status hujan
bool checkRainStatus() {
  int rainDigitalValue = digitalRead(RAIN_SENSOR_DIGITAL_PIN);
  return (rainDigitalValue == LOW);
}

// Fungsi untuk membaca nilai pH
float readPH() {
  float totalVoltage = 0;
  int numSamples = 10;

  for (int i = 0; i < numSamples; i++) {
    int sensorValue = analogRead(pHSensorPin);
    totalVoltage += sensorValue * (3.3 / 4095.0);
    delay(100);
  }
  
  float tegangan_pH = totalVoltage / numSamples;
  return 7.00 + ((teganganPh7 - tegangan_pH) / phStep);
}

int readUltrasonicDistance() {
  int distance = sonar.ping_cm();  // Fungsi ping_cm() akan mengembalikan jarak dalam cm
  if (distance == 0) {
    distance = MAX_DISTANCE;  // Jika tidak terbaca, gunakan nilai maxDistance
  }

  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" cm");
  return distance;
}

// Definisikan struct untuk feeding schedule jika belum
struct FeedingSchedule {
  int hour;
  int minute;
  int amount;
};

// Deklarasi array feedingSchedule
FeedingSchedule feedingSchedule[4];

// Fungsi untuk mengelola pemberian pakan
void handleFeeding() {
  DateTime now = rtc.now();

  for (int i = 0; i < 4; i++) {
    // Mengakses anggota dari feedingSchedule dengan notasi titik
    int scheduledHour = feedingSchedule[i].hour;    // Mengakses hour
    int scheduledMinute = feedingSchedule[i].minute; // Mengakses minute
    int amount = feedingSchedule[i].amount;          // Mengakses amount

    // Jika waktu saat ini cocok dengan waktu jadwal pakan
    if (now.hour() == scheduledHour && now.minute() == scheduledMinute && !isFeeding) {
      feedingDuration = amount / 50; // Durasi dalam detik sesuai dengan jumlah pakan
      activateFeeder(feedingDuration);
      lastFeedingTime = now;
      isFeeding = true;
    }
  }

  // Matikan feeder setelah durasi pemberian pakan selesai
  if (isFeeding && (now - lastFeedingTime).totalseconds() >= feedingDuration) {
    deactivateFeeder();
    delay(30000);
    isFeeding = false;
  }
}

// Fungsi untuk mengelola aerator
void manageAerator() {
  DateTime now = rtc.now();
  for (int i = 0; i < 4; i++) {
    // Mengakses anggota dari feedingSchedule dengan notasi titik
    int scheduledHour = feedingSchedule[i].hour;    // Mengakses hour
    int scheduledMinute = feedingSchedule[i].minute; // Mengakses minute
    DateTime feedingTime(now.year(), now.month(), now.day(), scheduledHour, scheduledMinute);

    DateTime aeratorOffTime = feedingTime - TimeSpan(0, 0, aeratorOffMinutesBefore, 0);
    DateTime aeratorOnTime = feedingTime + TimeSpan(0, 0, aeratorOnMinutesAfter, 0);

    // Matikan aerator beberapa menit sebelum waktu pemberian pakan
    if (now >= aeratorOffTime && now < feedingTime && !isAeratorOff) {
      deactivateAerator();
      isAeratorOff = true;
    }

    // Hidupkan kembali aerator beberapa menit setelah pemberian pakan selesai
    if (now >= aeratorOnTime && isAeratorOff) {
      activateAerator();
      isAeratorOff = false;
    }
  }
}

// Fungsi untuk mengaktifkan feeder
void activateFeeder(int duration) {
  feedServo.write(100); // Buka pintu pakan
  digitalWrite(RelayPin2, LOW); // Aktifkan relay untuk pelontar pakan
  Serial.println("Feeder ON");
  lcd.clear();
  lcd.print("Feeder ON");
  delay(duration * 1000); // Durasi pemberian pakan
}

// Fungsi untuk menonaktifkan feeder
void deactivateFeeder() {
  feedServo.write(0); // Tutup pintu pakan
  digitalWrite(RelayPin2, HIGH); // Matikan relay pelontar pakan
  Serial.println("Feeder OFF");
  lcd.clear();
  lcd.print("Feeder OFF");
}

// Fungsi untuk mengaktifkan aerator
void activateAerator() {
  digitalWrite(RelayPin, LOW); // Aktifkan aerator
  Serial.println("Aerator ON");
}

// Fungsi untuk menonaktifkan aerator
void deactivateAerator() {
  digitalWrite(RelayPin, HIGH); // Matikan aerator
  Serial.println("Aerator OFF");
}

// Fungsi untuk mengecek level pakan
void checkFeedLevel() {
  float distance = readUltrasonicDistance();
  if (distance > maxDistance) {
    deactivateFeeder();
    lcd.clear();
    lcd.setCursor(0, 1);
    lcd.print("Pakan hampir habis");
    lcd.setCursor(0, 2);
    lcd.print("Tolong isi pakan!!!");
    Serial.println("Pakan hampir habis !!!");
    updateFeedStatus(false);
  }
  else {
    updateFeedStatus(true);
  }
}

// Fungsi untuk log data jika diperlukan
void logDataIfNeeded(DateTime now, float temperature, float salinity, float turbidity, float pH, bool isRaining) {
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillis >= 5000) {
    previousMillis = currentMillis;
    logData(now, temperature, salinity, turbidity, pH, isRaining);
    if (currentMillis % 360000 < 5000) {
      createNewCSVFile(now);
    }
  }
}

// Fungsi untuk memperbarui indikator LED berdasarkan kondisi
void updateLEDIndicators(float temperature, float salinity, float turbidity, float pH) {
  byte shiftData = 0b00000000;

  if (temperature < temperatureLow || temperature > temperatureHigh) shiftData |= 0b00000001;
  else shiftData |= 0b00000010;

  if (salinity < salinityLow || salinity > salinityHigh) shiftData |= 0b00000100;
  else shiftData |= 0b00001000;

  if (turbidity < turbidityLow || turbidity > turbidityHigh) shiftData |= 0b00010000;
  else shiftData |= 0b00100000;

  if (pH < pHLow || pH > pHHigh) shiftData |= 0b01000000;
  else shiftData |= 0b10000000;

  updateShiftRegister(shiftData);
}

// Fungsi untuk menampilkan waktu dan status gearbox ke Serial Monitor
void displayTimeAndGearboxStatus(DateTime now) {
  Serial.print("Waktu RTC: ");
  Serial.print(now.year());
  Serial.print("-");
  Serial.print(now.month());
  Serial.print("-");
  Serial.print(now.day());
  Serial.print(" ");
  Serial.print(now.hour());
  Serial.print(":");
  Serial.print(now.minute());
  Serial.print(":");
  Serial.println(now.second());
}

void rain_display(int rainAnalogValue, float temperature, float salinity, float turbidity, float pH){
  if (isRaining) {
    displayRainStatus(rainAnalogValue);
  } else {
    displayLCD(temperature, salinity, turbidity, pH); // Perbarui LCD dengan nilai pH
  }
}

void displayRainStatus(int rainValueAnalog) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Cuaca Sedang Hujan");

  lcd.setCursor(0, 1);
  lcd.print("Intensitas : ");
  if (rainValueAnalog > 1500) {
    lcd.print("Deras");
  } else if (rainValueAnalog > 1000) {
    lcd.print("Sedang");
  } else {
    lcd.print("Ringan");
  }
}

void displayLCD(float temperature, float salinity, float turbidity, float pH) {
  lcd.clear(); // Bersihkan layar LCD

  // Menampilkan suhu jika sensor aktif
  if (temperatureSensorEnabled) {
      lcd.setCursor(0, 0); // Baris 0
      lcd.print("Temp: ");
      lcd.print(temperature);
      lcd.print(" C");
  }

  // Menampilkan salinitas jika sensor aktif
  if (salinitySensorEnabled) {
      lcd.setCursor(0, 1); // Baris 1
      lcd.print("Sal: ");
      lcd.print(salinity);
      lcd.print(" ppt");
  }

  // Menampilkan turbidity jika sensor aktif
  if (turbiditySensorEnabled) {
      lcd.setCursor(0, 2); // Baris 2
      lcd.print("Turb: ");
      lcd.print(turbidity);
      lcd.print(" NTU");
  }

  // Menampilkan pH jika sensor aktif
  if (phSensorEnabled) {
      lcd.setCursor(0, 3); // Baris 3
      lcd.print("pH: ");
      lcd.print(pH, 2); // Menampilkan pH dengan 2 angka desimal
  }
}

void logData(DateTime now, float temp, float salinity, float turbidity, float pH, int rainValueDigital) {
  File dataFile = SD.open("/data_sensor.csv", FILE_APPEND);

  if (dataFile) {
    // Tulis data dalam format CSV
    dataFile.print(now.year());
    dataFile.print(",");
    dataFile.print(now.month());
    dataFile.print(",");
    dataFile.print(now.day());
    dataFile.print(",");
    dataFile.print(now.hour());
    dataFile.print(",");
    dataFile.print(now.minute());
    dataFile.print(",");
    dataFile.print(now.second());
    dataFile.print(",");
    dataFile.print(temp);
    dataFile.print(",");
    dataFile.print(salinity);
    dataFile.print(",");
    dataFile.print(turbidity);
    dataFile.print(",");
    dataFile.print(pH);
    dataFile.print(",");
    dataFile.println(rainValueDigital == LOW ? "Yes" : "No");

    dataFile.close();
  } else {
    Serial.println("Error opening data_sensor.csv");
  }
}

void addCSVHeader() {
  File dataFile = SD.open("/data_sensor.csv", FILE_READ);

  if (!dataFile) {
    // Jika file belum ada, tambahkan header
    dataFile = SD.open("/data_sensor.csv", FILE_WRITE);
    if (dataFile) {
      dataFile.println("Year,Month,Day,Hour,Minute,Second,Temperature,Salinity,Turbidity,pH,RainDigitalValue");
      dataFile.close();
    } else {
      Serial.println("Error creating data_sensor.csv");
    }
  } else {
    dataFile.close();
  }
}

void createNewCSVFile(DateTime now) {
  String fileName = "/data_sensor_" + String(now.year()) + "" + String(now.month()) + "" + String(now.day()) + "" + String(now.hour()) + "" + String(now.minute()) + ".csv";
  File dataFile = SD.open(fileName.c_str(), FILE_WRITE);

  if (dataFile) {
    dataFile.println("Year,Month,Day,Hour,Minute,Second,Temperature,Salinity,Turbidity,pH,RainDigitalValue");
    dataFile.close();
  } else {
    Serial.println("Error creating new CSV file");
  }
}

// Function to send data to the 74HC595 shift register
void updateShiftRegister(byte data) {
  // Set STCP (latch) to low to prepare for data
  digitalWrite(STCP_PIN, LOW);
  
  // Use Arduino's built-in shiftOut function to shift data to the 74HC595
  shiftOut(DS_PIN, SHCP_PIN, MSBFIRST, data);
  
  // Set STCP (latch) to high to output data to the LEDs
  digitalWrite(STCP_PIN, HIGH);
}

// Function to send sensor data to Firebase
void sendDataToFirebase(float temperature, float salinity, float turbidity, float pH, DateTime now) {
  if (Firebase.ready()) {
    String path = "/sensorData"; // Path in Firebase
    String rtcTime = String(now.year()) + "-" + String(now.month()) + "-" + String(now.day()) + " " +
                     String(now.hour()) + ":" + String(now.minute()) + ":" + String(now.second());
    FirebaseJson json;
    json.set("temperature", temperature);
    json.set("salinity", salinity);
    json.set("turbidity", turbidity);
    json.set("pH", pH);
    json.set("rtcTime", rtcTime);
    
    // Send data to Firebase
    if (Firebase.setJSON(firebaseData, path, json)) {
      Serial.println("Data sent to Firebase successfully");
    } else {
      Serial.print("Error sending data: ");
      Serial.println(firebaseData.errorReason());
    }
  }
}

// Fungsi untuk memperbarui nilai threshold
void updateThresholds(FirebaseJson json) {
    FirebaseJsonData jsonData; // Membuat objek untuk menyimpan hasil

    // Mengambil nilai threshold dari JSON
    if (json.get(jsonData, "pHHigh")) {
      pHHigh = jsonData.floatValue; // Ambil nilai sebagai float
      Serial.print("pH High: "); Serial.println(pHHigh);
    }

    if (json.get(jsonData, "pHLow")) {
      pHLow = jsonData.floatValue; // Ambil nilai sebagai float
      Serial.print("pH Low: "); Serial.println(pHLow);
    }

    if (json.get(jsonData, "salinityHigh")) {
      salinityHigh = jsonData.floatValue; // Ambil nilai sebagai float
            Serial.print("Salinity High: "); Serial.println(salinityHigh);
    }

    if (json.get(jsonData, "salinityLow")) {
      salinityLow = jsonData.floatValue; // Ambil nilai sebagai float
      Serial.print("Salinity Low: "); Serial.println(salinityLow);
    }

    if (json.get(jsonData, "temperatureHigh")) {
      temperatureHigh = jsonData.floatValue; // Ambil nilai sebagai float
      Serial.print("Temperature High: "); Serial.println(temperatureHigh);
    }

    if (json.get(jsonData, "temperatureLow")) {
      temperatureLow = jsonData.floatValue; // Ambil nilai sebagai float
      Serial.print("Temperature Low: "); Serial.println(temperatureLow); 
    }

    if (json.get(jsonData, "turbidityHigh")) {
      turbidityHigh = jsonData.floatValue; // Ambil nilai sebagai float
      Serial.print("Turbidity High: "); Serial.println(turbidityHigh);
    }

    if (json.get(jsonData, "turbidityLow")) {
      turbidityLow = jsonData.floatValue; // Ambil nilai sebagai float
      Serial.print("Turbidity Low: "); Serial.println(turbidityLow);
    }
}


void updateSensorStatus(FirebaseJson json) {
    FirebaseJsonData jsonData; // Membuat objek untuk menyimpan hasil

    if (json.get(jsonData, "ph")) {
      phSensorEnabled = jsonData.boolValue; 
      Serial.print("Updated pH Sensor: ");
      Serial.println(phSensorEnabled ? "On" : "Off");
    }

    if (json.get(jsonData, "salinitas")) {
      salinitySensorEnabled = jsonData.boolValue; 
      Serial.print("Updated Salinity Sensor: ");
      Serial.println(salinitySensorEnabled ? "On" : "Off");
    } 

    if (json.get(jsonData, "suhu")) {
      temperatureSensorEnabled = jsonData.boolValue; 
      Serial.print("Updated Temperature Sensor: ");
      Serial.println(temperatureSensorEnabled ? "On" : "Off");
    } 

    if (json.get(jsonData, "turbidity")) {
      turbiditySensorEnabled = jsonData.boolValue; 
      Serial.print("Updated Turbidity Sensor: ");
      Serial.println(turbiditySensorEnabled ? "On" : "Off");
    } 
}


// Fungsi untuk mengupdate status isi_pakan di Firebase
void updateFeedStatus(bool isFeedAvailable) {
  checkWiFiConnection();
  if (Firebase.ready()) {
      String path = "/isi_pakan"; // Path di Firebase
      // Use the firebaseData object directly (not as a pointer)
      if (Firebase.setBool(firebaseData, path, isFeedAvailable)) {
          Serial.println("Status isi_pakan berhasil diperbarui ke Firebase.");
      } else {
          Serial.print("Gagal memperbarui status isi_pakan: ");
          Serial.println(firebaseData.errorReason());
      }
  }
}

// Fungsi untuk memperbarui konfigurasi aerator dari stream
void updateAeratorConfig(FirebaseJson json) {
  FirebaseJsonData jsonData; // Membuat objek untuk menampung hasil

  json.get(jsonData, "aeratorOffMinutesBefore"); // Ambil nilai "aeratorOffMinutesBefore"
  if (jsonData.success) { // Memeriksa apakah permintaan sukses
    aeratorOffMinutesBefore = jsonData.intValue; // Dapatkan nilai jika tipe data berhasil
  }

  json.get(jsonData, "aeratorOnMinutesAfter"); // Ambil nilai "aeratorOnMinutesAfter"
  if (jsonData.success) { // Memeriksa apakah permintaan sukses
    aeratorOnMinutesAfter = jsonData.intValue; // Dapatkan nilai jika tipe data berhasil
  }

  Serial.println("Aerator Config Updated:");
  Serial.print("Aerator Off Minutes Before: "); Serial.println(aeratorOffMinutesBefore);
  Serial.print("Aerator On Minutes After: "); Serial.println(aeratorOnMinutesAfter);
}

// Fungsi untuk memperbarui jadwal pakan dari stream
void updateFeedingSchedule(FirebaseJson json) {
  FirebaseJsonData jsonData; // Membuat objek FirebaseJsonData untuk menampung hasil

  for (int i = 1; i <= 4; i++) {
    String schedulePath = "schedule_" + String(i);

    json.get(jsonData, schedulePath + "/amount"); // Ambil nilai "amount"
    int amount = (jsonData.success) ? jsonData.intValue : 0; // Memeriksa apakah permintaan sukses

    json.get(jsonData, schedulePath + "/time"); // Ambil nilai "time"
    String time = (jsonData.success) ? jsonData.stringValue : ""; // Memeriksa apakah permintaan sukses

    int hour = time.substring(0, 2).toInt();
    int minute = time.substring(3, 5).toInt();

    // Perbarui jadwal pakan
    feedingSchedule[i - 1] = {hour, minute, amount};
  }

  Serial.println("Feeding Schedule Updated:");
  for (int i = 0; i < 4; i++) {
    Serial.print("Schedule "); Serial.print(i + 1); Serial.print(": ");
    Serial.print("Time: "); Serial.print(feedingSchedule[i].hour); Serial.print(":");
    Serial.print(feedingSchedule[i].minute); Serial.print(", Amount: ");
    Serial.println(feedingSchedule[i].amount);
  }
}
