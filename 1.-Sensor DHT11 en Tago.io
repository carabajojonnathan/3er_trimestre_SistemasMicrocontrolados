#include <WiFi.h>
#include <HTTPClient.h>
#include "DHT.h"

const char* ssid = "Nombre de la red";
const char* password = "Contraseña";

const char* serverAddress = "https://api.tago.io/data";
const char* tokenHeader = "c7f0e1ee-35fa-40d7-9dd8-d7c0828c4e7f";

HTTPClient client;

#define DHTPIN 5
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);

  WiFi.begin(ssid, password);
  Serial.print("Conectando");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nConectado!");
  Serial.println(WiFi.localIP());

  dht.begin();
}

void loop() {
  delay(15000); // 15 segundos

  float h = dht.readHumidity();
  float t = dht.readTemperature();
  float hic = dht.computeHeatIndex(t, h, false); // índice de calor

  if (isnan(h) || isnan(t)) {
    Serial.println("Error en DHT");
    return;
  }

  // JSON con 3 variables
  String postData = "[";
  postData += "{\"variable\":\"temperatura\",\"value\":" + String(t) + "},";
  postData += "{\"variable\":\"humedad\",\"value\":" + String(h) + "},";
  postData += "{\"variable\":\"indice_calor\",\"value\":" + String(hic) + "}";
  postData += "]";

  client.begin(serverAddress);
  client.addHeader("Content-Type", "application/json");
  client.addHeader("Device-Token", tokenHeader);

  int statusCode = client.POST(postData);

  Serial.print("Codigo HTTP: ");
  Serial.println(statusCode);

  client.end();
}
