# importación de clases
import time
import random
from Globals import shared

class Sensores:
    def __init__(self):
        # agregar y clasificar las lecturas
        self.last_read_time = 0
        self.read_interval = 2

    def setup(self):
        pass
        # configuracion principal de los sensores
        # DHT_PIN = board.D20
        # self.sensor = adafruit_dht.DHT11(DHT_PIN)

    def read(self):
        current_time = time.time()

        if current_time - self.last_read_time >= self.read_interval:
            shared.temperature = random.randint(20, 30)
            shared.humidity = random.randint(40, 60)
            self.last_read_time = current_time

        # agregar mas sensores.
