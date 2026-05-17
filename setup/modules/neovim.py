from pathlib import Path

from ..installer import BaseInstaller
from ..utils import clone_repo, dir_exists, run_cmd
from .base import BaseModule


class NeovimModule(BaseModule):
    @property
    def name(self) -> str:
        return "neovim"

    def should_run(self) -> bool:
        nvim_config = Path.home() / ".config" / "nvim"
        return not dir_exists(str(nvim_config))

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        installer.install_if_missing(["neovim"])

        nvim_config = Path.home() / ".config" / "nvim"
        nvim_data = Path.home() / ".local" / "share" / "nvim"
        nvim_state = Path.home() / ".local" / "state" / "nvim"
        nvim_cache = Path.home() / ".cache" / "nvim"

        for backup_path in [nvim_config, nvim_data, nvim_state, nvim_cache]:
            if backup_path.exists() and not dry_run:
                backup = Path(str(backup_path) + ".bak")
                if backup.exists():
                    import shutil
                    shutil.rmtree(backup)
                backup_path.rename(backup)
                logger.info(f"Backed up {backup_path}")

        config_url = "https://github.com/JuKMR/astronvim-configuration"
        logger.info("Cloning AstroNvim configuration...")
        return clone_repo(config_url, str(nvim_config), dry_run=dry_run)
