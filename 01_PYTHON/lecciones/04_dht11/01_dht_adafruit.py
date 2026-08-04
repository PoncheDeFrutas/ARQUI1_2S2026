import time
import board
import adafruit_dht

# void setup()
DHT_PIN = board.D20  # Pin GPIO conectado al sensor DHT11
sensor = adafruit_dht.DHT11(DHT_PIN)

# void loop()
try:
    while True:
        try:
            temperature_c = sensor.temperature
            humidity = sensor.humidity

            if temperature_c is None or humidity is None:
                print("Error al leer el sensor DHT11")
            else:
                print(f"Temperatura: {temperature_c:.1f} °C")
                print(f"Humedad: {humidity:.1f} %")
        except RuntimeError as e:
            print(f"Error al leer el sensor DHT11: {e}")
        time.sleep(2)  # Espera 2 segundos entre lecturas
except KeyboardInterrupt:
    print("Programa interrumpido por el usuario")
finally:
    sensor.exit()  # Cierra el sensor DHT11
