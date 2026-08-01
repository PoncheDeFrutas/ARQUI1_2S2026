# Lección 00: Blink

## Objetivo

Controlar un LED como salida digital.

## Materiales y conexión

- Raspberry Pi, LED y resistencia de 220 Ω a 1 kΩ.
- Ánodo del LED: GPIO18 (pin físico 12), a través de la resistencia.
- Cátodo del LED: GND.

## Ejecutar

```bash
uv run lecciones/00_blink/example_01.py
```

## Resultado esperado

El LED alterna entre encendido y apagado cada segundo. Detén el programa con `Ctrl+C`.

## Nota

El ejemplo usa numeración BCM y libera los GPIO al terminar.
