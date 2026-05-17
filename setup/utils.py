import subprocess
from pathlib import Path

from .logging_config import setup_logging

logger = setup_logging()


def run_cmd(cmd: list[str], sudo: bool = False, dry_run: bool = False) -> bool:
    if dry_run:
        prefix = "sudo " if sudo else ""
        logger.info(f"[DRY RUN] {prefix}{' '.join(cmd)}")
        return True

    full_cmd = (["sudo"] if sudo else []) + cmd
    logger.debug(f"Running: {' '.join(full_cmd)}")
    try:
        result = subprocess.run(
            full_cmd,
            capture_output=True,
            text=True,
            timeout=300,
        )
        if result.returncode != 0:
            logger.warning(f"Command failed (rc={result.returncode}): {result.stderr.strip()}")
            return False
        return True
    except subprocess.TimeoutExpired:
        logger.error(f"Command timed out: {' '.join(full_cmd)}")
        return False
    except FileNotFoundError:
        logger.error(f"Command not found: {full_cmd[0]}")
        return False


def command_exists(cmd: str) -> bool:
    try:
        subprocess.run(
            ["which", cmd],
            capture_output=True,
            text=True,
            check=False,
        )
        return True
    except FileNotFoundError:
        return False


def path_exists(path: str) -> bool:
    return Path(path).exists()


def dir_exists(path: str) -> bool:
    return Path(path).is_dir()


def file_contains(filepath: str, text: str) -> bool:
    p = Path(filepath)
    if not p.exists():
        return False
    return text in p.read_text()


def append_to_file(filepath: str, line: str) -> bool:
    p = Path(filepath)
    p.parent.mkdir(parents=True, exist_ok=True)
    with open(p, "a") as f:
        f.write(line + "\n")
    return True


def clone_repo(url: str, dest: str, dry_run: bool = False) -> bool:
    if dir_exists(dest):
        logger.info(f"Directory already exists: {dest}")
        return True
    return run_cmd(["git", "clone", url, dest], dry_run=dry_run)
