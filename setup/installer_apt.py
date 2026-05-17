from .installer import BaseInstaller
from .utils import command_exists, run_cmd


class AptInstaller(BaseInstaller):
    def install(self, packages: list[str]) -> bool:
        cmd = ["apt", "install", "-y"] + packages
        return run_cmd(cmd, sudo=True, dry_run=self.dry_run)

    def is_installed(self, package: str) -> bool:
        return run_cmd(["dpkg", "-s", package], sudo=False, dry_run=False)

    def install_aur(self, package: str) -> bool:
        from .utils import logger
        logger.info("AUR not available on apt-based systems, installing '%s' via apt", package)
        return self.install([package])
