from abc import ABC, abstractmethod
from pathlib import Path

from ..installer import BaseInstaller


class BaseModule(ABC):
    @property
    @abstractmethod
    def name(self) -> str:
        pass

    def should_run(self) -> bool:
        return True

    @abstractmethod
    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        pass
