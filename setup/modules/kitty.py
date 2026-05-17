import shutil
from pathlib import Path

from ..installer import BaseInstaller
from ..utils import command_exists, dir_exists, run_cmd
from .base import BaseModule

KITTY_LOCAL = Path.home() / ".local" / "kitty.app"


class KittyModule(BaseModule):
    @property
    def name(self) -> str:
        return "kitty"

    def should_run(self) -> bool:
        return not command_exists("kitty")

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        if not self.should_run():
            logger.info("kitty is already installed.")
            return True

        logger.info("Installing kitty...")
        success = run_cmd(
            ["sh", "-c", "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"],
            dry_run=dry_run,
        )
        if not success:
            return False

        bin_dir = Path.home() / ".local" / "bin"
        if not dry_run:
            bin_dir.mkdir(parents=True, exist_ok=True)
            for link_name, target in [
                ("kitty", KITTY_LOCAL / "bin" / "kitty"),
                ("kitten", KITTY_LOCAL / "bin" / "kitten"),
            ]:
                link = bin_dir / link_name
                if link.exists() or link.is_symlink():
                    link.unlink()
                link.symlink_to(target)

        apps_dir = Path.home() / ".local" / "share" / "applications"
        if not dry_run:
            apps_dir.mkdir(parents=True, exist_ok=True)
            src_desktop = KITTY_LOCAL / "share" / "applications" / "kitty.desktop"
            dst_desktop = apps_dir / "kitty.desktop"
            if src_desktop.exists():
                import shutil
                shutil.copy2(src_desktop, dst_desktop)

            src_open = KITTY_LOCAL / "share" / "applications" / "kitty-open.desktop"
            dst_open = apps_dir / "kitty-open.desktop"
            if src_open.exists():
                import shutil
                shutil.copy2(src_open, dst_open)

            import re
            user = Path.home().name
            for desktop in apps_dir.glob("kitty*.desktop"):
                content = desktop.read_text()
                content = re.sub(
                    r"Icon=kitty",
                    f"Icon=/home/{user}/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png",
                    content,
                )
                content = re.sub(
                    r"Exec=kitty",
                    f"Exec=/home/{user}/.local/kitty.app/bin/kitty",
                    content,
                )
                desktop.write_text(content)

        logger.info("kitty installed successfully.")
        return True
