#ifndef DATA_LOGGER_H
#define DATA_LOGGER_H

#include "config.h"

bool logData(DateTime now, float temp, float salinity, float turbidity, float pH, bool isRaining);
void CreatelogData(DateTime now, float temperature, float salinity, float turbidity, float pH, bool isRaining);
void createNewDailyLogFile(const String &fileName);
void addCSVHeader(File &file); 
String formatDate(DateTime now);
void printDataToSerial(DateTime now, float temp, float salinity, float turbidity, float pH, bool isRaining);
bool initSDCard();

#endif // DATA_LOGGER_H
