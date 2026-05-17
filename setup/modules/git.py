from ..installer import BaseInstaller
from ..utils import run_cmd
from .base import BaseModule


class GitModule(BaseModule):
    @property
    def name(self) -> str:
        return "git"

    def should_run(self) -> bool:
        return True

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        aliases = {
            "lola": "log --graph --decorate --pretty=oneline --abbrev-commit --all",
            "final-branches": '!git for-each-ref --format="%(objectname)^{commit}" | git cat-file --batch-check="%(objectname)^!" | grep -v missing | git log --oneline --stdin',
            "alias": "! git config --get-regexp ^alias\\. | sed -e s/^alias\\.// -e s/\\ /\\ =\\ /",
            "undo": "reset --soft HEAD^",
        }

        for alias_name, alias_value in aliases.items():
            logger.info(f"Setting git alias: {alias_name}")
            run_cmd(
                ["git", "config", "--global", f"alias.{alias_name}", alias_value],
                dry_run=dry_run,
            )

        logger.info("Git aliases configured.")
        return True
