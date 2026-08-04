import time
import board
import adafruit_dht

# void setup()
DHT_PIN = board.D20  # Pin GPIO conectado al sensor DHT11
sensor = adafruit_dht.DHT11(DHT_PIN)

last_read_time = 0  # Variable para almacenar el tiempo de la última lectura
read_interval = 2   # Intervalo de lectura en segundos

# void loop()
try:
    while True:
        try:
            current_time = time.time()

            if current_time - last_read_time >= read_interval:
                temperature_c = sensor.temperature
                humidity = sensor.humidity
                last_read_time = current_time   # Actualiza el tiempo de la última lectura

                if temperature_c is None or humidity is None:
                    print("Error al leer el sensor DHT11")
                else:
                    print(f"Temperatura: {temperature_c:.1f} °C")
                    print(f"Humedad: {humidity:.1f} %")

        except RuntimeError as e:
            print(f"Error al leer el sensor DHT11: {e}")
        time.sleep(0.2)
except KeyboardInterrupt:
    print("Programa interrumpido por el usuario")
finally:
    sensor.exit()  # Cierra el sensor DHT11
