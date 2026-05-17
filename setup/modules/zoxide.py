from pathlib import Path

from ..installer import BaseInstaller
from ..utils import command_exists, file_contains, run_cmd
from .base import BaseModule


class ZoxideModule(BaseModule):
    @property
    def name(self) -> str:
        return "zoxide"

    def should_run(self) -> bool:
        return not command_exists("zoxide")

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        if not command_exists("zoxide"):
            logger.info("Installing zoxide...")
            run_cmd(
                ["sh", "-c", "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"],
                dry_run=dry_run,
            )

        zshrc = Path.home() / ".zshrc"
        init_line = 'eval "$(zoxide init zsh --cmd cd)"'
        if not file_contains(str(zshrc), "zoxide init zsh"):
            if not dry_run:
                with open(zshrc, "a") as f:
                    f.write(init_line + "\n")
                logger.info("Added zoxide init to .zshrc")
        else:
            logger.info("zoxide already initialized in .zshrc")

        if not command_exists("fzf"):
            logger.info("Installing fzf...")
            installer.install_if_missing(["fzf"])

        logger.info("Zoxide setup complete.")
        return True
