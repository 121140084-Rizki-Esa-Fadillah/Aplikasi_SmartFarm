#include "data_logger.h"
#include "config.h"

DateTime lastLogDate;

String currentLogFileName = "";

// Fungsi untuk menulis data ke file CSV harian
void logDataIfNeeded(DateTime now, float temperature, float salinity, float turbidity, float pH, bool isRaining) {
  String fileName = "/data_" + formatDate(now) + ".csv";

  // Cek apakah file berubah (hari berganti atau reboot)
  if (fileName != currentLogFileName) {
    currentLogFileName = fileName;
    createNewDailyLogFile(fileName);
  }

  // Logging setiap 1 menit
  if (millis() - lastLogMillis >= 60000) {
    lastLogMillis = millis();
    logData(now, temperature, salinity, turbidity, pH, isRaining);
  }
}

// Membuat file baru jika belum ada, atau mengecek apakah perlu header
void createNewDailyLogFile(const String &fileName) {
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

// Tambahkan header CSV
void addCSVHeader(File &file) {
  file.println("Hour,Minute,Temperature,Salinity,Turbidity,pH,Rain");
}

// Menulis data ke file log harian
void logData(DateTime now, float temp, float salinity, float turbidity, float pH, bool isRaining) {
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
  } else {
    Serial.println("Gagal menulis data ke file log harian.");
  }
}

// Format tanggal: yyyy-mm-dd
String formatDate(DateTime now) {
  String day = now.day() < 10 ? "0" + String(now.day()) : String(now.day());
  String month = now.month() < 10 ? "0" + String(now.month()) : String(now.month());
  return String(now.year()) + "-" + month + "-" + day;
}
