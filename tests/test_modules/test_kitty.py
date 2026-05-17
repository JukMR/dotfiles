from unittest.mock import patch, MagicMock
from pathlib import Path

from setup.modules.kitty import KittyModule


class TestKittyModule:
    def test_name(self):
        module = KittyModule()
        assert module.name == "kitty"

    def test_should_run_when_not_installed(self):
        with patch("setup.modules.kitty.command_exists", return_value=False):
            module = KittyModule()
            assert module.should_run() is True

    def test_should_run_when_installed(self):
        with patch("setup.modules.kitty.command_exists", return_value=True):
            module = KittyModule()
            assert module.should_run() is False

    def test_run_skips_when_installed(self, mock_installer):
        with patch("setup.modules.kitty.command_exists", return_value=True):
            module = KittyModule()
            result = module.run(mock_installer, dry_run=True)
            assert result is True

    def test_run_dry_run(self, mock_installer, mock_subprocess):
        with patch("setup.modules.kitty.command_exists", return_value=False):
            module = KittyModule()
            result = module.run(mock_installer, dry_run=True)
            assert result is True
