#include "data_logger.h"
#include "config.h"

DateTime lastLogDate;
String currentLogFileName = "";

bool initSDCard() {
  sdCardAvailable = SD.begin(CS_PIN);
  if (!sdCardAvailable) {
    Serial.println("Card failed, or not present. Please check");
  } else {
    Serial.println("SD card initialized.");
  }
  return sdCardAvailable;
}

void CreatelogData(DateTime now, float temperature, float salinity, float turbidity, float pH, bool isRaining) {
  if (!sdCardAvailable) {
    // fallback ke Serial
    Serial.println("SD tidak tersedia. Data akan dicetak ke Serial saja.");
    printDataToSerial(now, temperature, salinity, turbidity, pH, isRaining);
    return;
  }

  String fileName = "/data_" + formatDate(now) + ".csv";

  if (fileName != currentLogFileName) {
    currentLogFileName = fileName;
    createNewDailyLogFile(fileName);
  }

  // Tangani millis() overflow
  if (millis() < lastLogMillis) {
    lastLogMillis = 0;
  }

  if (millis() - lastLogMillis >= 60000) {
    lastLogMillis = millis();
    if (!logData(now, temperature, salinity, turbidity, pH, isRaining)) {
      // Jika gagal tulis ke SD → fallback Serial
      printDataToSerial(now, temperature, salinity, turbidity, pH, isRaining);
    }
  }
}

void createNewDailyLogFile(const String &fileName) {
  if (!sdCardAvailable) return;

  File file = SD.open(fileName, FILE_WRITE);
  if (file) {
    if (file.size() == 0) {
      addCSVHeader(file);
    }
    file.close();
  } else {
    Serial.println("Gagal membuat file log harian.");
  }
}

void addCSVHeader(File &file) {
  file.println("Hour,Minute,Temperature,Salinity,Turbidity,pH,Rain");
}

bool logData(DateTime now, float temp, float salinity, float turbidity, float pH, bool isRaining) {
  if (!sdCardAvailable) return false;

  const int MAX_RETRY = 3;
  for (int i = 0; i < MAX_RETRY; i++) {
    File file = SD.open(currentLogFileName, FILE_APPEND);
    if (file) {
      file.print(now.hour());
      file.print(",");
      file.print(now.minute());
      file.print(",");
      file.print(temp, 1);
      file.print(",");
      file.print(salinity, 1);
      file.print(",");
      file.print(turbidity, 1);
      file.print(",");
      file.print(pH, 2);
      file.print(",");
      file.println(isRaining ? "Yes" : "No");
      file.close();
      return true;
    } else {
      Serial.println("Gagal menulis data ke file log, coba ulang...");
      delay(100);
    }
  }
  return false;
}

String formatDate(DateTime now) {
  String day = now.day() < 10 ? "0" + String(now.day()) : String(now.day());
  String month = now.month() < 10 ? "0" + String(now.month()) : String(now.month());
  return String(now.year()) + "-" + month + "-" + day;
}

// Fallback Serial output
void printDataToSerial(DateTime now, float temp, float salinity, float turbidity, float pH, bool isRaining) {
  Serial.print(now.hour());
  Serial.print(":");
  Serial.print(now.minute());
  Serial.print(" - ");
  Serial.print("T=");
  Serial.print(temp);
  Serial.print("C, S=");
  Serial.print(salinity);
  Serial.print("ppt, Turb=");
  Serial.print(turbidity);
  Serial.print("NTU, pH=");
  Serial.print(pH);
  Serial.print(", Rain=");
  Serial.println(isRaining ? "Yes" : "No");
}
