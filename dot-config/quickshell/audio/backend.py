"""Bridge profiles, ports and stream routing missing from Quickshell's native API."""
import atexit
import json
import signal
import subprocess
import sys
import threading

lock = threading.Lock()
changed = threading.Event()


def pactl(*args):
    return subprocess.check_output(["pactl", *map(str, args)], text=True, stderr=subprocess.PIPE)


def publish(error=""):
    with lock:
        try:
            groups = {}
            for kind in ("sinks", "sources", "sink-inputs", "source-outputs"):
                items = json.loads(pactl("--format=json", "list", kind))
                groups[kind] = [dict(
                    id=str(item["index"]), name=item.get("name", ""),
                    serial=str(item.get("properties", {}).get("object.serial", "")),
                    device=str(item.get("sink", item.get("source", ""))),
                    ports=[dict(name=p["name"], label=p["description"]) for p in item.get("ports", []) if p.get("availability") != "not available"],
                    port=item.get("active_port", ""),
                ) for item in items if kind != "sources" or not item.get("monitor_source") and item.get("monitor_of_sink") in (None, 4294967295)]
            cards = json.loads(pactl("--format=json", "list", "cards"))
            groups["cards"] = [dict(
                id=str(card["index"]), name=card["name"],
                label=card.get("properties", {}).get("device.description", card["name"]),
                profile=card.get("active_profile", ""),
                profiles=[dict(name=name, label=profile["description"]) for name, profile in card.get("profiles", {}).items()
                          if profile.get("available") not in (False, "no") or name == card.get("active_profile")],
                profileLabel=card.get("profiles", {}).get(card.get("active_profile"), {}).get("description", card.get("active_profile", "")),
            ) for card in cards]
            print(json.dumps(dict(metadata=groups, error=error)), flush=True)
        except (OSError, subprocess.CalledProcessError, ValueError, KeyError) as exc:
            print(json.dumps(dict(error=str(exc))), flush=True)


def watch():
    try:
        process = subprocess.Popen(["pactl", "subscribe"], stdout=subprocess.PIPE, text=True)
        atexit.register(process.terminate)
        for line in process.stdout:
            if any(word in line for word in ("sink", "source", "server", "card")):
                changed.set()
    except OSError as exc:
        print(json.dumps(dict(error=str(exc))), flush=True)


def refresh_changes():
    while changed.wait():
        # Coalesce bursts of PipeWire/Pulse events, including native volume updates.
        threading.Event().wait(0.15)
        changed.clear()
        publish()


threading.Thread(target=refresh_changes, daemon=True).start()
signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
threading.Thread(target=watch, daemon=True).start()
publish()
for line in sys.stdin:
    try:
        request = json.loads(line)
        action = request["action"]
        kind = request.get("kind", "sinks")
        singular = {"sinks": "sink", "sources": "source", "sink-inputs": "sink-input", "source-outputs": "source-output", "cards": "card"}[kind]
        index = str(int(request.get("id", 0)))
        if action == "profile" and kind == "cards":
            pactl("set-card-profile", index, request["value"])
        elif action == "port" and kind in ("sinks", "sources"):
            pactl("set-" + singular + "-port", index, request["value"])
        elif action == "move" and kind in ("sink-inputs", "source-outputs"):
            pactl("move-" + singular, index, str(int(request["value"])))
        publish()
    except (OSError, subprocess.CalledProcessError, ValueError, KeyError) as exc:
        publish(exc.stderr.strip() if isinstance(exc, subprocess.CalledProcessError) else str(exc))
