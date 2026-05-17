from pathlib import Path

from ..installer import BaseInstaller
from ..utils import dir_exists, file_contains, run_cmd
from .base import BaseModule


class AwesomeModule(BaseModule):
    @property
    def name(self) -> str:
        return "awesome"

    def should_run(self) -> bool:
        return not dir_exists(str(Path.home() / ".config" / "awesome" / "awesome-wm-widgets"))

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        installer.install_if_missing(["awesome"])

        awesome_config = Path.home() / ".config" / "awesome"
        if not dry_run:
            awesome_config.mkdir(parents=True, exist_ok=True)

        widgets_dir = awesome_config / "awesome-wm-widgets"
        if not widgets_dir.exists():
            logger.info("Cloning awesome-wm-widgets...")
            run_cmd(
                ["git", "clone", "https://github.com/streetturtle/awesome-wm-widgets", str(widgets_dir)],
                dry_run=dry_run,
            )

        net_widgets = awesome_config / "net_widgets"
        if not net_widgets.exists():
            logger.info("Cloning net_widgets...")
            run_cmd(
                ["git", "clone", "https://github.com/pltanton/net_widgets.git", str(net_widgets)],
                dry_run=dry_run,
            )

        zsh_vim = awesome_config / "zsh-vim-mode"
        if not zsh_vim.exists():
            logger.info("Cloning zsh-vim-mode...")
            run_cmd(
                ["git", "clone", "https://github.com/softmoth/zsh-vim-mode.git", str(zsh_vim)],
                dry_run=dry_run,
            )

        logger.info("Awesome WM setup complete.")
        return True
