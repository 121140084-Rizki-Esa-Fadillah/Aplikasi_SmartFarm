#ifndef CONFIG_H
#define CONFIG_H

//Library
#include <RTClib.h>
#include <LiquidCrystal_I2C.h>
#include <WiFi.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <ESP32Servo.h>
#include <FirebaseESP32.h>
#include <TimeLib.h> 
#include <OneWire.h>
#include <DallasTemperature.h>
#include <NewPing.h>
#include <Wire.h>
#include <FS.h>
#include <SD.h>
#include <SPI.h>
#include <Arduino.h>

// Base Path Firebase
#define FIREBASE_BASE_PATH "Sadewa_SmartFarm/ponds/SSF-Pond-001"

// Konfigurasi Wi-Fi
extern const char* ssid;
extern const char* password;

// Konfigurasi Firebase
#define FIREBASE_HOST "https://app-sadewa-smartfarm-default-rtdb.asia-southeast1.firebasedatabase.app/"
#define FIREBASE_AUTH "5J7D9ikZ2kAenTPKVNKTR41QcJyokSxPmTA0vZyA"

extern FirebaseData firebaseData;
extern FirebaseJson Json;


// Setup NTP (Network Time Protocol) Client
extern WiFiUDP ntpUDP;
extern NTPClient timeClient;

//Temperature
#define TEMPERATURE_SENSOR_PIN 4
extern DallasTemperature sensors;

//PH
#define PH_SENSOR_PIN 36

//Turbidity
#define TURBIDITY_SENSOR_PIN 34
constexpr float V_REF = 3.3;
constexpr float ADC_RESOLUTION = 4095;

//Salinity
#define SALINITY_PIN 39
constexpr float vRef = 3.3;
constexpr float temperatureCompensation = 0.019;

//Ultrasonik
#define TRIGGER_PIN 26
#define ECHO_PIN 25
constexpr int MAX_DISTANCE = 200; 
constexpr int FEED_DISTANCE = 14;   
extern NewPing sonar;

// Servo & Relay
#define SERVO_PIN_TABUNG_PAKAN 12
#define RELAY_PIN_AERATOR 16
#define RELAY_PIN_PAKAN 17
extern Servo feedServo;

// RTC 
extern RTC_DS3231 rtc;

// LCD
constexpr uint8_t LCD_ADDRESS = 0x27;
constexpr uint8_t LCD_COLUMNS = 20;
constexpr uint8_t LCD_ROWS = 4;
extern LiquidCrystal_I2C lcd;

// Deklarasi pin IC
#define DS_PIN 0
#define STCP_PIN 15
#define SHCP_PIN 27

// SD Card
#define CS_PIN 5
extern bool sdCardAvailable;
extern unsigned long lastLogMillis;

//Hujan
#define RAIN_SENSOR_ANALOG_PIN 33
#define RAIN_SENSOR_DIGITAL_PIN 13
extern bool isRaining;
extern int rainAnalogValue;

// Threshold & Flags
extern float temperatureLow, pHLow, salinityLow, turbidityLow;
extern float temperatureHigh, pHHigh, salinityHigh, turbidityHigh;

extern float temperature, pH, salinity, turbidity;

extern bool AeratorEnabled, PakanUdangEnabled;

// Jadwal Pakan
struct FeedingSchedule {
      int hour;
      int minute;
      int amount;
    };
    
extern FeedingSchedule feedingSchedule[4];
extern bool isFeeding;
extern bool feedEmpty;
extern int feedingDuration;
extern DateTime lastFeedingTime;
extern bool isFeedingFromSchedule;
extern bool feedingDoneToday[4];
extern int lastFeedingDay;

// Aerator
extern int aeratorOnMinutesAfter;
extern DateTime aeratorOffTimestamp;

extern bool forceFeedNow;
extern bool forceAeratorNow;

#endif // CONFIG_H
