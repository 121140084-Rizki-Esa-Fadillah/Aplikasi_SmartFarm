#include "display.h"
#include "config.h"

// Variabel untuk kontrol tampilan bergantian
unsigned long lastDisplaySwitchTime = 0;
int displayState = 0;

const unsigned long DISPLAY_DURATION_DEFAULT = 50000;
const unsigned long DISPLAY_DURATION_WARNING = 10000;

// === Fungsi Sub-Display ===
void showSensorData(float temperature, float salinity, float turbidity, float pH) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Temp: ");
  lcd.print(temperature, 1);
  lcd.print("C   ");  // Tambah spasi ekstra untuk hapus sisa

  lcd.setCursor(0, 1);
  lcd.print("Sal: ");
  lcd.print(salinity, 1);
  lcd.print("ppt ");  // Tambah spasi ekstra

  lcd.setCursor(0, 2);
  lcd.print("Turb: ");
  lcd.print(turbidity, 1);
  lcd.print("NTU ");  // Tambah spasi ekstra

  lcd.setCursor(0, 3);
  lcd.print("pH: ");
  lcd.print(pH, 2);
  lcd.print("   ");  // Tambah spasi ekstra
}

void showRainStatus(float rainAnalogValue) {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Cuaca: Hujan");

  lcd.setCursor(0, 1);
  lcd.print("Intensitas: ");
  if (rainAnalogValue > 1500) {
    lcd.print("Deras");
  } else if (rainAnalogValue > 1000) {
    lcd.print("Sedang");
  } else {
    lcd.print("Ringan");
  }
}

void showFeedWarning() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Pakan udang hampir");
  lcd.setCursor(0, 1);
  lcd.print("habis! Harap isi");
  lcd.setCursor(0, 2);
  lcd.print("ulang pakan");
}

void showFeedingMessage() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Pakan sedang");
  lcd.setCursor(0, 1);
  lcd.print("diberikan...");
}

// === Fungsi Utama Display ===
void updateDisplay(float rainAnalogValue, float temperature, float salinity, float turbidity, float pH,
                   bool isFeeding, bool feedEmpty, bool isRaining) {
  static unsigned long currentMillis;
  currentMillis = millis();

  // PRIORITAS 1: Pakan sedang diberikan
  if (isFeeding && !feedEmpty) {
    showFeedingMessage();
    return;
  }

  // PRIORITAS 2: Tampilan bergilir jika feedEmpty atau hujan
  if (feedEmpty || isRaining) {
    if (currentMillis - lastDisplaySwitchTime > (
        displayState == 0 ? DISPLAY_DURATION_DEFAULT : DISPLAY_DURATION_WARNING)) {

      // Rotasi state tampilan
      displayState++;
      if (!feedEmpty && displayState == 2) displayState = 0;
      if (!isRaining && displayState == 1) displayState = (feedEmpty ? 2 : 0);
      if (displayState > 2) displayState = 0;

      lastDisplaySwitchTime = currentMillis;
      
      // Menghapus teks di baris yang sebelumnya digunakan, bukan seluruh layar
      lcd.setCursor(0, 0);
      lcd.print("                ");  // Hapus baris pertama
      lcd.setCursor(0, 1);
      lcd.print("                ");  // Hapus baris kedua
      lcd.setCursor(0, 2);
      lcd.print("                ");  // Hapus baris ketiga
      lcd.setCursor(0, 3);
      lcd.print("                ");  // Hapus baris keempat
    }

    switch (displayState) {
      case 0:
        showSensorData(temperature, salinity, turbidity, pH);
        break;
      case 1:
        showRainStatus(rainAnalogValue);
        break;
      case 2:
        showFeedWarning();
        break;
    }

    return;
  }

  // PRIORITAS 3: Default sensor view
  showSensorData(temperature, salinity, turbidity, pH);
  displayState = 0;
  lastDisplaySwitchTime = currentMillis;
}

void updateLEDIndicators(float temperature, float salinity, float turbidity, float pH) {
  byte shiftData = 0b00000000;

  // Temperature
  if (temperature < temperatureLow || temperature > temperatureHigh)
    shiftData |= 0b00000010;  // LED Merah untuk suhu (bit 1)
  else
    shiftData |= 0b00000001;  // LED Hijau untuk suhu (bit 0)

  // Salinity
  if (salinity < salinityLow || salinity > salinityHigh)
    shiftData |= 0b00001000;  // LED Merah untuk salinitas (bit 3)
  else
    shiftData |= 0b00000100;  // LED Hijau untuk salinitas (bit 2)

  // Turbidity
  if (turbidity < turbidityLow || turbidity > turbidityHigh)
    shiftData |= 0b00100000;  // LED Merah untuk turbidity (bit 5)
  else
    shiftData |= 0b00010000;  // LED Hijau untuk turbidity (bit 4)

  // pH
  if (pH < pHLow || pH > pHHigh)
    shiftData |= 0b10000000;  // LED Merah untuk pH (bit 7)
  else
    shiftData |= 0b01000000;  // LED Hijau untuk pH (bit 6)

  updateShiftRegister(shiftData);
}

void updateShiftRegister(byte data) {
  digitalWrite(STCP_PIN, LOW);
  shiftOut(DS_PIN, SHCP_PIN, MSBFIRST, data);
  digitalWrite(STCP_PIN, HIGH);
}
