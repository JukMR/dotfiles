from pathlib import Path
import shutil

from ..installer import BaseInstaller
from ..utils import dir_exists, run_cmd
from .base import BaseModule


class PicomModule(BaseModule):
    @property
    def name(self) -> str:
        return "picom"

    def should_run(self) -> bool:
        config = Path.home() / ".config" / "picom" / "picom.conf"
        return not config.exists()

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        installer.install_if_missing(["picom"])

        dotfiles_root = self._find_dotfiles_root()
        if not dotfiles_root:
            logger.error("Could not find dotfiles root.")
            return False

        src = dotfiles_root / "programs" / "picom" / "picom.conf"
        if not src.exists():
            logger.error(f"picom.conf not found: {src}")
            return False

        dst_dir = Path.home() / ".config" / "picom"
        dst = dst_dir / "picom.conf"

        if not dry_run:
            dst_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
            logger.info("Copied picom.conf")

        logger.info("Picom setup complete.")
        return True

    def _find_dotfiles_root(self) -> Path | None:
        current = Path(__file__).resolve().parent.parent.parent
        if (current / "programs" / "picom").exists():
            return current
        home_dotfiles = Path.home() / "dotfiles"
        if (home_dotfiles / "programs" / "picom").exists():
            return home_dotfiles
        return None
