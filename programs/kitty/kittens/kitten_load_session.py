#!/usr/bin/env python3
import sys
import os
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

        elif line.startswith("launch"):
            # Handle both "launch" (no args) and "launch <cmd>"
            cmd = line[len("launch"):].strip()
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

    # Use the kitten process's cwd — kitty sets this to the active window's cwd
    # when invoked via `map key kitten path/to/kitten.py`
    current_cwd = os.getcwd()

    # Read and parse session file
    with open(session_path, "r") as f:
        session_content = f.read()

    # Replace all cd directives with current working directory
    modified_content = re.sub(
        r"^cd .*$",
        f"cd {current_cwd}",
        session_content,
        flags=re.MULTILINE,
    )

    tabs = parse_session_file(modified_content)

    # Create tabs and windows - first tab in a new OS window, rest as additional tabs.
    # We capture each window ID so we can use --match=window_id:N to target the
    # correct tab; without this, kitty @ commands default to the kitten's own tab.
    os_window_ref_id = None  # a window ID inside the new OS window

    for i, tab in enumerate(tabs):
        if not tab["windows"]:
            continue

        first_window = tab["windows"][0]

        # First tab: open new OS window. Subsequent tabs: add to same OS window.
        if i == 0:
            cmd = ["kitty", "@", "launch", "--type=os-window"]
            if tab["title"]:
                cmd.append(f"--title={tab['title']}")
        else:
            cmd = ["kitty", "@", "launch", "--type=tab",
                   f"--match=window_id:{os_window_ref_id}"]
            if tab["title"]:
                cmd.append(f"--tab-title={tab['title']}")

        cmd.append(f"--cwd={current_cwd}")

        if first_window["cmd"] and not is_plain_shell(first_window["cmd"]):
            cmd.extend(["--", first_window["cmd"]])

        result = subprocess.run(cmd, capture_output=True, text=True)
        window_id = result.stdout.strip()

        if i == 0:
            os_window_ref_id = window_id  # anchor for targeting the new OS window

        # Set layout targeting the newly created tab
        if window_id:
            subprocess.run(
                ["kitty", "@", "goto_layout",
                 f"--match=window_id:{window_id}", tab["layout"]],
                capture_output=True,
            )

        # Remaining windows in this tab
        for window in tab["windows"][1:]:
            cmd = ["kitty", "@", "launch", "--type=window",
                   f"--match=window_id:{window_id}",
                   f"--cwd={current_cwd}"]

            if window["cmd"] and not is_plain_shell(window["cmd"]):
                cmd.extend(["--", window["cmd"]])

            subprocess.run(cmd, capture_output=True)

    print(f"Session loaded: {chosen_session} (pwd: {current_cwd})", file=sys.stderr)


if __name__ == "__main__":
    main([])
