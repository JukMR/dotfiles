from pathlib import Path

from ..installer import BaseInstaller
from ..utils import command_exists, dir_exists, run_cmd
from .base import BaseModule


class GitDiffImageModule(BaseModule):
    @property
    def name(self) -> str:
        return "git_diff_image"

    def should_run(self) -> bool:
        return not dir_exists(str(Path.home() / "git-diff-image" / "git-diff-image"))

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        dest = Path.home() / "git-diff-image"
        if dest.exists():
            logger.info("git-diff-image already exists, skipping.")
            return True

        logger.info("Cloning git-diff-image...")
        success = run_cmd(
            ["git", "clone", "https://github.com/ewanmellor/git-diff-image.git", str(dest)],
            dry_run=dry_run,
        )
        if not success:
            return False

        logger.info("Installing git-diff-image...")
        return run_cmd(
            ["bash", "./install.sh"],
            dry_run=dry_run,
        )
