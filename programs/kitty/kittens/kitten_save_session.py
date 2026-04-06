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
            lines.append("")

        # new_tab with title if present
        title = tab.get("title", "")
        if title:
            lines.append(f"new_tab {title}")
        else:
            lines.append("new_tab")

        windows = tab.get("windows", [])

        # Filter out kitten windows first
        valid_windows = []
        for w in windows:
            cmdline = w.get("cmdline", [])
            cmdline_str = " ".join(cmdline) if cmdline else ""
            # Skip the save kitten's own process
            if "kitten_save_session.py" not in cmdline_str:
                valid_windows.append(w)

        # Write layout once per tab, from first valid window
        if valid_windows:
            layout = valid_windows[0].get("layout", "tall")
            lines.append(f"layout {layout}")

        # Write all valid windows
        for w in valid_windows:
            cwd = w.get("cwd", "")
            if cwd:
                lines.append(f"cd {cwd}")

            # Determine what command to launch
            cmd_to_launch = None

            # Try to get the actual running process from foreground_processes
            fg_processes = w.get("foreground_processes", [])
            if fg_processes:
                fg_cmd = fg_processes[0].get("cmdline", [])
                if fg_cmd:
                    # Filter out shell processes
                    fg_exe = fg_cmd[0].split("/")[-1] if fg_cmd else ""
                    if fg_exe not in ("zsh", "bash", "sh", "fish", "ksh"):
                        # It's a real program, use it
                        cmd_to_launch = " ".join(fg_cmd)

            # If no good foreground process and NOT at prompt, try last_reported_cmdline (preserves aliases)
            # Skip last_reported_cmdline if at shell prompt - those are just previous commands
            if not cmd_to_launch and not w.get("at_prompt"):
                last_cmd = w.get("last_reported_cmdline", "")
                if last_cmd:
                    cmd_to_launch = last_cmd

            # Always write a launch command (empty launch for plain shells)
            if cmd_to_launch:
                lines.append(f"launch {cmd_to_launch}")
            else:
                # Plain shell - write empty launch so parser captures this window
                lines.append("launch")

    with open(session_path, "w") as f:
        f.write("\n".join(lines))

    print(f"Session saved to: {session_path}", file=sys.stderr)


if __name__ == "__main__":
    main([])
