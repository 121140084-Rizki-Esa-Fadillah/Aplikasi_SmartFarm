#ifndef DATA_LOGGER_H
#define DATA_LOGGER_H

#include "config.h"


void logData(DateTime now, float temperature, float salinity, float turbidity, float pH, bool isRaining);
void logDataIfNeeded(DateTime now, float temperature, float salinity, float turbidity, float pH, bool isRaining);
void createNewDailyLogFile(const String &fileName);
void addCSVHeader(File &file); 
String formatDate(DateTime now);


#endif // DATA_LOGGER_H
