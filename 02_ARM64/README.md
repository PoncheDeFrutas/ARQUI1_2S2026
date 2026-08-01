# ARM64: QEMU y Raspberry Pi

Esta carpeta incluye lo necesario para compilar y depurar ejemplos de
ensamblador ARM64. Se puede trabajar con QEMU en la computadora o directamente
en una Raspberry Pi.

| Opción | Cuándo usarla |
| --- | --- |
| QEMU | Para trabajar desde una computadora que no es ARM64 o para probar sin una Raspberry Pi. |
| Raspberry Pi | Para ejecutar el programa en una Raspberry Pi 3 o 4 con Raspberry Pi OS de 64 bits. |

Cada Makefile recibe el archivo `.s` que quieres compilar y deja el resultado
en `build/`, conservando su ruta. Por ejemplo,
`src/00_hello_world.s` genera `build/src/00_hello_world`.

## Requisitos comunes

- VS Code 1.110 o superior.
- Extensiones recomendadas por el proyecto: **C/C++**, **StackScope** y
  **ARM64**. VS Code las sugerirá al abrir la carpeta.
- Abre la carpeta raíz del proyecto, no solo la carpeta `src`.

Los ejemplos usan llamadas al sistema Linux de AArch64.

## QEMU en la computadora

Para empezar sin una Raspberry Pi, instala estas herramientas en Debian,
Ubuntu o un derivado:

```sh
sudo apt install make binutils-aarch64-linux-gnu qemu-user gdb-multiarch
```

Desde la raíz del proyecto:

```sh
make -f Makefile.qemu SRC=src/00_hello_world.s run
```

En VS Code, abre el archivo `.s` que quieras probar y usa:

- **Terminal -> Run Task -> ARM64 QEMU: ejecutar archivo activo** para compilar
  y ejecutar.
- El perfil **Depurar ARM64 con QEMU** y F5 para depurar.

Al iniciar la depuración, QEMU queda esperando en el puerto local `1234`.
VS Code se conecta con `gdb-multiarch` y se detiene en `_start` antes de la
primera instrucción.

## Raspberry Pi

Para trabajar directamente en una Raspberry Pi 3 o 4, usa Raspberry Pi OS de
64 bits y abre el proyecto mediante **Remote - SSH**. Así, el ensamblador,
el enlazador, GDB y el programa se ejecutan en la Pi.

En la terminal de la Raspberry instala las herramientas necesarias:

```sh
sudo apt update
sudo apt install make binutils gdb
```

Luego:

1. Activa SSH en la Raspberry y conéctala a la red.
2. En VS Code de tu computadora instala **Remote - SSH** y usa
   `Remote-SSH: Connect to Host...` para entrar como, por ejemplo,
   `pi@raspberrypi.local`.
3. Abre la carpeta del proyecto dentro de la sesión remota. En la esquina
   inferior izquierda de VS Code verás la conexión SSH activa.
4. Instala las extensiones recomendadas cuando VS Code lo solicite. Verifica
   que **C/C++** esté instalada en la Raspberry.

Con un archivo `.s` abierto:

- Ejecuta la tarea **ARM64 Raspberry Pi: ejecutar archivo activo**.
- Para depurar, elige **Depurar ARM64 en Raspberry Pi** y presiona F5.

La configuración compila con `Makefile.arm64`, inicia `/usr/bin/gdb` en la
Raspberry y se detiene en `_start`.

También se puede trabajar desde la terminal remota:

```sh
make -f Makefile.arm64 SRC=src/00_hello_world.s run
```

## StackScope

StackScope consulta la memoria mediante la sesión de depuración de **C/C++**
(`cppdbg`). La ejecución debe estar detenida en un breakpoint, en `_start` o
después de avanzar una instrucción.

1. Inicia uno de los dos perfiles de depuración con F5.
2. Cuando la ejecución se detenga, abre `StackScope: Open Memory View` desde
   la paleta de comandos.
3. Prueba expresiones como `$sp`, `$pc`, `$lr` o una dirección como
   `0x400000`.

Los registros, la pila, la memoria y el desensamblado aparecen desde el
depurador activo. La cantidad de watchpoints depende de los recursos de
hardware disponibles en QEMU o en la Raspberry.

## Limpiar resultados

Los ejecutables, objetos y dependencias se guardan en `build/`. Para borrarlos:

```sh
make -f Makefile.qemu clean
# o, en la Raspberry:
make -f Makefile.arm64 clean
```

## Problemas frecuentes

**El ejecutable no corre en la Raspberry**

Revisa que la Pi use un sistema operativo de 64 bits y que `binutils` esté
instalado. Un sistema de 32 bits no puede ejecutar binarios AArch64.

**QEMU no permite iniciar el depurador**

El puerto `1234` ya puede estar ocupado. Detén una sesión de depuración previa
o identifica el proceso que lo está usando antes de volver a iniciar F5.

**El perfil de Raspberry busca GDB en la computadora**

La carpeta se abrió localmente. Conéctate primero por Remote-SSH y vuelve a
abrir el proyecto desde la Raspberry.

**StackScope no muestra memoria**

Confirma que hay una sesión de depuración activa y detenida. Ejecutar la tarea
normal no inicia un depurador.
