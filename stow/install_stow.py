#!/usr/bin/env python3
# /// script
# requires = ["inquirer"]
# dependencies = [
#     "inquirer>=3.4.1",
# ]
# ///

import argparse
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path


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


@dataclass
class ValidationResult:
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    @property
    def ok(self) -> bool:
        return not self.errors


def get_package_entries(package_dir: Path) -> list[Path]:
    if not package_dir.is_dir():
        return []

    return sorted(
        entry.relative_to(package_dir)
        for entry in package_dir.rglob("*")
        if entry.is_file() or entry.is_symlink()
    )


def format_target_path(target: Path, rel_path: Path) -> str:
    full_path = target / rel_path
    if target == Path.home():
        return f"~/{rel_path.as_posix()}"
    return str(full_path)


def is_suspicious_xdg_root_file(rel_path: Path) -> bool:
    if len(rel_path.parts) != 2 or rel_path.parts[0] != ".config":
        return False

    filename = rel_path.name.lower()
    return filename.startswith("config.") or filename.startswith("settings.")


def validate_package_layout(package_dir: Path, package: str, target: Path) -> ValidationResult:
    result = ValidationResult()
    entries = get_package_entries(package_dir)

    if not entries:
        result.errors.append(f"Package directory '{package_dir}' does not contain any files to stow.")
        return result

    expected_config_dir = Path(".config") / package
    for rel_path in entries:
        if not is_suspicious_xdg_root_file(rel_path):
            continue

        result.errors.append(
            f"{rel_path.as_posix()} would link to {format_target_path(target, rel_path)}. "
            f"Use a nested app directory such as {format_target_path(target, expected_config_dir / rel_path.name)} instead."
        )

    return result


def validate_linked_targets(package_dir: Path, target: Path) -> ValidationResult:
    result = ValidationResult()

    for rel_path in get_package_entries(package_dir):
        target_path = target / rel_path
        source_path = package_dir / rel_path

        if not target_path.exists():
            if target_path.is_symlink():
                result.errors.append(
                    f"{format_target_path(target, rel_path)} is a broken symlink; expected {source_path}."
                )
            else:
                result.errors.append(
                    f"Missing expected target {format_target_path(target, rel_path)}."
                )
            continue

        if target_path.resolve() != source_path.resolve():
            result.errors.append(
                f"{format_target_path(target, rel_path)} resolves to {target_path.resolve()}, expected {source_path.resolve()}."
            )

    return result


def print_validation_result(package: str, result: ValidationResult, *, stream: object | None = None) -> None:
    if not result.errors and not result.warnings:
        return

    if stream is None:
        stream = sys.stderr

    if result.errors:
        print(f"  Invalid package layout for {package}:", file=stream)
        for message in result.errors:
            print(f"    - {message}", file=stream)

    if result.warnings:
        print(f"  Warnings for {package}:", file=stream)
        for message in result.warnings:
            print(f"    - {message}", file=stream)


def build_stow_command(
    profile_dir: Path,
    package: str,
    target: Path,
    *,
    adopt: bool,
    dry_run: bool,
    verbose: bool,
) -> list[str]:
    cmd = ["stow", "-t", str(target), "-d", str(profile_dir)]

    if adopt:
        cmd.append("--adopt")
    if dry_run:
        cmd.extend(["-n", "--verbose=1"])
    elif verbose:
        cmd.append("--verbose=1")

    cmd.extend(["-S", package])
    return cmd


def print_dry_run_targets(package_dir: Path, target: Path) -> None:
    print("  [DRY RUN] Would manage:")
    for rel_path in get_package_entries(package_dir):
        print(f"    - {format_target_path(target, rel_path)}")


def format_stow_error(result: subprocess.CompletedProcess[str]) -> str:
    output_parts = [part.strip() for part in (result.stderr, result.stdout) if part and part.strip()]
    return "\n".join(output_parts)


def stow_package(
    stow_dir: Path,
    profile: str,
    package: str,
    adopt: bool = False,
    dry_run: bool = False,
    verbose: bool = False,
    target: Path | None = None,
) -> bool:
    target = target or Path.home()
    profile_dir = stow_dir / "profiles" / profile
    package_dir = profile_dir / package
    preflight = validate_package_layout(package_dir, package, target)

    if not preflight.ok:
        print_validation_result(package, preflight)
        return False

    cmd = build_stow_command(
        profile_dir,
        package,
        target,
        adopt=adopt,
        dry_run=dry_run,
        verbose=verbose,
    )

    if verbose:
        print(f"  Command: {' '.join(cmd)}")

    if dry_run:
        print_dry_run_targets(package_dir, target)

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(f"  Error stowing {package}: {format_stow_error(result)}", file=sys.stderr)
        return False

    if dry_run:
        if verbose and result.stdout.strip():
            for line in result.stdout.strip().splitlines():
                print(f"    {line}")
        print(f"  [DRY RUN] Validated {package} (profile: {profile})")
        return True

    postflight = validate_linked_targets(package_dir, target)
    if not postflight.ok:
        print(f"  Post-stow validation failed for {package}:", file=sys.stderr)
        for message in postflight.errors:
            print(f"    - {message}", file=sys.stderr)
        return False

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
        help="Machine profile (e.g., ubuntu, manjaro, base). If not provided, prompts for selection.",
    )
    parser.add_argument(
        "--adopt",
        action="store_true",
        help="Pass through GNU Stow's native --adopt behavior (use with caution).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Validate package layout and show managed targets without making changes.",
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
        try:
            import inquirer
        except ModuleNotFoundError:
            print(
                "Interactive profile selection requires 'inquirer'. Run with "
                "`uv run --script install_stow.py` or use the repo virtualenv.",
                file=sys.stderr,
            )
            sys.exit(1)

        choices = available_profiles + ["base (base profile only)"]
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
        machine = "base"

    selected_profiles = ["base"]
    if machine != "base" and machine in available_profiles:
        selected_profiles.append(machine)
    elif machine != "base":
        print(f"Warning: Profile '{machine}' not found. Using base only.", file=sys.stderr)

    if args.dry_run:
        print("Running in dry-run mode - no changes will be made.")

    print(f"Installing dotfiles with GNU Stow (profiles: {', '.join(selected_profiles)})...")
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
