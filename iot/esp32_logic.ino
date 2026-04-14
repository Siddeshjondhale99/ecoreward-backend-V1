#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>
#include "HX711.h"

// --- Configuration ---
const char* ssid = "moto g45 5G_9855";
const char* password = "password";
// Change this to your live Render/Railway URL
const String baseUrl = "https://eco-backend-jfn4.onrender.com/iot"; 

// --- Hardware Pins ---
const int servoPin = 18;
const int hx711_dt = 32;
const int hx711_sck = 33;
const int moisturePin = 34; // Analog pin
const int ledPin = 2; 

// --- Objects ---
Servo binServo;
HX711 scale;
float calibration_factor = -7050.0; // Adjust this based on your load cell

void setup() {
  Serial.begin(115200);
  pinMode(ledPin, OUTPUT);
  pinMode(moisturePin, INPUT);
  
  // Servo Setup
  binServo.attach(servoPin);
  binServo.write(0); // Closed
  
  // HX711 Setup
  scale.begin(hx711_dt, hx711_sck);
  scale.set_scale(calibration_factor);
  scale.tare(); // Assuming bin is empty on startup
  
  // WiFi Setup
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    digitalWrite(ledPin, !digitalRead(ledPin));
  }
  Serial.println("\nConnected to WiFi!");
  digitalWrite(ledPin, HIGH);
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    pollDeviceStatus();
  }
  delay(2000); // Poll every 2 seconds
}

void pollDeviceStatus() {
  WiFiClientSecure client;
  client.setInsecure(); // Important: Required to connect to Render (HTTPS)
  
  HTTPClient http;
  String url = baseUrl + "/device-status?device_id=BIN_001";
  
  Serial.print("Polling URL: "); Serial.println(url);
  
  if (http.begin(client, url)) {
    int httpCode = http.GET();
    Serial.print("HTTP Response Code: "); Serial.println(httpCode);
    
    if (httpCode == 200) {
      String payload = http.getString();
      Serial.println("Response: " + payload);
      
      DynamicJsonDocument doc(256);
      deserializeJson(doc, payload);
      
      const char* status = doc["status"];
      if (strcmp(status, "allowed") == 0) {
        handleAccessGranted();
      }
    } else {
      Serial.print("Request failed, error: ");
      Serial.println(http.errorToString(httpCode).c_str());
    }
    http.end();
  } else {
    Serial.println("Unable to connect to server");
  }
}

void handleAccessGranted() {
  Serial.println(">>> ACCESS GRANTED: Opening Bin...");
  binServo.write(90); // Open
  
  // Give user time to drop waste (10 seconds)
  Serial.println("Waiting for waste drop...");
  delay(10000); 
  
  // Take measurements
  float weight = scale.get_units(10); // Average of 10 readings
  if (weight < 0) weight = 0; // Handle noise
  
  int rawMoisture = analogRead(moisturePin);
  float moisturePercent = map(rawMoisture, 4095, 0, 0, 100); // 4095 is dry, 0 is wet
  
  Serial.print("Measured Weight: "); Serial.print(weight); Serial.println(" kg");
  Serial.print("Measured Moisture: "); Serial.print(moisturePercent); Serial.println(" %");

  // Close Bin
  binServo.write(0);
  Serial.println("Bin Closed. Reporting to Cloud...");
  
  reportMeasurements(weight, moisturePercent);
}

void reportMeasurements(float weight, float moisture) {
  HTTPClient http;
  http.begin(baseUrl + "/report-measurements");
  http.addHeader("Content-Type", "application/json");
  
  StaticJsonDocument<200> doc;
  doc["device_id"] = "BIN_001";
  doc["weight"] = weight;
  doc["moisture"] = moisture;
  doc["waste_type"] = "recyclable"; // Placeholder: AI might override this on backend
  
  String requestBody;
  serializeJson(doc, requestBody);
  
  int httpCode = http.POST(requestBody);
  if (httpCode > 0) {
    Serial.println("Report Success: " + http.getString());
  } else {
    Serial.println("Report Failed.");
  }
  http.end();
}
