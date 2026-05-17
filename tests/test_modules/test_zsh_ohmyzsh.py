from unittest.mock import patch, MagicMock
from pathlib import Path

from setup.modules.zsh_ohmyzsh import ZshOhMyZshModule


class TestZshOhMyZshModule:
    def test_name(self):
        module = ZshOhMyZshModule()
        assert module.name == "zsh_ohmyzsh"

    def test_should_run_when_not_installed(self, mock_home):
        with patch("setup.modules.zsh_ohmyzsh.command_exists", return_value=False):
            with patch("setup.modules.zsh_ohmyzsh.dir_exists", return_value=False):
                module = ZshOhMyZshModule()
                assert module.should_run() is True

    def test_should_run_when_installed(self, mock_home):
        with patch("setup.modules.zsh_ohmyzsh.command_exists", return_value=True):
            with patch("setup.modules.zsh_ohmyzsh.dir_exists", return_value=True):
                module = ZshOhMyZshModule()
                assert module.should_run() is False

    def test_run_dry_run(self, mock_installer, mock_subprocess, mock_home):
        with patch("setup.modules.zsh_ohmyzsh.command_exists", return_value=False):
            with patch("setup.modules.zsh_ohmyzsh.dir_exists", return_value=False):
                module = ZshOhMyZshModule()
                result = module.run(mock_installer, dry_run=True)
                assert result is True
