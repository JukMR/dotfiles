from abc import ABC, abstractmethod

from .logging_config import setup_logging

logger = setup_logging()


class BaseInstaller(ABC):
    def __init__(self, dry_run: bool = False):
        self.dry_run = dry_run

    @abstractmethod
    def install(self, packages: list[str]) -> bool:
        pass

    @abstractmethod
    def is_installed(self, package: str) -> bool:
        pass

    def install_if_missing(self, packages: list[str]) -> list[str]:
        missing = [p for p in packages if not self.is_installed(p)]
        if not missing:
            logger.info("All packages already installed.")
            return []
        if self.install(missing):
            return missing
        return []
