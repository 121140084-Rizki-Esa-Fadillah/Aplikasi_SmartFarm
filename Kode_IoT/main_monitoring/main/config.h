#ifndef CONFIG_H
#define CONFIG_H

//Library
#include <LiquidCrystal_I2C.h>
#include <WiFi.h>
#include <RTClib.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <ESP32Servo.h>
#include <FirebaseESP32.h>
#include <NewPing.h>
#include <Wire.h>
#include <Arduino.h>

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

// Setup NTP (Network Time Protocol) Client
extern WiFiUDP ntpUDP;
extern NTPClient timeClient;

// RTC 
extern RTC_DS3231 rtc;
extern bool rtcAvailable;

//Ultrasonik
#define TRIGGER_PIN 26
#define ECHO_PIN 25
constexpr int MAX_DISTANCE = 200; 
constexpr int FEED_DISTANCE = 14;   
extern NewPing sonar;

// SD Card
#define CS_PIN 5
extern bool sdCardAvailable;
extern unsigned long lastLogMillis;

// Servo & Relay
#define SERVO_PIN_TABUNG_PAKAN 12
#define RELAY_PIN_AERATOR 16
#define RELAY_PIN_PAKAN 17
extern Servo feedServo;

//Hujan
#define RAIN_SENSOR_ANALOG_PIN 33
#define RAIN_SENSOR_DIGITAL_PIN 13
extern bool isRaining;
extern int rainAnalogValue;

// LCD
constexpr uint8_t LCD_ADDRESS = 0x27;
constexpr uint8_t LCD_COLUMNS = 20;
constexpr uint8_t LCD_ROWS = 4;
extern LiquidCrystal_I2C lcd;

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
extern bool aeratorInDelayMode;
extern bool forceFeedNow;
extern bool forceAeratorNow;

#endif // CONFIG_H
