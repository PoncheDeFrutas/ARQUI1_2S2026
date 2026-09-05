import subprocess
import stat
from pathlib import Path

program_path = Path(__file__).parent / "src" / "build" / "00_hello_world"
program_path.chmod(program_path.stat().st_mode | stat.S_IXUSR)

result = subprocess.run(
    [str(program_path)],
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
