import subprocess
from pathlib import Path

program_path = Path(__file__).parent / "00_hello_world"

result = subprocess.run(
    [program_path],
    capture_output=True,
    text=True,
)

if result .returncode == 0:
    print("El programa se ejecutó correctamente.")
    print("Salida:")
    print(result.stdout)
else:
    print("Hubo un error al ejecutar el programa.")
    print("Código de salida:", result.returncode)
    print("Error:")
    print(result.stderr)
