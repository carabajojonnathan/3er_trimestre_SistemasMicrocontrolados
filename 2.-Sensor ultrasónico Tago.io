#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "RED MECATRONICA";
const char* password = "MECA2026@.";

// Token de TagoIO
String token = "c7f0e1ee-35fa-40d7-9dd8-d7c0828c4e7f";

// Pines
#define TRIG 5
#define ECHO 18

void setup() {
  Serial.begin(115200);

  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);

  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nConectado!");
}

float medirDistancia() {
  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);

  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG, LOW);

  long duracion = pulseIn(ECHO, HIGH);
  float distancia = duracion * 0.034 / 2;

  return distancia;
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    float distancia = medirDistancia();

    Serial.print("Distancia: ");
    Serial.print(distancia);
    Serial.println(" cm");

    http.begin("http://api.tago.io/data");
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Device-Token", token);

    String payload = "{\"variable\":\"distancia\",\"value\":" + String(distancia) + "}";

    int httpResponseCode = http.POST(payload);

    Serial.print("Codigo HTTP: ");
    Serial.println(httpResponseCode);

    http.end();
  } else {
    Serial.println("WiFi desconectado");
  }

  delay(5000); // cada 5 segundos
}
