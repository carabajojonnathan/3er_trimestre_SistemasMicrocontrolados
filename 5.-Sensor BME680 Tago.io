#include <WiFi.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BME680.h>

// WiFi
const char* ssid = "Red wifi";
const char* password = "clave";

// Token de TagoIO
const char* token = "c7f0e1ee-35fa-40d7-9dd8-d7c0828c4e7f";

Adafruit_BME680 bme; // I2C

void setup() {
  Serial.begin(115200);

  // WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi conectado");

  // Sensor
  if (!bme.begin(0x76)) {
    Serial.println("No se encontró el BME680");
    while (1);
  }

  bme.setTemperatureOversampling(BME680_OS_8X);
  bme.setHumidityOversampling(BME680_OS_2X);
  bme.setPressureOversampling(BME680_OS_4X);
  bme.setGasHeater(320, 150);
}

void loop() {

  if (!bme.performReading()) {
    Serial.println("Error leyendo sensor");
    return;
  }

  float temperature = bme.temperature;
  float humidity = bme.humidity;
  float pressure = bme.pressure / 100.0;
  float gas = bme.gas_resistance / 1000.0;

  Serial.println("Enviando datos...");

  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    http.begin("https://api.tago.io/data");
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Device-Token", token);

    String json = "[";
    json += "{\"variable\":\"temperature\",\"value\":" + String(temperature) + "},";
    json += "{\"variable\":\"humidity\",\"value\":" + String(humidity) + "},";
    json += "{\"variable\":\"pressure\",\"value\":" + String(pressure) + "},";
    json += "{\"variable\":\"gas\",\"value\":" + String(gas) + "}";
    json += "]";

    int httpResponseCode = http.POST(json);

    Serial.println(httpResponseCode);
    Serial.println(json);

    http.end();
  }

  delay(10000); // cada 10 segundos
}
