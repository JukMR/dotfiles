from pathlib import Path

from ..installer import BaseInstaller
from ..utils import command_exists, file_contains, run_cmd
from .base import BaseModule


class AtuinModule(BaseModule):
    @property
    def name(self) -> str:
        return "atuin"

    def should_run(self) -> bool:
        return not command_exists("atuin")

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        if not command_exists("atuin"):
            logger.info("Installing atuin...")
            run_cmd(
                ["sh", "-c", "curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh"],
                dry_run=dry_run,
            )

        config = Path.home() / ".config" / "atuin" / "config.toml"
        if config.exists():
            content = config.read_text()
            if "ctrl_n_shortcuts = true" not in content:
                logger.info("Enabling ctrl_n_shortcuts in atuin config...")
                if not dry_run:
                    new_content = content.replace(
                        "ctrl_n_shortcuts = false",
                        "# ctrl_n_shortcuts = false\nctrl_n_shortcuts = true",
                    )
                    config.write_text(new_content)
            else:
                logger.info("ctrl_n_shortcuts already enabled.")
        else:
            logger.info("Atuin config not found, skipping ctrl_n_shortcuts.")

        logger.info("Atuin setup complete.")
        return True
