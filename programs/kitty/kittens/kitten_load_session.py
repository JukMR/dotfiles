#!/usr/bin/env python3
import sys
import os
import json
import subprocess
import re


def is_plain_shell(cmd_str):
    """Check if command is just a shell executable without arguments."""
    if not cmd_str:
        return False
    cmd_parts = cmd_str.split()
    if len(cmd_parts) != 1:
        return False
    # Get just the executable name (basename)
    exe = os.path.basename(cmd_parts[0])
    return exe in ("zsh", "bash", "sh", "fish", "ksh")


def parse_session_file(content):
    """Parse a .kitty-session file into structured tabs with windows."""
    tabs = []
    current_tab = {"title": "", "layout": "tall", "windows": []}
    current_cwd = None

    for line in content.splitlines():
        line = line.strip()
        if not line:
            continue

        if line.startswith("new_tab"):
            # Save previous tab if it exists
            if current_tab["windows"]:
                tabs.append(current_tab)
            # Start new tab
            title = line[len("new_tab"):].strip()
            current_tab = {"title": title, "layout": "tall", "windows": []}
            current_cwd = None

        elif line.startswith("layout "):
            current_tab["layout"] = line[len("layout "):].strip()

        elif line.startswith("cd "):
            current_cwd = line[len("cd "):].strip()

        elif line.startswith("launch "):
            cmd = line[len("launch "):].strip()
            current_tab["windows"].append({"cwd": current_cwd, "cmd": cmd})

    # Don't forget last tab
    if current_tab["windows"]:
        tabs.append(current_tab)

    return tabs


def main(args):
    sessions_dir = os.path.expanduser("~/.local/share/kitty/sessions")

    if not os.path.exists(sessions_dir):
        print("No sessions directory found", file=sys.stderr)
        sys.exit(1)

    # List all .kitty-session files (excluding temp ones)
    session_files = sorted([f for f in os.listdir(sessions_dir)
                           if f.endswith(".kitty-session") and not f.startswith(".")])

    if not session_files:
        print("No sessions found", file=sys.stderr)
        sys.exit(1)

    # Use rofi to pick a session
    result = subprocess.run(
        ["rofi", "-dmenu", "-p", "Load session:"],
        input="\n".join(session_files),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    chosen_session = result.stdout.strip()

    if not chosen_session:
        print("No session chosen", file=sys.stderr)
        sys.exit(1)

    session_path = os.path.join(sessions_dir, chosen_session)

    # Get current working directory from focused window
    ls_result = subprocess.run(
        ["kitty", "@", "ls"],
        capture_output=True,
        text=True,
    )
    state = json.loads(ls_result.stdout)

    current_cwd = os.path.expanduser("~")

    if isinstance(state, list) and state:
        state = state[0]

    # Find focused window and get its cwd
    for tab in state.get("tabs", []):
        for window in tab.get("windows", []):
            if window.get("is_focused"):
                current_cwd = window.get("cwd", current_cwd)
                break

    # Read and parse session file
    with open(session_path, "r") as f:
        session_content = f.read()

    # Replace all cd directives with current cwd
    modified_content = re.sub(
        r"^cd .*$",
        f"cd {current_cwd}",
        session_content,
        flags=re.MULTILINE,
    )

    tabs = parse_session_file(modified_content)

    # Open a new kitty window
    subprocess.run(["kitty", "@", "launch", "--type=os-window"], capture_output=True)

    # Create tabs and windows in the new window
    for i, tab in enumerate(tabs):
        if not tab["windows"]:
            continue

        # First window in tab (creates the tab)
        first_window = tab["windows"][0]
        cmd = ["kitty", "@", "launch", "--type=tab"]

        if tab["title"]:
            cmd.append(f"--tab-title={tab['title']}")

        cmd.append(f"--cwd={current_cwd}")

        # Add command if present and it's not just a shell
        if first_window["cmd"] and not is_plain_shell(first_window["cmd"]):
            cmd.extend(["--", first_window["cmd"]])

        subprocess.run(cmd, capture_output=True)

        # Set layout for this tab
        subprocess.run(
            ["kitty", "@", "goto_layout", tab["layout"]],
            capture_output=True,
        )

        # Remaining windows in tab
        for window in tab["windows"][1:]:
            cmd = ["kitty", "@", "launch", "--type=window"]
            cmd.append(f"--cwd={current_cwd}")

            # Add command if present and it's not just a shell
            if window["cmd"] and not is_plain_shell(window["cmd"]):
                cmd.extend(["--", window["cmd"]])

            subprocess.run(cmd, capture_output=True)

    print(f"Session loaded: {chosen_session} (pwd: {current_cwd})", file=sys.stderr)


if __name__ == "__main__":
    main([])
