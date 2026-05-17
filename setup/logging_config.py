import sys
from pathlib import Path

from loguru import logger


def setup_logging(verbose: bool = False, log_file: Path | None = None) -> "logger":
    logger.remove()

    logger.add(
        sys.stdout,
        level="DEBUG" if verbose else "INFO",
        format="<green>{time:HH:mm:ss}</green> [<level>{level}</level>] <cyan>{name}</cyan>: {message}",
    )

    if log_file:
        log_file.parent.mkdir(parents=True, exist_ok=True)
        logger.add(
            str(log_file),
            level="DEBUG",
            format="{time:YYYY-MM-DD HH:mm:ss} [{level}] {name}: {message}",
            rotation="10 MB",
        )

    return logger
