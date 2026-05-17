from pathlib import Path

from ..installer import BaseInstaller
from ..utils import command_exists, run_cmd
from .base import BaseModule


class CronjobModule(BaseModule):
    @property
    def name(self) -> str:
        return "cronjob"

    def should_run(self) -> bool:
        return not command_exists("crontab")

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        installer.install_if_missing(["cronie"])

        wallpapers = Path.home() / "Pictures" / "wallpapers"
        if not dry_run:
            wallpapers.mkdir(parents=True, exist_ok=True)
            logger.info(f"Created {wallpapers}")

        dotfiles_root = self._find_dotfiles_root()
        if not dotfiles_root:
            logger.error("Could not find dotfiles root.")
            return False

        cron_script = dotfiles_root / "scripts" / "wallpaper_changer_cron.sh"
        cron_line = f"*/10 * * * *  {cron_script}"

        if not dry_run:
            cron_file = Path("wallpaper_set.cron")
            cron_file.write_text(cron_line + "\n")
            run_cmd(["crontab", str(cron_file)], dry_run=False)
            logger.info("Cronjob installed.")
            run_cmd(["crontab", "-l"], dry_run=False)

        logger.info("Cronjob setup complete.")
        return True

    def _find_dotfiles_root(self) -> Path | None:
        current = Path(__file__).resolve().parent.parent.parent
        if (current / "scripts" / "wallpaper_changer_cron.sh").exists():
            return current
        home_dotfiles = Path.home() / "dotfiles"
        if (home_dotfiles / "scripts" / "wallpaper_changer_cron.sh").exists():
            return home_dotfiles
        return None
