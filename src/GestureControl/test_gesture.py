"""Unit tests for gesture rules, stability filtering and UDP transport."""
import json
from pathlib import Path
import socket
import sys
import unittest
from types import SimpleNamespace as Point

sys.path.insert(0, str(Path(__file__).parent))
from gesture_camera import StableGesture, angle, classify, send


def hand(extended, thumb=False):
    points = [Point(x=0.0, y=0.0, z=0.0) for _ in range(21)]
    points[1] = Point(x=-0.4, y=0.2, z=0)
    points[2] = Point(x=-0.7, y=0.4, z=0)
    points[3] = Point(x=-1.0, y=0.6, z=0)
    points[4] = Point(x=-1.6, y=1.0, z=0) if thumb else Point(x=-0.5, y=1.0, z=0)
    for i, base in enumerate((5, 9, 13, 17)):
        x = -0.6+i*0.4
        points[base] = Point(x=x, y=1, z=0)
        points[base+1] = Point(x=x, y=1.5, z=0)
        points[base+2] = Point(x=x, y=1.8 if extended[i] else 1.2, z=0)
        points[base+3] = Point(x=x, y=2.1 if extended[i] else 0.9, z=0)
    return points


class GestureTests(unittest.TestCase):
    def test_mapping(self):
        self.assertEqual(classify(hand([False]*4)), "SHOVEL")
        self.assertEqual(classify(hand([False]*4, True)), "NORMAL")
        self.assertEqual(classify(hand([True, True, False, False])), "SICKLE")
        self.assertEqual(classify(hand([True]*4, True)), "WATERING_CAN")
        self.assertIsNone(classify(hand([True, False, False, False])))

    def test_rotated_hand(self):
        points = hand([True, True, False, False])
        rotated = [Point(x=-p.y, y=p.x, z=p.z) for p in points]
        self.assertEqual(classify(rotated), "SICKLE")

    def test_degenerate_angle(self):
        p = Point(x=0,y=0,z=0)
        self.assertEqual(angle(p,p,p), 0)

    def test_hold_and_reset(self):
        stable = StableGesture(0.45)
        self.assertIsNone(stable.update("SHOVEL", 0))
        self.assertIsNone(stable.update("SHOVEL", 0.44))
        self.assertEqual(stable.update("SHOVEL", 0.46), "SHOVEL")
        self.assertIsNone(stable.update("SICKLE", 0.5))
        self.assertIsNone(stable.update(None, 0.6))
        self.assertIsNone(stable.update("SICKLE", 0.7))
        self.assertEqual(stable.update("SICKLE", 1.2), "SICKLE")

    def test_local_packet(self):
        with socket.socket(socket.AF_INET,socket.SOCK_DGRAM) as receiver:
            receiver.bind(("127.0.0.1",0))
            receiver.settimeout(2)
            with socket.socket(socket.AF_INET,socket.SOCK_DGRAM) as sender:
                send(sender,receiver.getsockname()[1],"SHOVEL")
            packet,_ = receiver.recvfrom(1024)
            self.assertEqual(json.loads(packet), {"version":1,"tool":"SHOVEL","status":"tracking"})


if __name__ == "__main__":
    unittest.main()
