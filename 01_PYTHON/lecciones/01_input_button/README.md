# Lección 01: Botón como entrada

## Objetivo

Leer un botón y cambiar el estado de un LED, evitando rebotes eléctricos.

## Materiales y conexión

- Raspberry Pi, LED, resistencia de 220 Ω a 1 kΩ y botón.
- LED: GPIO18 (pin físico 12), con resistencia hacia GND.
- Botón: GPIO17 (pin físico 11) y GND.

El programa configura `GPIO17` con `PUD_UP`: sin pulsar lee `HIGH`; al pulsar, `LOW`.

## Ejecutar

```bash
uv run lecciones/01_input_button/example_01.py
```

## Ejemplos

- `example_01.py`: sondeo continuo y debounce por tiempo.
- `example_02.py`: detección de flanco mediante callback.
- `example_03.py`: distingue pulsación corta y larga.

## Resultado esperado

Una pulsación cambia el LED de estado. En el tercer ejemplo, una pulsación larga apaga el LED.
