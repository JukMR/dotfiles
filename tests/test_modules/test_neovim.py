from unittest.mock import patch, MagicMock
from pathlib import Path

from setup.modules.neovim import NeovimModule


class TestNeovimModule:
    def test_name(self):
        module = NeovimModule()
        assert module.name == "neovim"

    def test_should_run_when_no_config(self, mock_home):
        with patch("setup.modules.neovim.dir_exists", return_value=False):
            module = NeovimModule()
            assert module.should_run() is True

    def test_should_run_when_config_exists(self, mock_home):
        with patch("setup.modules.neovim.dir_exists", return_value=True):
            module = NeovimModule()
            assert module.should_run() is False

    def test_run_dry_run(self, mock_installer, mock_subprocess, mock_home):
        with patch("setup.modules.neovim.dir_exists", return_value=False):
            module = NeovimModule()
            result = module.run(mock_installer, dry_run=True)
            assert result is True
