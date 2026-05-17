import sys
from pathlib import Path

from ..installer import BaseInstaller
from ..utils import dir_exists, run_cmd
from .base import BaseModule


class DotfilesModule(BaseModule):
    @property
    def name(self) -> str:
        return "dotfiles"

    def should_run(self) -> bool:
        return True

    def run(self, installer: BaseInstaller, dry_run: bool = False) -> bool:
        from ..utils import logger

        dotfiles_root = self._find_dotfiles_root()
        if not dotfiles_root:
            logger.error("Could not find dotfiles root directory.")
            return False

        stow_dir = dotfiles_root / "stow"
        if not stow_dir.exists():
            logger.error(f"Stow directory not found: {stow_dir}")
            return False

        sys.path.insert(0, str(stow_dir))
        try:
            from install_stow import stow_package

            profiles_to_use = ["base"]
            os_name = self._detect_os_profile()
            if os_name in ("manjaro", "ubuntu"):
                profiles_to_use.append(os_name)

            personal_profile = stow_dir / "profiles" / "personal"
            if personal_profile.exists():
                profiles_to_use.append("personal")

            all_success = True
            for profile in profiles_to_use:
                profile_dir = stow_dir / "profiles" / profile
                if not profile_dir.exists():
                    logger.warning(f"Profile directory not found: {profile_dir}")
                    continue

                packages = sorted(
                    entry.name for entry in profile_dir.iterdir() if entry.is_dir()
                )
                for package in packages:
                    logger.info(f"Stowing {package} (profile: {profile})")
                    success = stow_package(
                        stow_dir,
                        profile,
                        package,
                        adopt=True,
                        dry_run=dry_run,
                        verbose=False,
                    )
                    if not success:
                        all_success = False

            return all_success
        finally:
            sys.path.pop(0)

    def _find_dotfiles_root(self) -> Path | None:
        current = Path(__file__).resolve().parent.parent.parent
        if (current / "stow").exists():
            return current
        home_dotfiles = Path.home() / "dotfiles"
        if home_dotfiles.exists():
            return home_dotfiles
        return None

    def _detect_os_profile(self) -> str:
        os_release = Path("/etc/os-release")
        if not os_release.exists():
            return "manjaro"
        content = os_release.read_text()
        for line in content.splitlines():
            if line.startswith("ID="):
                distro_id = line.split("=", 1)[1].strip('"')
                if distro_id in ("manjaro", "ubuntu"):
                    return distro_id
        return "manjaro"
