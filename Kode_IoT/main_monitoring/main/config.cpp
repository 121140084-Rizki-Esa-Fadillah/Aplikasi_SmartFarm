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

// NTP Client
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 7 * 3600, 60000); 

// RTC
RTC_DS3231 rtc;
bool rtcAvailable = false;

// Ultrasonik
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE);

// SD Card
#define CS_PIN 5
unsigned long lastLogMillis = 0;
bool sdCardAvailable = false;

// Servo
Servo feedServo;

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


// Jadwal Pakan
FeedingSchedule feedingSchedule[4];
bool isFeeding = false;
bool feedEmpty = false;
int feedingDuration;
DateTime lastFeedingTime;
bool isFeedingFromSchedule = false;
bool feedingDoneToday[4] = { false, false, false, false };
int lastFeedingDay = -1;

// Aerator
int aeratorOnMinutesAfter;
DateTime aeratorOffTimestamp;
bool aeratorInDelayMode = false;  
bool forceFeedNow = false;
bool forceAeratorNow = true;
