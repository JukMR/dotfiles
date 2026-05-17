from pathlib import Path

from ..installer import BaseInstaller
from ..utils import command_exists, dir_exists, run_cmd
from .base import BaseModule


class ZshOhMyZshModule(BaseModule):
    @property
    def name(self) -> str:
        return "zsh_ohmyzsh"

    def should_run(self) -> bool:
        return not dir_exists(str(Path.home() / ".oh-my-zsh")) or not command_exists("zsh")

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        if not command_exists("zsh"):
            logger.info("Installing zsh...")
            installer.install_if_missing(["zsh"])

        omz_dir = Path.home() / ".oh-my-zsh"
        if not omz_dir.exists():
            logger.info("Installing Oh My Zsh...")
            success = run_cmd(
                ["sh", "-c", "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"],
                dry_run=dry_run,
            )
            if not success:
                logger.warning("Oh My Zsh installation may have failed (unattended mode).")

        autosuggest_plugin = omz_dir / "custom" / "plugins" / "zsh-autosuggestions"
        if not autosuggest_plugin.exists():
            logger.info("Installing zsh-autosuggestions plugin...")
            plugins_dir = omz_dir / "custom" / "plugins"
            if not dry_run:
                plugins_dir.mkdir(parents=True, exist_ok=True)
            run_cmd(
                ["git", "clone", "https://github.com/zsh-users/zsh-autosuggestions", str(autosuggest_plugin)],
                dry_run=dry_run,
            )
            autosuggest_config = omz_dir / "custom" / "autosuggetion.zsh"
            if not dry_run and not autosuggest_config.exists():
                autosuggest_config.write_text(
                    'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=01,bg=cyan,bold,underline"\n'
                    "ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20\n"
                )

        vim_mode_plugin = omz_dir / "custom" / "plugins" / "zsh-vim-mode"
        if not vim_mode_plugin.exists():
            logger.info("Installing zsh-vim-mode plugin...")
            run_cmd(
                ["git", "clone", "https://github.com/softmoth/zsh-vim-mode", str(vim_mode_plugin)],
                dry_run=dry_run,
            )

        logger.info("zsh + Oh My Zsh setup complete.")
        return True
