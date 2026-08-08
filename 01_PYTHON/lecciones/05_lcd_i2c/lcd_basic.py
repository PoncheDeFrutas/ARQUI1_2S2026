import time
from rpi_lcd import LCD

lcd = LCD(0x27, 1, 16, 2, True)

try:
    lcd.text("Hola Mundo!", 1)
    lcd.text("LCD I2C", 2)
finally:
    lcd.clear()
