#!/usr/bin/env python3
import sys
import os
import json
import subprocess


def main(args):
    result = subprocess.run(
        ["rofi", "-dmenu", "-p", "Session name:"],
        stdin=open("/dev/tty"),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    session_name = result.stdout.strip()

    if not session_name:
        print("No session name provided", file=sys.stderr)
        sys.exit(1)

    if not session_name.endswith(".kitty-session"):
        session_name += ".kitty-session"

    base_dir = os.path.expanduser("~/.local/share/kitty/sessions")
    os.makedirs(base_dir, exist_ok=True)
    session_path = os.path.join(base_dir, session_name)

    rc_result = subprocess.run(
        ["kitty", "@", "ls"],
        stdin=open("/dev/tty"),
        capture_output=True,
        text=True,
    )
    state = json.loads(rc_result.stdout)

    if isinstance(state, list):
        if state:
            state = state[0]
        else:
            state = {}

    tabs = state.get("tabs", [])
    lines = []

    for i, tab in enumerate(tabs):
        if i > 0:
            lines.extend(["", "new_tab"])

        windows = tab.get("windows", [])
        for w_idx, w in enumerate(windows):
            if w_idx > 0:
                lines.append("launch")

            layout = w.get("layout", "tall")
            lines.append(f"layout {layout}")

            cwd = w.get("cwd", "")
            if cwd:
                lines.append(f"cd {cwd}")

            cmdline = w.get("cmdline", [])
            if cmdline:
                lines.append(f"launch {' '.join(cmdline)}")

    with open(session_path, "w") as f:
        f.write("\n".join(lines))

    print(f"Session saved to: {session_path}", file=sys.stderr)


if __name__ == "__main__":
    main([])
