#!/usr/bin/env python3
# /// script
# requires = ["inquirer"]
# dependencies = [
#     "inquirer>=3.4.1",
# ]
# ///

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

import inquirer


def get_script_dir() -> Path:
    return Path(__file__).parent.resolve()


def list_profiles(stow_dir: Path) -> list[str]:
    profiles_dir = stow_dir / "profiles"
    if not profiles_dir.is_dir():
        return []
    return sorted(entry.name for entry in profiles_dir.iterdir() if entry.is_dir())


def get_profile_packages(stow_dir: Path, profile: str) -> list[str]:
    profile_dir = stow_dir / "profiles" / profile
    if not profile_dir.is_dir():
        return []
    return sorted(entry.name for entry in profile_dir.iterdir() if entry.is_dir())


def stow_package(
    stow_dir: Path,
    profile: str,
    package: str,
    adopt: bool = False,
    dry_run: bool = False,
    verbose: bool = False,
) -> bool:
    target = Path.home()
    profile_dir = stow_dir / "profiles" / profile
    package_dir = profile_dir / package

    # Build the stow command
    cmd = ["stow", "-t", str(target), "-S", package, "-d", str(profile_dir)]

    if verbose:
        print(f"  Command: {' '.join(cmd)}")

    if dry_run:
        print(f"  [DRY RUN] Would run: {' '.join(cmd)}")
        return True

    # First attempt without --adopt
    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
    )

    if result.returncode == 0:
        print(f"  Linked {package} (profile: {profile})")
        return True

    # If failed and adopt is requested, try to manually adopt conflicting files
    if adopt and "would cause conflicts" in result.stderr:
        conflicts = []
        for line in result.stderr.split("\n"):
            line = line.strip()
            if line.startswith("*"):
                parts = line.split(": ", 1)
                if len(parts) >= 2:
                    conflicts.append(parts[1].strip())

        if conflicts:
            print(f"  Adopting {len(conflicts)} conflicting file(s)...")
            for rel_path in conflicts:
                target_file = target / rel_path
                package_file = package_dir / rel_path

                if dry_run:
                    print(
                        f"  [DRY RUN] Would adopt {rel_path}: {target_file} -> {package_file}"
                    )
                    continue

                if target_file.exists() or target_file.is_symlink():
                    package_file.parent.mkdir(parents=True, exist_ok=True)
                    if target_file.is_symlink():
                        target_file.unlink()
                        if verbose:
                            print(f"    Removed symlink: {target_file}")
                    else:
                        shutil.move(str(target_file), str(package_file))
                        print(f"    Adopted {rel_path}")
                    if not package_file.exists():
                        print(f"    Warning: {rel_path} not found in package, skipping")
                        continue
                else:
                    print(f"    {rel_path} not found in target, skipping")

            # Retry stow after adopting
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
            )

    if result.returncode != 0:
        print(f"  Error stowing {package}: {result.stderr.strip()}", file=sys.stderr)
        return False
    else:
        print(f"  Linked {package} (profile: {profile})")
        return True


def main() -> None:
    script_dir = get_script_dir()
    stow_dir = script_dir

    parser = argparse.ArgumentParser(description="Install dotfiles with GNU Stow")
    parser.add_argument(
        "machine",
        nargs="?",
        default=None,
        help="Machine profile (e.g., ubuntu, manjaro, basic). If not provided, prompts for selection.",
    )
    parser.add_argument(
        "--adopt",
        action="store_true",
        help="Adopt existing files into stow packages (use with caution).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print commands without executing them.",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Enable verbose output.",
    )
    args = parser.parse_args()

    profiles = list_profiles(stow_dir)
    available_profiles = [p for p in profiles if p != "base"]

    machine = args.machine

    if not machine and available_profiles:
        choices = available_profiles + ["basic (base profile only)"]
        questions = [
            inquirer.List(
                "machine",
                message="Select machine profile",
                choices=choices,
            )
        ]
        answers = inquirer.prompt(questions)
        if not answers:
            print("Cancelled by user.", file=sys.stderr)
            sys.exit(1)
        machine = answers["machine"].split()[0]
    elif not machine:
        machine = "basic"

    selected_profiles = ["base"]
    if machine != "basic" and machine in available_profiles:
        selected_profiles.append(machine)
    elif machine != "basic":
        print(
            f"Warning: Profile '{machine}' not found. Using base only.", file=sys.stderr
        )

    if args.dry_run:
        print("Running in dry-run mode - no changes will be made.")

    print(
        f"Installing dotfiles with GNU Stow (profiles: {', '.join(selected_profiles)})..."
    )
    print(f"Using stow dir: {stow_dir}")

    linked_count = 0
    failed_count = 0

    for profile in selected_profiles:
        packages = get_profile_packages(stow_dir, profile)
        for package in packages:
            if stow_package(
                stow_dir,
                profile,
                package,
                adopt=args.adopt,
                dry_run=args.dry_run,
                verbose=args.verbose,
            ):
                linked_count += 1
            else:
                failed_count += 1

    if failed_count > 0:
        print(f"Done with errors: {linked_count} linked, {failed_count} failed.")
    elif linked_count == 0:
        print("No dotfiles were linked.")
    elif args.dry_run:
        print("Dry run complete. No changes were made.")
    else:
        print("Done! Config files are now symlinked to your home directory.")


if __name__ == "__main__":
    main()
