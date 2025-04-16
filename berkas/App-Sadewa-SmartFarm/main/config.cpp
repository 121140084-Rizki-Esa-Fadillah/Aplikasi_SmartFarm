#include "config.h"

// Wi-Fi
const char* ssid = "realme";
const char* password = "12345678";

// Firebase
FirebaseData firebaseData;
FirebaseConfig firebaseConfig;
FirebaseAuth firebaseAuth;
FirebaseJson Json;

// NTP Client
WiFiUDP udp;
NTPClient timeClient(udp, "pool.ntp.org", 0, 60000);

// Sensor suhu
OneWire oneWire(TEMPERATURE_SENSOR_PIN);
DallasTemperature sensors(&oneWire);

// Ultrasonik
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);

// Servo
Servo feedServo;

// RTC
RTC_DS3231 rtc;

// SD Card
bool sdCardAvailable = false;
unsigned long lastLogMillis;

// Hujan
bool isRaining = false;
int rainAnalogValue;

// LCD
LiquidCrystal_I2C lcd(LCD_ADDRESS, LCD_COLUMNS, LCD_ROWS);

// Treshold Sensor
float temperatureLow, pHLow, salinityLow, turbidityLow;
float temperatureHigh, pHHigh, salinityHigh, turbidityHigh;

// Sensor Value
float temperature, pH, salinity, turbidity;

// Flags
bool AeratorEnabled = true; 
bool PakanUdangEnabled = false;

// Jadwal Pakan
FeedingSchedule feedingSchedule[4];
bool isFeeding = false;
bool feedEmpty = false;
int feedingDuration;
DateTime lastFeedingTime;
bool isFeedingFromSchedule = false;

// Aerator
int aeratorOnMinutesAfter;
DateTime aeratorOffTimestamp;
bool isAeratorOn = true;
