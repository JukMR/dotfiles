#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
from pathlib import Path

import inquirer


def get_script_dir() -> Path:
    return Path(__file__).parent.resolve()


def find_machine_suffixes(stow_dir: Path) -> set[str]:
    suffixes = set()
    for entry in stow_dir.iterdir():
        if entry.is_dir():
            name = entry.name
            if "-" in name:
                suffix = name.split("-", 1)[-1]
                if suffix and suffix not in ("vim", "kitty"):
                    suffixes.add(suffix)
    return sorted(suffixes)


def find_machine_specific_packages(
    stow_dir: Path, suffix: str
) -> list[tuple[str, str]]:
    packages = []
    for entry in stow_dir.iterdir():
        if entry.is_dir() and entry.name.endswith(f"-{suffix}"):
            base_name = entry.name.rsplit(f"-{suffix}", 1)[0]
            packages.append((entry.name, base_name))
    return sorted(packages, key=lambda x: x[1])


def find_machine_agnostic_packages(stow_dir: Path) -> list[str]:
    all_suffixes = find_machine_suffixes(stow_dir)
    packages = []
    for entry in stow_dir.iterdir():
        if entry.is_dir():
            name = entry.name
            is_agnostic = True
            for suffix in all_suffixes:
                if name.endswith(f"-{suffix}"):
                    is_agnostic = False
                    break
            if is_agnostic:
                packages.append(name)
    return sorted(packages)


def stow_package(stow_dir: Path, package: str) -> bool:
    target = Path.home()
    result = subprocess.run(
        ["stow", "-t", str(target), "-S", package, "-d", str(stow_dir)],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"  Error stowing {package}: {result.stderr.strip()}", file=sys.stderr)
        return False
    else:
        print(f"  Linked {package}")
        return True


def main() -> None:
    script_dir = get_script_dir()
    stow_dir = script_dir / "stow"

    parser = argparse.ArgumentParser(description="Install dotfiles with GNU Stow")
    parser.add_argument(
        "machine",
        nargs="?",
        default=None,
        help="Machine profile (e.g., ubuntu, manjaro). If not provided, prompts for selection.",
    )
    args = parser.parse_args()

    suffixes = find_machine_suffixes(stow_dir)

    if args.machine:
        machine = args.machine
    elif suffixes:
        choices = suffixes + ["basic (no OS-specific packages)"]
        questions = [
            inquirer.List(
                "machine",
                message="Select machine profile",
                choices=choices,
            )
        ]
        answers = inquirer.prompt(questions)
        machine = answers["machine"].split()[0]
    else:
        machine = "default"

    print(f"Installing dotfiles with GNU Stow (machine: {machine})...")
    print(f"Using stow dir: {stow_dir}")

    linked_count = 0
    failed_count = 0

    if machine != "basic":
        machine_specific = find_machine_specific_packages(stow_dir, machine)
        for full_name, base_name in machine_specific:
            if stow_package(stow_dir, full_name):
                linked_count += 1
            else:
                failed_count += 1

    machine_agnostic = find_machine_agnostic_packages(stow_dir)
    for package in machine_agnostic:
        if stow_package(stow_dir, package):
            linked_count += 1
        else:
            failed_count += 1

    if failed_count > 0:
        print(f"Done with errors: {linked_count} linked, {failed_count} failed.")
    elif linked_count == 0:
        print("No dotfiles were linked.")
    else:
        print("Done! Config files are now symlinked to your home directory.")


if __name__ == "__main__":
    main()
