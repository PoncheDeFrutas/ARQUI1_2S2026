import time
from rpi_lcd import LCD

lcd = LCD(0x27, 1, 16, 2, True)

screens = [
    ("Pantalla 1", "Estado: Ok"),
    ("Pantalla 2", "TEMP: 25°C"),
    ("Pantalla 3", "HUM: 60%"),
    ("Pantalla 4", "Presión: 1013 hPa"),
]

try:
    index = 0
    while True:
        screen = screens[index]
        lcd.text(screen[0], 1)
        lcd.text(screen[1], 2)
        time.sleep(5)
        index = (index + 1) % len(screens) # Ciclo a la siguiente pantalla
        lcd.clear()
        time.sleep(3)
except KeyboardInterrupt:
    print("Programa interrumpido por el usuario.")
finally:
    lcd.clear()
