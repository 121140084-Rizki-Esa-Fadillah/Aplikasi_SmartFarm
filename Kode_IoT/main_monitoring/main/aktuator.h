#ifndef AKTUATOR_H
#define AKTUATOR_H

#include "config.h"

// Fungsi feeder
void handleFeeding();
void activateFeeder(int duration);
void deactivateFeeder();
void checkFeedLevel();
void forceActivateFeeder(); 

// Fungsi aerator
void manageAerator();
void activateAerator();
void deactivateAerator();

// Fungsi tambahan
int readUltrasonicDistance();
void updateRainStatus();

#endif // AKTUATOR_H
