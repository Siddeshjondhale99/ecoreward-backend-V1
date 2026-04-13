#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <ESP32Servo.h>

// --- Configuration ---
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const String serverUrl = "https://your-backend-url.onrender.com/iot/device-status?device_id=BIN_001";

// --- Hardware Pins ---
const int servoPin = 18;
const int ledPin = 2; // Internal LED for status

Servo binServo;
int posOpen = 90;
int posClosed = 0;

void setup() {
  Serial.begin(115200);
  pinMode(ledPin, OUTPUT);
  
  // Servo Setup
  binServo.attach(servoPin);
  binServo.write(posClosed);
  
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
    HTTPClient http;
    http.begin(serverUrl);
    
    int httpCode = http.GET();
    
    if (httpCode > 0) {
      String payload = http.getString();
      Serial.println("Polling Status: " + payload);
      
      DynamicJsonDocument doc(256);
      deserializeJson(doc, payload);
      
      const char* status = doc["status"];
      
      if (strcmp(status, "allowed") == 0) {
        Serial.println("ACCESS GRANTED: Opening Bin...");
        openBin();
      } else if (strcmp(status, "denied") == 0) {
        Serial.println("ACCESS DENIED");
        flashLED(3);
      }
    } else {
      Serial.println("Error on HTTP request");
    }
    
    http.end();
  }
  
  delay(3000); // Poll every 3 seconds
}

void openBin() {
  binServo.write(posOpen);
  delay(5000); // Keep open for 5 seconds
  binServo.write(posClosed);
  Serial.println("Bin Closed.");
}

void flashLED(int times) {
  for(int i=0; i<times; i++) {
    digitalWrite(ledPin, HIGH);
    delay(200);
    digitalWrite(ledPin, LOW);
    delay(200);
  }
}
