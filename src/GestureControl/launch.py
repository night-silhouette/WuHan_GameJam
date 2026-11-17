"""Bootstrap an isolated environment and launch the camera module.

From the project root: python src/GestureControl/launch.py
Pass --setup-only to install dependencies and download the model without opening a camera.
Pass --simulate SHOVEL to test Godot communication without CV dependencies.
"""
import os
from pathlib import Path
import subprocess
import sys
import venv


def main():
    folder = Path(__file__).resolve().parent
    args = sys.argv[1:]
    if "--simulate" in args:
        return subprocess.call([sys.executable, str(folder / "gesture_camera.py"), *args])
    env = folder / ".venv"
    python = env / ("Scripts/python.exe" if os.name == "nt" else "bin/python")
    if not python.is_file():
        print("Creating isolated Python environment...", flush=True)
        venv.EnvBuilder(with_pip=True).create(env)
    # Keep Godot from recursively scanning Python packages as game resources.
    (env / ".gdignore").touch()
    marker = env / ".gesture_dependencies"
    requirements = (folder / "requirements.txt").read_text(encoding="utf-8")
    if not marker.is_file() or marker.read_text(encoding="utf-8") != requirements:
        print("Installing camera dependencies (first launch only)...", flush=True)
        subprocess.check_call([str(python), "-m", "pip", "install", "-r", str(folder / "requirements.txt")])
        marker.write_text(requirements, encoding="utf-8")
    if "--setup-only" in args:
        subprocess.check_call([str(python), "-c", "from gesture_camera import get_model; from pathlib import Path; get_model(Path('models/hand_landmarker.task'))"], cwd=str(folder))
        print("Setup complete. Run launch.py without --setup-only to open the camera.", flush=True)
        return 0
    return subprocess.call([str(python), str(folder / "gesture_camera.py"), *args])


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, subprocess.CalledProcessError) as exc:
        print(f"Setup failed: {exc}", file=sys.stderr)
        print("Check your network and Python compatibility, then run launch.py again.", file=sys.stderr)
        raise SystemExit(1)
