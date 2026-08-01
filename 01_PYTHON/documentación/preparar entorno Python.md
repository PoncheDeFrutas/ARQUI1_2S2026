# Preparar un entorno Python con pip o uv

Desde la carpeta del proyecto, crea un entorno virtual llamado `.venv`. En Linux puede hacerse con `pip` o con `uv`.

Ambas opciones preparan el mismo tipo de entorno; cambia la herramienta utilizada para instalar y registrar las dependencias.

## Opción 1: pip

`pip` es la herramienta que acompaña a Python. Primero se crea y activa el entorno; después se instalan los paquetes necesarios.

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
```

Si el primer comando indica que falta `venv`, instálalo una vez:

```bash
sudo apt-get install python3-venv
```

Con el entorno activo, instala los paquetes que necesite el proyecto. Por ejemplo:

```bash
python -m pip install RPi.GPIO adafruit-circuitpython-dht
```

Para salir del entorno:

```bash
deactivate
```

## Opción 2: uv

`uv` es una herramienta adicional para gestionar el entorno y las dependencias del proyecto. Comprueba primero que esté instalado:

```bash
uv --version
```

Si no lo está, sigue la [instalación oficial de uv](https://docs.astral.sh/uv/getting-started/installation/). Luego crea y activa el entorno:

```bash
uv venv
source .venv/bin/activate
```

En proyectos que incluyen `pyproject.toml` y `uv.lock`, como este, los paquetes se agregan y el programa se ejecuta así:

```bash
uv add RPi.GPIO adafruit-circuitpython-dht
uv run tu_programa.py
```

`uv run` prepara o reutiliza `.venv` automáticamente; no hace falta activarlo antes.

## Diferencias entre pip y uv

| Aspecto | pip | uv |
| --- | --- | --- |
| Disponible con Python | Sí | No, se instala por separado |
| Crear el entorno | `python3 -m venv .venv` | `uv venv` |
| Instalar paquetes | `python -m pip install paquete` | `uv add paquete` |
| Ejecutar un archivo | `python archivo.py` con el entorno activo | `uv run archivo.py` |
| Archivos del proyecto | No modifica `pyproject.toml` ni `uv.lock` | Actualiza `pyproject.toml` y `uv.lock` |

Vuelve a [GPIO y sensores](./gpio%20y%20sensores.md) para instalar las bibliotecas y conectar el hardware.
