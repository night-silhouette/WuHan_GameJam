"""Local webcam gesture input for Godot. Frames never leave this computer.

Run: python gesture_camera.py
Test without camera: python gesture_camera.py --simulate SHOVEL
First real run downloads Google's hand landmark model (not camera frames).
"""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
import socket
import sys
import time
import urllib.request
import os
import threading


def watch_parent(pid):
    """Exit even when Godot is stopped forcibly by the editor debugger."""
    if pid <= 0:
        return
    def monitor():
        if os.name == "nt":
            import ctypes
            from ctypes import wintypes
            kernel = ctypes.WinDLL("kernel32", use_last_error=True)
            kernel.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
            kernel.OpenProcess.restype = wintypes.HANDLE
            kernel.WaitForSingleObject.argtypes = [wintypes.HANDLE, wintypes.DWORD]
            kernel.WaitForSingleObject.restype = wintypes.DWORD
            kernel.CloseHandle.argtypes = [wintypes.HANDLE]
            handle = kernel.OpenProcess(0x00100000, False, pid)
            if not handle:
                os._exit(0)
            kernel.WaitForSingleObject(handle, 0xFFFFFFFF)
            kernel.CloseHandle(handle)
            os._exit(0)
        else:
            while True:
                try:
                    os.kill(pid, 0)
                except ProcessLookupError:
                    os._exit(0)
                threading.Event().wait(0.5)
    threading.Thread(target=monitor, daemon=True).start()

MODEL_URL = "https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task"
TOOLS = ("NORMAL", "SHOVEL", "SICKLE", "WATERING_CAN")


def angle(a, b, c):
    u = (a.x - b.x, a.y - b.y, a.z - b.z)
    v = (c.x - b.x, c.y - b.y, c.z - b.z)
    length = math.sqrt(sum(x*x for x in u) * sum(x*x for x in v))
    if length < 1e-10:
        return 0.0
    cosine = max(-1.0, min(1.0, sum(x*y for x, y in zip(u, v)) / length))
    return math.degrees(math.acos(cosine))


def distance(a, b):
    return math.sqrt((a.x-b.x)**2 + (a.y-b.y)**2 + (a.z-b.z)**2)


def classify(points):
    """Conservative joint-angle rules. Unknown/intermediate poses return None.

    Coordinates are normalized into image-aspect-correct space before this call.
    Thumb direction is unrestricted: Thumb_Up here means an extended thumb and
    four folded fingers, avoiding dependence on mirrored/rotated camera images.
    """
    extended = []
    folded = []
    for base in (5, 9, 13, 17):
        pip_angle = angle(points[base], points[base+1], points[base+3])
        dip_angle = angle(points[base+1], points[base+2], points[base+3])
        farther = distance(points[base+3], points[0]) > distance(points[base+1], points[0]) * 1.08
        extended.append(pip_angle > 155 and dip_angle > 150 and farther)
        folded.append(pip_angle < 125 or distance(points[base+3], points[0]) < distance(points[base+1], points[0]) * 0.95)
    palm = distance(points[5], points[17])
    thumb_open = (angle(points[1], points[2], points[4]) > 150
                  and distance(points[4], points[5]) > palm * 0.65)
    thumb_closed = distance(points[4], points[5]) < palm * 0.60
    if all(extended) and thumb_open:
        return "SHOVEL"
    if extended[0] and extended[1] and folded[2] and folded[3]:
        return "SICKLE"
    if all(folded):
        if thumb_open:
            return "NORMAL"
        if thumb_closed:
            return "WATERING_CAN"
    return None


class StableGesture:
    def __init__(self, hold=0.45):
        self.hold = hold
        self.candidate = None
        self.since = 0.0

    def update(self, candidate, now):
        if candidate != self.candidate:
            self.candidate = candidate
            self.since = now
        if candidate is not None and now - self.since >= self.hold:
            return candidate
        return None

    def progress(self, now):
        if self.candidate is None:
            return 0.0
        return min(1.0, (now-self.since)/self.hold)


def send(sock, port, tool, status="tracking"):
    packet = {"version": 1, "tool": tool, "status": status}
    sock.sendto(json.dumps(packet).encode("utf-8"), ("127.0.0.1", port))


def get_model(path):
    if path.is_file():
        return
    print("First run: downloading the MediaPipe hand model from Google. Camera images are NOT uploaded.")
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(".download")
    try:
        with urllib.request.urlopen(MODEL_URL, timeout=60) as source, temporary.open("wb") as target:
            while chunk := source.read(1024 * 1024):
                target.write(chunk)
        temporary.replace(path)
    except Exception:
        temporary.unlink(missing_ok=True)
        raise


