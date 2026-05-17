from .atuin import AtuinModule
from .awesome import AwesomeModule
from .base import BaseModule
from .clipboard import ClipboardModule
from .cronjob import CronjobModule
from .dotfiles import DotfilesModule
from .git import GitModule
from .git_diff_image import GitDiffImageModule
from .kitty import KittyModule
from .neovim import NeovimModule
from .pacman_config import PacmanConfigModule
from .picom import PicomModule
from .ssh import SSHModule
from .zoxide import ZoxideModule
from .zsh_ohmyzsh import ZshOhMyZshModule

ALL_MODULES = [
    KittyModule,
    PacmanConfigModule,
    ZshOhMyZshModule,
    GitModule,
    NeovimModule,
    DotfilesModule,
    AwesomeModule,
    PicomModule,
    SSHModule,
    AtuinModule,
    ZoxideModule,
    ClipboardModule,
    CronjobModule,
    GitDiffImageModule,
]


def get_module_by_name(name: str) -> BaseModule | None:
    for cls in ALL_MODULES:
        if cls().name == name:
            return cls()
    return None


def get_all_module_names() -> list[str]:
    return [cls().name for cls in ALL_MODULES]
