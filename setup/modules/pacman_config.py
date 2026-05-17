from pathlib import Path

from ..installer import BaseInstaller
from ..utils import run_cmd
from .base import BaseModule


class PacmanConfigModule(BaseModule):
    @property
    def name(self) -> str:
        return "pacman_config"

    def should_run(self) -> bool:
        return True

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        pacman_conf = Path("/etc/pacman.conf")
        if not pacman_conf.exists():
            logger.info("pacman.conf not found, skipping (not Arch/Manjaro).")
            return True

        logger.info("Configuring pacman...")

        run_cmd(
            ["sed", "-i", "-E", "-e", "s/# *Color/Color/g", str(pacman_conf)],
            sudo=True,
            dry_run=dry_run,
        )

        run_cmd(
            ["sed", "-i", "-E", "-e", "s/# *ParallelDownloads = 5/ParallelDownloads = 5/g", str(pacman_conf)],
            sudo=True,
            dry_run=dry_run,
        )

        content = pacman_conf.read_text()
        if "ILoveCandy" not in content:
            run_cmd(
                ["sed", "-i", "-E", "-e", "/ParallelDownloads = [0-9]/a ILoveCandy", str(pacman_conf)],
                sudo=True,
                dry_run=dry_run,
            )

        pamac_conf = Path("/etc/pamac.conf")
        if pamac_conf.exists():
            content = pamac_conf.read_text()
            if "EnableAUR" not in content or "#EnableAUR" in content:
                run_cmd(
                    ["sed", "-i", "s/#EnableAUR/EnableAUR/", str(pamac_conf)],
                    sudo=True,
                    dry_run=dry_run,
                )

        logger.info("Pacman configuration complete.")
        return True
