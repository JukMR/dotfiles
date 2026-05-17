from pathlib import Path

from .logging_config import setup_logging

logger = setup_logging()

OS_RELEASE_PATH = Path("/etc/os-release")

SUPPORTED_DISTROS = {"manjaro", "ubuntu", "arch", "debian"}


def detect_os() -> str:
    if not OS_RELEASE_PATH.exists():
        logger.warning(f"{OS_RELEASE_PATH} not found, defaulting to 'other'")
        return "other"

    content = OS_RELEASE_PATH.read_text()
    distro_id = _parse_os_release(content, "ID")
    distro_id_like = _parse_os_release(content, "ID_LIKE")

    if distro_id in SUPPORTED_DISTROS:
        return distro_id

    if distro_id_like:
        for like_id in distro_id_like.strip('"').split():
            if like_id in SUPPORTED_DISTROS:
                return like_id

    return "other"


def _parse_os_release(content: str, key: str) -> str:
    for line in content.splitlines():
        if line.startswith(f"{key}="):
            return line.split("=", 1)[1].strip('"')
    return ""
