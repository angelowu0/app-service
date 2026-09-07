# app-service/tests/test_app.py
"""Real integration check: start the app as a subprocess, hit /healthz over
HTTP, confirm it responds 200 with the expected payload."""
import subprocess
import sys
import time

import requests

APP_URL = "http://127.0.0.1:8080"


def _start_app():
    proc = subprocess.Popen([sys.executable, "app.py"])
    for _ in range(10):
        try:
            resp = requests.get(f"{APP_URL}/healthz", timeout=1)
            return proc, resp
        except requests.ConnectionError:
            time.sleep(0.5)
    proc.terminate()
    proc.wait(timeout=5)
    raise RuntimeError("app never became reachable on :8080")


def test_healthz_returns_200_and_healthy_status():
    proc, resp = _start_app()
    try:
        assert resp.status_code == 200
        assert resp.json()["status"] == "healthy"
    finally:
        proc.terminate()
        proc.wait(timeout=5)


def test_index_reports_environment():
    proc, _ = _start_app()
    try:
        resp = requests.get(APP_URL, timeout=1)
        body = resp.json()
        assert resp.status_code == 200
        assert body["service"] == "app-service"
        assert "environment" in body
    finally:
        proc.terminate()
        proc.wait(timeout=5)