def run_camera(args, sock):
    # Delayed imports allow simulation and unit tests without CV dependencies.
    try:
        import cv2
        import mediapipe as mp
        from mediapipe.tasks import python
        from mediapipe.tasks.python import vision
    except ImportError as exc:
        raise RuntimeError("Missing CV dependency. Run: python -m pip install -r requirements.txt. "
                           "If your Python version has no compatible wheel, use Python 3.11 or 3.12.") from exc
    model = Path(args.model)
    get_model(model)
    options = vision.HandLandmarkerOptions(
        base_options=python.BaseOptions(model_asset_path=str(model)),
        running_mode=vision.RunningMode.VIDEO,
        num_hands=1,
        min_hand_detection_confidence=0.65,
        min_hand_presence_confidence=0.65,
        min_tracking_confidence=0.65,
    )
    capture = cv2.VideoCapture(args.camera)
    if not capture.isOpened():
        capture.release()
        raise RuntimeError("Cannot open camera. Check Windows camera permissions, close other camera apps, or try --camera 1.")
    stable = StableGesture(args.hold)
    last_send = 0.0
    last_timestamp = -1
    failures = 0
    connections = ((0,1),(1,2),(2,3),(3,4),(0,5),(5,6),(6,7),(7,8),
                   (5,9),(9,10),(10,11),(11,12),(9,13),(13,14),(14,15),
                   (15,16),(13,17),(0,17),(17,18),(18,19),(19,20))
    try:
        with vision.HandLandmarker.create_from_options(options) as detector:
            print("Camera started. Fist=WATERING_CAN, V=SICKLE, open palm=SHOVEL, thumb=NORMAL.")
            while True:
                ok, frame = capture.read()
                if not ok:
                    failures += 1
                    stable.update(None, time.monotonic())
                    if failures >= 15:
                        raise RuntimeError("Camera stopped delivering frames.")
                    time.sleep(0.03)
                    continue
                failures = 0
                frame = cv2.flip(frame, 1)
                height, width = frame.shape[:2]
                image = mp.Image(image_format=mp.ImageFormat.SRGB, data=cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
                now = time.monotonic()
                timestamp = max(last_timestamp + 1, int(now * 1000))
                last_timestamp = timestamp
                result = detector.detect_for_video(image, timestamp)
                candidate = None
                if result.hand_landmarks:
                    landmarks = result.hand_landmarks[0]
                    # MediaPipe x/z are width-normalized, y is height-normalized.
                    from types import SimpleNamespace
                    points = [SimpleNamespace(x=p.x, y=p.y*height/width, z=p.z) for p in landmarks]
                    candidate = classify(points)
                    if args.preview:
                        pixels = [(int(p.x*width), int(p.y*height)) for p in landmarks]
                        for a,b in connections:
                            cv2.line(frame, pixels[a], pixels[b], (70,180,70), 2)
                        for p in pixels:
                            cv2.circle(frame, p, 4, (30,100,230), -1)
                confirmed = stable.update(candidate, now)
                # Heartbeat repeats only a stable pose. Godot deduplicates switches.
                if now-last_send >= 0.1:
                    send(sock, args.port, confirmed, "tracking" if candidate else "no_gesture")
                    last_send = now
                if args.preview:
                    text = f"Pose: {candidate or 'unknown'}  Hold: {stable.progress(now):.0%}"
                    cv2.putText(frame, text, (15,30), cv2.FONT_HERSHEY_SIMPLEX, 0.65, (255,255,255), 2)
                    cv2.putText(frame, "Fist: water | V: sickle | Palm: shovel | Thumb: normal", (15,58), cv2.FONT_HERSHEY_SIMPLEX, 0.47, (255,255,255), 1)
                    cv2.imshow("Gesture Control - Q to quit", frame)
                    key = cv2.waitKey(1) & 0xff
                    if key in (ord("q"), 27) or cv2.getWindowProperty("Gesture Control - Q to quit", cv2.WND_PROP_VISIBLE) < 1:
                        break
    finally:
        capture.release()
        if args.preview:
            cv2.destroyAllWindows()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--preview", action="store_true", help="Show a camera window for debugging; hidden by default")
    parser.add_argument("--camera", type=int, default=0)
    parser.add_argument("--port", type=int, default=47823)
    parser.add_argument("--hold", type=float, default=0.45)
    parser.add_argument("--model", default=str(Path(__file__).parent / "models" / "hand_landmarker.task"))
    parser.add_argument("--simulate", choices=TOOLS, help="Send a tool for 2 seconds without opening the camera")
    parser.add_argument("--parent-pid", type=int, default=0, help="Exit automatically when the owning game stops")
    args = parser.parse_args()
    watch_parent(args.parent_pid)
    if args.hold <= 0 or not 1 <= args.port <= 65535:
        parser.error("--hold must be positive and --port must be 1..65535")
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        try:
            if args.simulate:
                print(f"Sending {args.simulate} to 127.0.0.1:{args.port}")
                for _ in range(20):
                    send(sock, args.port, args.simulate)
                    time.sleep(0.1)
            else:
                run_camera(args, sock)
        except KeyboardInterrupt:
            pass
        except Exception as exc:
            print(f"Gesture control failed: {exc}", file=sys.stderr)
            return 1
        finally:
            send(sock, args.port, None, "offline")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
