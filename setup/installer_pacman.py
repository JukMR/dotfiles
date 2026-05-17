from .installer import BaseInstaller
from .utils import command_exists, run_cmd


class PacmanInstaller(BaseInstaller):
    def install(self, packages: list[str]) -> bool:
        cmd = ["pacman", "-S", "--noconfirm", "--needed"] + packages
        return run_cmd(cmd, sudo=True, dry_run=self.dry_run)

    def is_installed(self, package: str) -> bool:
        return run_cmd(["pacman", "-Qi", package], sudo=False, dry_run=False)

    def install_aur(self, package: str) -> bool:
        if not command_exists("yay"):
            from .utils import logger
            logger.warning("yay not found, cannot install AUR package: %s", package)
            return False
        return run_cmd(["yay", "-S", "--noconfirm", package], dry_run=self.dry_run)
