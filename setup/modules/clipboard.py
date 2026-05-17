from ..installer import BaseInstaller
from ..utils import command_exists, run_cmd
from .base import BaseModule


class ClipboardModule(BaseModule):
    @property
    def name(self) -> str:
        return "clipboard"

    def should_run(self) -> bool:
        return not command_exists("clipboard")

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        if not self.should_run():
            logger.info("Clipboard is already installed.")
            return True

        logger.info("Installing Clipboard...")
        return run_cmd(
            ["sh", "-c", "curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh"],
            dry_run=dry_run,
        )
